part of '../../main.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
