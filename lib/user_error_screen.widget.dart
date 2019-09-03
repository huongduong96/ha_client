part of 'main.dart';

class UserErrorScreen extends StatelessWidget {

  final UserError error;

  const UserErrorScreen({Key key, this.error}) : super(key: key);

  void _goToAppSettings(BuildContext context) {
    Navigator.pushNamed(context, '/connection-settings');
  }

  void _reload() {
    eventBus.fire(ReloadUIEvent(true));
  }

  void _disableLovelace() {
    SharedPreferences.getInstance().then((prefs){
      prefs.setBool("use-lovelace", false);
      eventBus.fire(ReloadUIEvent(true));
    });
  }

  void _reLogin() {
    ConnectionManager().logout().then((_) => eventBus.fire(ReloadUIEvent(true)));
  }

  @override
  Widget build(BuildContext context) {
    String errorText;
    List<Widget> buttons = [];
    switch (this.error.code) {
      case ErrorCode.AUTH_ERROR: {
        errorText = "There was an error logging in to Home Assistant";
        buttons.add(RaisedButton(
          onPressed: () => _reload(),
          child: Text("Retry"),
        ));
        buttons.add(RaisedButton(
          onPressed: () => _reLogin(),
          child: Text("Login again"),
        ));
        break;
      }
      case ErrorCode.UNABLE_TO_CONNECT: {
        errorText = "Unable to connect to Home Assistant";
        buttons.addAll(<Widget>[
          RaisedButton(
              onPressed: () => _reload(),
              child: Text("Retry")
          ),
          Container(width: 15.0,),
          RaisedButton(
            onPressed: () => _goToAppSettings(context),
            child: Text("Check application settings"),
          )
        ]
        );
        break;
      }
      case ErrorCode.AUTH_INVALID: {
        errorText = "${error.message ?? "Can't login to Home Assistant"}";
        buttons.addAll(<Widget>[
          RaisedButton(
              onPressed: () => _reload(),
              child: Text("Retry")
          ),
          Container(width: 15.0,),
          RaisedButton(
            onPressed: () => _reLogin(),
            child: Text("Login again"),
          )
        ]
        );
        break;
      }
      case ErrorCode.GENERAL_AUTH_ERROR: {
        buttons.addAll(<Widget>[
          RaisedButton(
              onPressed: () => _reload(),
              child: Text("Retry")
          ),
          Container(width: 15.0,),
          RaisedButton(
            onPressed: () => _reLogin(),
            child: Text("Login again"),
          )
        ]
        );
        break;
      }
      case ErrorCode.DISCONNECTED: {
        errorText = "Disconnected";
        buttons.addAll(<Widget>[
          RaisedButton(
              onPressed: () => _reload(),
              child: Text("Reconnect")
          ),
          Container(width: 15.0,),
          RaisedButton(
            onPressed: () => _goToAppSettings(context),
            child: Text("Check application settings"),
          )
        ]
        );
        break;
      }
      case ErrorCode.CONNECTION_TIMEOUT: {
        errorText = "Connection timeout";
        buttons.addAll(<Widget>[
            RaisedButton(
              onPressed: () => _reload(),
              child: Text("Reconnect")
            ),
            Container(width: 15.0,),
            RaisedButton(
              onPressed: () => _goToAppSettings(context),
              child: Text("Check application settings"),
            )
          ]
        );
        break;
      }
      case ErrorCode.NOT_CONFIGURED: {
        errorText = "Looks like HA Client is not configured yet.";
        buttons.add(RaisedButton(
          onPressed: () => _goToAppSettings(context),
          child: Text("Open application settings"),
        ));
        break;
      }
      case ErrorCode.ERROR_GETTING_PANELS:
      case ErrorCode.ERROR_GETTING_CONFIG:
      case ErrorCode.ERROR_GETTING_STATES: {
        errorText = "Couldn't get data from Home Assistant. ${error.message ?? ""}";
        buttons.add(RaisedButton(
          onPressed: () => _reload(),
          child: Text("Try again"),
        ));
        break;
      }
      case ErrorCode.ERROR_GETTING_LOVELACE_CONFIG: {
        errorText = "Couldn't get Lovelace UI config. You can try to disable it and use group-based UI istead.";
        buttons.addAll(<Widget>[
          RaisedButton(
            onPressed: () => _reload(),
            child: Text("Retry"),
          ),
          Container(width: 15.0,),
          RaisedButton(
            onPressed: () => _disableLovelace(),
            child: Text("Disable Lovelace UI"),
          )
        ]);
        break;
      }
      case ErrorCode.NOT_LOGGED_IN: {
        errorText = "You are not logged in yet. Please login.";
        buttons.add(RaisedButton(
          onPressed: () => _reload(),
          child: Text("Login"),
        ));
        break;
      }
      case ErrorCode.NO_MOBILE_APP_COMPONENT: {
        errorText = "Looks like mobile_app component is not enabled on your Home Assistant instance. Please add it to your configuration.yaml";
        buttons.add(RaisedButton(
          onPressed: () => Launcher.launchURLInCustomTab(context: context, url: "https://www.home-assistant.io/components/mobile_app/"),
          child: Text("Help"),
        ));
        break;
      }
      default: {
        errorText = "There was an error. Code ${this.error.code}";
        buttons.add(RaisedButton(
          onPressed: () => _reload(),
          child: Text("Reload"),
        ));
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: Sizes.leftWidgetPadding, right: Sizes.rightWidgetPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 100.0, bottom: 20.0),
                    child: Icon(
                        Icons.error,
                        color: Colors.redAccent,
                        size: 48.0
                    )
                ),
                Text(
                  errorText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45, fontSize: Sizes.largeFontSize),
                  softWrap: true,
                  maxLines: 5,
                ),
                Container(height: Sizes.rowPadding,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buttons.isNotEmpty ? buttons : Container(height: 0.0, width: 0.0,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
