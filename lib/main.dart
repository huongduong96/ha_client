import 'dart:convert';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'const.dart';
part 'utils/launcher.dart';
part 'entities/entity.class.dart';
part 'entities/entity_wrapper.class.dart';
part 'entities/timer/timer_entity.class.dart';
part 'entities/switch/switch_entity.class.dart';
part 'entities/button/button_entity.class.dart';
part 'entities/text/text_entity.class.dart';
part 'entities/climate/climate_entity.class.dart';
part 'entities/cover/cover_entity.class.dart';
part 'entities/date_time/date_time_entity.class.dart';
part 'entities/light/light_entity.class.dart';
part 'entities/select/select_entity.class.dart';
part 'entities/sun/sun_entity.class.dart';
part 'entities/sensor/sensor_entity.class.dart';
part 'entities/slider/slider_entity.dart';
part 'entities/media_player/media_player_entity.class.dart';
part 'entities/lock/lock_entity.class.dart';
part 'entities/group/group_entity.class.dart';
part 'entities/fan/fan_entity.class.dart';
part 'entities/automation/automation_entity.class.dart';
part 'entities/camera/camera_entity.class.dart';
part 'entities/alarm_control_panel/alarm_control_panel_entity.class.dart';
part 'entity_widgets/common/badge.dart';
part 'entity_widgets/model_widgets.dart';
part 'entity_widgets/default_entity_container.dart';
part 'entity_widgets/missed_entity.dart';
part 'entity_widgets/glance_entity_container.dart';
part 'entity_widgets/button_entity_container.dart';
part 'entity_widgets/common/entity_attributes_list.dart';
part 'entity_widgets/entity_icon.dart';
part 'entity_widgets/entity_name.dart';
part 'entity_widgets/common/last_updated.dart';
part 'entity_widgets/common/mode_swicth.dart';
part 'entity_widgets/common/mode_selector.dart';
part 'entity_widgets/common/universal_slider.dart';
part 'entity_widgets/common/flat_service_button.dart';
part 'entity_widgets/common/light_color_picker.dart';
part 'entity_widgets/common/camera_stream_view.dart';
part 'entity_widgets/entity_colors.class.dart';
part 'entity_widgets/entity_page_container.dart';
part 'entity_widgets/history_chart/entity_history.dart';
part 'entity_widgets/history_chart/simple_state_history_chart.dart';
part 'entity_widgets/history_chart/numeric_state_history_chart.dart';
part 'entity_widgets/history_chart/combined_history_chart.dart';
part 'entity_widgets/history_chart/history_control_widget.dart';
part 'entity_widgets/history_chart/entity_history_moment.dart';
part 'entities/switch/widget/switch_state.dart';
part 'entities/slider/widgets/slider_controls.dart';
part 'entities/text/widgets/text_input_state.dart';
part 'entities/select/widgets/select_state.dart';
part 'entity_widgets/common/simple_state.dart';
part 'entities/timer/widgets/timer_state.dart';
part 'entities/climate/widgets/climate_state.widget.dart';
part 'entities/cover/widgets/cover_state.dart';
part 'entities/date_time/widgets/date_time_state.dart';
part 'entities/lock/widgets/lock_state.dart';
part 'entities/climate/widgets/climate_controls.dart';
part 'entities/climate/widgets/temperature_control_widget.dart';
part 'entities/cover/widgets/cover_controls.widget.dart';
part 'entities/light/widgets/light_controls.dart';
part 'entities/media_player/widgets/media_player_widgets.dart';
part 'entities/fan/widgets/fan_controls.dart';
part 'entities/alarm_control_panel/widgets/alarm_control_panel_controls.widget.dart';
part 'pages/settings.page.dart';
part 'pages/purchase.page.dart';
part 'pages/widgets/product_purchase.widget.dart';
part 'pages/widgets/page_loading_indicator.dart';
part 'pages/widgets/page_loading_error.dart';
part 'pages/panel.page.dart';
part 'home_assistant.class.dart';
part 'pages/log.page.dart';
part 'pages/entity.page.dart';
part 'utils.class.dart';
part 'mdi.class.dart';
part 'entity_collection.class.dart';
part 'managers/auth_manager.class.dart';
part 'managers/location_manager.class.dart';
part 'managers/mobile_app_integration_manager.class.dart';
part 'managers/connection_manager.class.dart';
part 'managers/device_info_manager.class.dart';
part 'managers/startup_user_messages_manager.class.dart';
part 'ui_class/ui.dart';
part 'ui_class/view.class.dart';
part 'ui_class/card.class.dart';
part 'ui_class/sizes_class.dart';
part 'ui_class/panel_class.dart';
part 'ui_widgets/view.dart';
part 'ui_widgets/card_widget.dart';
part 'ui_widgets/card_header_widget.dart';
part 'panels/config_panel_widget.dart';
part 'panels/widgets/link_to_web_config.dart';


EventBus eventBus = new EventBus();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
const String appName = "HA Client";
const appVersion = "0.6.5-alpha2";

void main() async {
  FlutterError.onError = (errorDetails) {
    Logger.e( "${errorDetails.exception}");
    if (Logger.isInDebugMode) {
      FlutterError.dumpErrorToConsole(errorDetails);
    }
  };

  runZoned(() {
    //AndroidAlarmManager.initialize().then((_) {
      runApp(new HAClientApp());
    //  print("Running MAIN isolate ${Isolate.current.hashCode}");
    //});

  }, onError: (error, stack) {
    Logger.e("$error");
    Logger.e("$stack");
    if (Logger.isInDebugMode) {
      debugPrint("$stack");
    }
  });
}

class HAClientApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: appName,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => MainPage(title: 'HA Client'),
        "/connection-settings": (context) => ConnectionSettingsPage(title: "Settings"),
        "/putchase": (context) => PurchasePage(title: "Support app development"),
        "/log-view": (context) => LogViewPage(title: "Log"),
        "/login": (context) => WebviewScaffold(
          url: "${ConnectionManager().oauthUrl}",
          appBar: new AppBar(
            leading: IconButton(
                icon: Icon(Icons.help),
                onPressed: () => Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.homemade.systems/docs#authentication")
            ),
            title: new Text("Login with HA"),
            actions: <Widget>[
              FlatButton(
                child: Text("Manual", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  eventBus.fire(ShowPageEvent(path: "/connection-settings", goBackFirst: true));
                },
              )
            ],
          ),
        ),
        "/webview": (context) => WebviewScaffold(
          url: "${(ModalRoute.of(context).settings.arguments as Map)['url']}",
          appBar: new AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop()
            ),
            title: new Text("${(ModalRoute.of(context).settings.arguments as Map)['title']}"),
          ),
        )
      },
    );
  }
}

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
  bool _showLoginButton = false;
  bool _preventAppRefresh = false;

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
    _showInfoBottomBar(progress: true,);
    _subscribe().then((_) {
      ConnectionManager().init(loadSettings: true, forceReconnect: true).then((__){
        _fetchData();
        StartupUserMessagesManager().checkMessagesToShow();
      }, onError: (e) {
        _setErrorState(e);
      });
    });
  }

  void _quickLoad() {
    _hideBottomBar();
    _showInfoBottomBar(progress: true,);
    ConnectionManager().init(loadSettings: false, forceReconnect: false).then((_){
      _fetchData();
      StartupUserMessagesManager().checkMessagesToShow();
    }, onError: (e) {
      _setErrorState(e);
    });
  }

  _fetchData() async {
    await HomeAssistant().fetchData().then((_) {
      _hideBottomBar();
      int currentViewCount = HomeAssistant().ui?.views?.length ?? 0;
      if (_previousViewCount != currentViewCount) {
        Logger.d("Views count changed ($_previousViewCount->$currentViewCount). Creating new tabs controller.");
        _viewsTabController = TabController(vsync: this, length: currentViewCount);
        _previousViewCount = currentViewCount;
      }
    }).catchError((e) {
      if (e is HAError) {
        _setErrorState(e);
      } else {
        _setErrorState(HAError(e.toString()));
      }
    });
    eventBus.fire(RefreshDataFinishedEvent());
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
        _showErrorBottomBar(event.error);
      });
    }

    if (_startAuthSubscription == null) {
      _startAuthSubscription = eventBus.on<StartAuthEvent>().listen((event){
        setState(() {
          _showLoginButton = event.showButton;
        });
        if (event.showButton) {
          _showOAuth();
        } else {
          _preventAppRefresh = false;
          Navigator.of(context).pop();
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
    Navigator.of(context).pushNamed('/login');
  }

  _setErrorState(HAError e) {
    if (e == null) {
      _showErrorBottomBar(
        HAError("Unknown error")
      );
    } else {
      _showErrorBottomBar(e);
    }
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

  //TODO remove this shit
  void _callService(String domain, String service, String entityId, Map additionalParams) {
    _showInfoBottomBar(
      message: "Calling $domain.$service",
      duration: Duration(seconds: 3)
    );
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

  List<Tab> buildUIViewTabs() {
    List<Tab> result = [];

      if (HomeAssistant().ui.views.isNotEmpty) {
        HomeAssistant().ui.views.forEach((HAView view) {
          result.add(view.buildTab());
        });
      }

    return result;
  }

  Drawer _buildAppDrawer() {
    List<Widget> menuItems = [];
    menuItems.add(
        UserAccountsDrawerHeader(
          accountName: Text(HomeAssistant().userName),
          accountEmail: Text(ConnectionManager().displayHostname ?? "Not configured"),
          onDetailsPressed: () {
            final flutterWebViewPlugin = new FlutterWebviewPlugin();
            flutterWebViewPlugin.onStateChanged.listen((viewState) async {
              if (viewState.type == WebViewState.startLoad) {
                Logger.d("[WebView] Injecting external auth JS");
                rootBundle.loadString('assets/js/externalAuth.js').then((js){
                  flutterWebViewPlugin.evalJavascript(js.replaceFirst("[token]", ConnectionManager()._token));
                });
              }
            });
            Navigator.of(context).pushNamed(
                "/webview",
                arguments: {
                  "url": "${ConnectionManager().httpWebHost}/profile?external_auth=1",
                  "title": "Profile"
                }
            );
          },
          currentAccountPicture: CircleAvatar(
            child: Text(
              HomeAssistant().userAvatarText,
              style: TextStyle(
                  fontSize: 32.0
              ),
            ),
          ),
        )
    );
      if (HomeAssistant().panels.isNotEmpty) {
        HomeAssistant().panels.forEach((Panel panel) {
          if (!panel.isHidden) {
            menuItems.add(
                new ListTile(
                    leading: Icon(MaterialDesignIcons.getIconDataFromIconName(panel.icon)),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${panel.title}"),
                        Container(width: 4.0,),
                        panel.isWebView ? Text("webview", style: TextStyle(fontSize: 8.0, color: Colors.black45),) : Container(width: 1.0,)
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      panel.handleOpen(context);
                    }
                )
            );
          }
        });
      }
      menuItems.addAll([
        Divider(),
        ListTile(
          leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:login-variant")),
          title: Text("Connection settings"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/connection-settings');
          },
        )
      ]);
      menuItems.addAll([
        Divider(),
        new ListTile(
          leading: Icon(Icons.insert_drive_file),
          title: Text("Log"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/log-view');
          },
        ),
        new ListTile(
          leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:github-circle")),
          title: Text("Report an issue"),
          onTap: () {
            Navigator.of(context).pop();
            Launcher.launchURL("https://github.com/estevez-dev/ha_client/issues/new");
          },
        ),
        Divider(),
        new ListTile(
          leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:food")),
          title: Text("Support app development"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/putchase');
          },
        ),
        Divider(),
        new ListTile(
          leading: Icon(Icons.help),
          title: Text("Help"),
          onTap: () {
            Navigator.of(context).pop();
            Launcher.launchURL("http://ha-client.homemade.systems/docs");
          },
        ),
        new ListTile(
          leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:discord")),
          title: Text("Join Discord channel"),
          onTap: () {
            Navigator.of(context).pop();
            Launcher.launchURL("https://discord.gg/AUzEvwn");
          },
        ),
        new AboutListTile(
          aboutBoxChildren: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURL("http://ha-client.homemade.systems/");
              },
              child: Text(
                "ha-client.homemade.systems",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.homemade.systems/terms_and_conditions");
              },
              child: Text(
                "Terms and Conditions",
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.homemade.systems/privacy_policy");
              },
              child: Text(
                "Privacy Policy",
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                ),
              ),
            )
          ],
          applicationName: appName,
          applicationVersion: appVersion
        )
      ]);
    return new Drawer(
      child: ListView(
        children: menuItems,
      ),
    );
  }

  void _hideBottomBar() {
    //_scaffoldKey?.currentState?.hideCurrentSnackBar();
    setState(() {
      _showBottomBar = false;
    });
  }

  Widget _bottomBarAction;
  bool _showBottomBar = false;
  String _bottomBarText;
  bool _bottomBarProgress;
  Color _bottomBarColor;
  Timer _bottomBarTimer;

  void _showInfoBottomBar({String message, bool progress: false, Duration duration}) {
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
  }

  void _showErrorBottomBar(HAError error) {
    TextStyle textStyle = TextStyle(
        color: Colors.blue,
        fontSize: Sizes.nameFontSize
    );
    _bottomBarColor = Colors.red.shade100;
    List<Widget> actions = [];
    error.actions.forEach((HAErrorAction action) {
      switch (action.type) {
        case HAErrorActionType.FULL_RELOAD: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              _fullLoad();
            },
          ));
          break;
        }

        case HAErrorActionType.QUICK_RELOAD: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              _quickLoad();
            },
          ));
          break;
        }

        case HAErrorActionType.URL: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              Launcher.launchURLInCustomTab(context: context, url: "${action.url}");
            },
          ));
          break;
        }

        case HAErrorActionType.OPEN_CONNECTION_SETTINGS: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              Navigator.pushNamed(context, '/connection-settings');
            },
          ));
          break;
        }
      }
    });
    if (actions.isNotEmpty) {
      _bottomBarAction = Row(
        mainAxisSize: MainAxisSize.min,
        children: actions,
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      _bottomBarAction = Container(height: 0.0, width: 0.0,);
    }
    setState(() {
      _bottomBarProgress = false;
      _bottomBarText = "${error.message}";
      _showBottomBar = true;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildScaffoldBody(bool empty) {
    List<PopupMenuItem<String>> popupMenuItems = [];

    popupMenuItems.add(PopupMenuItem<String>(
      child: new Text("Reload"),
      value: "reload",
    ));
    List<Widget> emptyBody = [
      Text("."),
    ];
    if (ConnectionManager().isAuthenticated) {
      _showLoginButton = false;
      popupMenuItems.add(
          PopupMenuItem<String>(
            child: new Text("Logout"),
            value: "logout",
          ));
    }
    if (_showLoginButton) {
      emptyBody = [
        FlatButton(
          child: Text("Login with Home Assistant", style: TextStyle(fontSize: 16.0, color: Colors.white)),
          color: Colors.blue,
          onPressed: () => _fullLoad(),
        )
      ];
    }
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            floating: true,
            pinned: true,
            primary: true,
            title: Text(HomeAssistant().locationName ?? ""),
            actions: <Widget>[
              IconButton(
                icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:dots-vertical"), color: Colors.white,),
                onPressed: () {
                  showMenu(
                    position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width, 70.0, 0.0, 0.0),
                    context: context,
                    items: popupMenuItems
                  ).then((String val) {
                    if (val == "reload") {
                      _quickLoad();
                    } else if (val == "logout") {
                      HomeAssistant().logout().then((_) {
                        _quickLoad();
                      });
                    }
                  });
                }
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            bottom: empty ? null : TabBar(
              controller: _viewsTabController,
              tabs: buildUIViewTabs(),
              isScrollable: true,
            ),
          ),

        ];
      },
      body: empty ?
      Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: emptyBody
        ),
      )
          :
      HomeAssistant().buildViews(context, _viewsTabController),
    );
  }

  TabController _viewsTabController;

  @override
  Widget build(BuildContext context) {
    Widget bottomBar;
    if (_showBottomBar) {
      List<Widget> bottomBarChildren = [];
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
      }
      if (_bottomBarProgress) {
        bottomBarChildren.add(
          CollectionScaleTransition(
            children: <Widget>[
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.on),),
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.unavailable),),
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.off),),
            ],
          ),
        );
      }
      if (bottomBarChildren.isNotEmpty) {
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
      }
    }
    // This method is rerun every time setState is called.
    if (HomeAssistant().isNoViews) {
      return Scaffold(
        key: _scaffoldKey,
        primary: false,
        drawer: _buildAppDrawer(),
        bottomNavigationBar: bottomBar,
        body: _buildScaffoldBody(true)
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        drawer: _buildAppDrawer(),
        primary: false,
        bottomNavigationBar: bottomBar,
        body: _buildScaffoldBody(false),
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
