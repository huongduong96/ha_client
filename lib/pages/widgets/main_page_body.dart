part of '../../main.dart';

class MainPageBody extends StatelessWidget {

  final bool empty;
  final onReload;
  final onMenu;
  final TabController tabController;

  const MainPageBody({Key key, this.empty, this.onReload, this.tabController, this.onMenu}) : super(key: key);

  List<Tab> buildUIViewTabs() {
    List<Tab> result = [];

    if (HomeAssistant().ui.views.isNotEmpty) {
      HomeAssistant().ui.views.forEach((HAView view) {
        //TODO Create a widget for that and pass view to it. An opposit way as it is implemented now
        result.add(view.buildTab());
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<PopupMenuItem<String>> popupMenuItems = [];

    popupMenuItems.add(PopupMenuItem<String>(
      child: new Text("Reload"),
      value: "reload",
    ));
    /*List<Widget> emptyBody = [
      Text("."),
    ];*/
    if (ConnectionManager().isAuthenticated) {
      //_showLoginButton = false;
      popupMenuItems.add(
          PopupMenuItem<String>(
            child: new Text("Logout"),
            value: "logout",
          ));
    }
    Widget bodyWidget;
    if (empty) {
      bodyWidget = Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator()
        ],
      );
    } else {
      bodyWidget = HomeAssistant().buildViews(context, tabController);
    }
    /*if (_showLoginButton) {
      emptyBody = [
        FlatButton(
          child: Text("Login with Home Assistant", style: TextStyle(fontSize: 16.0, color: Colors.white)),
          color: Colors.blue,
          onPressed: () => _fullLoad(),
        )
      ];
    }*/
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
                        onReload();
                      } else if (val == "logout") {
                        HomeAssistant().logout().then((_) {
                          onReload();
                        });
                      }
                    });
                  }
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => onMenu(),
            ),
            bottom: empty ? null : TabBar(
              controller: tabController,
              tabs: buildUIViewTabs(),
              isScrollable: true,
            ),
          ),

        ];
      },
      body: bodyWidget,
    );
  }
}
