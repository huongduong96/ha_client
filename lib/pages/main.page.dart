part of '../main.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver, TickerProviderStateMixin {

  StreamSubscription<List<PurchaseDetails>> _subscription;
  StreamSubscription _stateSubscription;
  StreamSubscription _settingsSubscription;
  StreamSubscription _serviceCallSubscription;
  StreamSubscription _showEntityPageSubscription;
  StreamSubscription _showErrorSubscription;
  StreamSubscription _startAuthSubscription;
  StreamSubscription _showPopupDialogSubscription;
  StreamSubscription _showPopupMessageSubscription;
  StreamSubscription _reloadUISubscription;
  StreamSubscription _showPageSubscription;
  int _previousViewCount;
  //bool _showLoginButton = false;
  bool _preventAppRefresh = false;
  UserError _userError;

  @override
  void initState() {
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _firebaseMessaging.configure(
        onLaunch: (data) {
          Logger.d("Notification [onLaunch]: $data");
          return Future.value();
        },
        onMessage: (data) {
          Logger.d("Notification [onMessage]: $data");
          return _showNotification(title: data["notification"]["title"], text: data["notification"]["body"]);
        },
        onResume: (data) {
          Logger.d("Notification [onResume]: $data");
          return Future.value();
        }
    );

    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('mini_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: null);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _settingsSubscription = eventBus.on<SettingsChangedEvent>().listen((event) {
      Logger.d("Settings change event: reconnect=${event.reconnect}");
      if (event.reconnect) {
        _preventAppRefresh = false;
        _fullLoad();
      }
    });

    _fullLoad();


  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      Logger.d('Notification clicked: ' + payload);
    }
  }

  Future _showNotification({String title, String text}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'ha_notify', 'Home Assistant notifications', 'Notifications from Home Assistant notify service',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        title ?? appName,
        text,
        platformChannelSpecifics
    );
  }

  void _fullLoad() async {
    //TODO show loading somewhere somehow
    //_showInfoBottomBar(progress: true,);
    _subscribe().then((_) {
      ConnectionManager().init(loadSettings: true, forceReconnect: true).then((__){
        _fetchData();
      }, onError: (error) {
        _setErrorState(error);
      });
    });
  }

  void _quickLoad() {
    //_hideBottomBar();
    //TODO show loading somewhere somehow
    //_showInfoBottomBar(progress: true,);
    ConnectionManager().init(loadSettings: false, forceReconnect: false).then((_){
      _fetchData();
    }, onError: (error) {
      _setErrorState(error);
    });
  }

  _fetchData() async {
    setState(() {
      _userError = null;
    });
    await HomeAssistant().fetchData().then((_) {
      int currentViewCount = HomeAssistant().ui?.views?.length ?? 0;
      if (_previousViewCount != currentViewCount) {
        Logger.d("Views count changed ($_previousViewCount->$currentViewCount). Creating new tabs controller.");
        _viewsTabController = TabController(vsync: this, length: currentViewCount);
        _previousViewCount = currentViewCount;
      }
    }).catchError((code) {
      _setErrorState(code);
    });
    eventBus.fire(RefreshDataFinishedEvent());
    StartupUserMessagesManager().checkMessagesToShow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Logger.d("$state");
    if (state == AppLifecycleState.resumed && ConnectionManager().settingsLoaded && !_preventAppRefresh) {
      _quickLoad();
    }
  }

  void _handlePurchaseUpdates(purchase) {
    if (purchase is List<PurchaseDetails>) {
      if (purchase[0].status == PurchaseStatus.purchased) {
        eventBus.fire(ShowPopupMessageEvent(
            title: "Thanks a lot!",
            body: "Thank you for supporting HA Client development!",
            buttonText: "Ok"
        ));
      } else {
        Logger.d("Purchase change handler: ${purchase[0].status}");
      }
    } else {
      Logger.e("Something wrong with purchase handling. Got: $purchase");
    }
  }

  Future _subscribe() {
    Completer completer = Completer();
    if (_stateSubscription == null) {
      _stateSubscription = eventBus.on<StateChangedEvent>().listen((event) {
        if (event.needToRebuildUI) {
          Logger.d("New entity. Need to rebuild UI");
          _quickLoad();
        } else {
          setState(() {});
        }
      });
    }
    if (_reloadUISubscription == null) {
      _reloadUISubscription = eventBus.on<ReloadUIEvent>().listen((event){
        if (event.full)
          _fullLoad();
        else
          _quickLoad();
      });
    }
    if (_showPopupDialogSubscription == null) {
      _showPopupDialogSubscription = eventBus.on<ShowPopupDialogEvent>().listen((event){
        _showPopupDialog(
            title: event.title,
            body: event.body,
            onPositive: event.onPositive,
            onNegative: event.onNegative,
            positiveText: event.positiveText,
            negativeText: event.negativeText
        );
      });
    }
    if (_showPopupMessageSubscription == null) {
      _showPopupMessageSubscription = eventBus.on<ShowPopupMessageEvent>().listen((event){
        _showPopupDialog(
            title: event.title,
            body: event.body,
            onPositive: event.onButtonClick,
            positiveText: event.buttonText,
            negativeText: null
        );
      });
    }
    if (_serviceCallSubscription == null) {
      _serviceCallSubscription =
          eventBus.on<ServiceCallEvent>().listen((event) {
            _callService(event.domain, event.service, event.entityId,
                event.additionalParams);
          });
    }

    if (_showEntityPageSubscription == null) {
      _showEntityPageSubscription =
          eventBus.on<ShowEntityPageEvent>().listen((event) {
            _showEntityPage(event.entity.entityId);
          });
    }

    if (_showPageSubscription == null) {
      _showPageSubscription =
          eventBus.on<ShowPageEvent>().listen((event) {
            _showPage(event.path, event.goBackFirst);
          });
    }

    if (_showErrorSubscription == null) {
      _showErrorSubscription = eventBus.on<ShowErrorEvent>().listen((event){
        _setErrorState(event.error);
      });
    }

    if (_startAuthSubscription == null) {
      _startAuthSubscription = eventBus.on<StartAuthEvent>().listen((event){
        if (event.starting) {
          _showOAuth();
        } else {
          _preventAppRefresh = false;
          Navigator.of(context).pop();
          setState(() {
            _userError = null;
          });
        }
      });
    }

    _firebaseMessaging.getToken().then((String token) {
      HomeAssistant().fcmToken = token;
      completer.complete();
    });
    return completer.future;
  }

  void _showOAuth() {
    _preventAppRefresh = true;
    _setErrorState(UserError(code: ErrorCode.NOT_LOGGED_IN));
    Navigator.of(context).pushNamed('/login');
  }

  _setErrorState(error) {
    if (error is UserError) {
      setState(() {
        //_showBottomBar = false;
        _userError = error;
      });
    } else {
      setState(() {
        //_showBottomBar = false;
        _userError = UserError(code: ErrorCode.UNKNOWN);
      });
    }
    /*if (e == null) {
      _showErrorBottomBar(
        HAError("Unknown error")
      );
    } else {
      _showErrorBottomBar(e);
    }*/
  }

  void _showPopupDialog({String title, String body, var onPositive, var onNegative, String positiveText, String negativeText}) {
    List<Widget> buttons = [];
    buttons.add(FlatButton(
      child: new Text("$positiveText"),
      onPressed: () {
        Navigator.of(context).pop();
        if (onPositive != null) {
          onPositive();
        }
      },
    ));
    if (negativeText != null) {
      buttons.add(FlatButton(
        child: new Text("$negativeText"),
        onPressed: () {
          Navigator.of(context).pop();
          if (onNegative != null) {
            onNegative();
          }
        },
      ));
    }
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("$title"),
          content: new Text("$body"),
          actions: buttons,
        );
      },
    );
  }

  void _callService(String domain, String service, String entityId, Map additionalParams) {
    //TODO show SnackBar
    /*_showInfoBottomBar(
      message: "Calling $domain.$service",
      duration: Duration(seconds: 3)
    );*/
    ConnectionManager().callService(domain: domain, service: service, entityId: entityId, additionalServiceData: additionalParams).catchError((e) => _setErrorState(e));
  }

  void _showEntityPage(String entityId) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntityViewPage(entityId: entityId),
        )
    );
  }

  void _showPage(String path, bool goBackFirst) {
    if (goBackFirst) {
      Navigator.pop(context);
    }
    Navigator.pushNamed(
        context,
        path
    );
  }

  /*void _hideBottomBar() {
    //_scaffoldKey?.currentState?.hideCurrentSnackBar();
    setState(() {
      _showBottomBar = false;
    });
  }*/

  /*Widget _bottomBarAction;
  bool _showBottomBar = false;
  String _bottomBarText;
  bool _bottomBarProgress;
  Color _bottomBarColor;
  Timer _bottomBarTimer;*/

  /*void _showInfoBottomBar({String message, bool progress: false, Duration duration}) {
    _bottomBarTimer?.cancel();
    _bottomBarAction = Container(height: 0.0, width: 0.0,);
    _bottomBarColor = Colors.grey.shade50;
    setState(() {
      _bottomBarText = message;
      _bottomBarProgress = progress;
      _showBottomBar = true;
    });
    if (duration != null) {
      _bottomBarTimer = Timer(duration, () {
        _hideBottomBar();
      });
    }
  }*/

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TabController _viewsTabController;

  @override
  Widget build(BuildContext context) {
    Widget bottomBar;
    if (_userError != null) {
      bottomBar = UserErrorScreen(error: _userError,);
      /*List<Widget> bottomBarChildren = [];
      if (_bottomBarText != null) {
        bottomBarChildren.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                Sizes.leftWidgetPadding, Sizes.rowPadding, 0.0,
                Sizes.rowPadding),
            child: Text(
              "$_bottomBarText",
              textAlign: TextAlign.left,
              softWrap: true,
            ),
          )

        );
      }*/
      /*if (_bottomBarProgress) {
        bottomBarChildren.add(
          CollectionScaleTransition(
            children: <Widget>[
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.on),),
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.unavailable),),
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.off),),
            ],
          ),
        );
      }*/
      /*if (bottomBarChildren.isNotEmpty) {
        bottomBar = Container(
          color: _bottomBarColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: _bottomBarProgress ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: bottomBarChildren,
                ),
              ),
              _bottomBarAction
            ],
          ),
        );
      }*/
    }
    // This method is rerun every time setState is called.
    if (HomeAssistant().isNoViews) {
      return Scaffold(
          key: _scaffoldKey,
          primary: false,
          drawer: AppDrawer(),
          bottomNavigationBar: bottomBar,
          body: MainPageBody(
            empty: true,
            onReload: () => _quickLoad(),
            tabController: _viewsTabController,
            onMenu: () => _scaffoldKey.currentState.openDrawer(),
          )
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(),
        primary: false,
        bottomNavigationBar: bottomBar,
        body: MainPageBody(
          empty: false,
          onReload: () => _quickLoad(),
          tabController: _viewsTabController,
          onMenu: () => _scaffoldKey.currentState.openDrawer(),
        ),
      );
    }
  }

  @override
  void dispose() {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _viewsTabController?.dispose();
    _stateSubscription?.cancel();
    _settingsSubscription?.cancel();
    _serviceCallSubscription?.cancel();
    _showPopupDialogSubscription?.cancel();
    _showPopupMessageSubscription?.cancel();
    _showEntityPageSubscription?.cancel();
    _showErrorSubscription?.cancel();
    _startAuthSubscription?.cancel();
    _subscription?.cancel();
    _showPageSubscription?.cancel();
    _reloadUISubscription?.cancel();
    //TODO disconnect
    //widget.homeAssistant?.disconnect();
    super.dispose();
  }
}
