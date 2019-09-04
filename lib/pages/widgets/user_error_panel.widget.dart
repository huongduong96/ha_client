part of '../../main.dart';

class UserErrorActionButton extends StatelessWidget {

  final onPressed;
  final String text;

  const UserErrorActionButton({Key key, this.onPressed, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () => this.onPressed(),
      color: Colors.blue,
      child: Text(
        "${this.text}",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

}

class UserErrorPanel extends StatelessWidget {

  final UserError error;

  const UserErrorPanel({Key key, this.error}) : super(key: key);

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
        buttons.add(UserErrorActionButton(
          onPressed: () => _reload(),
          text: "Retry",
        ));
        buttons.add(UserErrorActionButton(
          onPressed: () => _reLogin(),
          text: "Login again",
        ));
        break;
      }
      case ErrorCode.UNABLE_TO_CONNECT: {
        errorText = "Unable to connect to Home Assistant";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
              onPressed: () => _reload(),
              text: "Retry"
          ),
          UserErrorActionButton(
            onPressed: () => _goToAppSettings(context),
            text: "Check application settings",
          )
        ]
        );
        break;
      }
      case ErrorCode.AUTH_INVALID: {
        errorText = "${error.message ?? "Can't login to Home Assistant"}";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
              onPressed: () => _reload(),
              text: "Retry"
          ),
          UserErrorActionButton(
            onPressed: () => _reLogin(),
            text: "Login again",
          )
        ]
        );
        break;
      }
      case ErrorCode.GENERAL_AUTH_ERROR: {
        errorText = "There was some error logging in. ${this.error.message ?? ""}";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
              onPressed: () => _reload(),
              text: "Retry"
          ),
          UserErrorActionButton(
            onPressed: () => _reLogin(),
            text: "Login again",
          )
        ]
        );
        break;
      }
      case ErrorCode.SECURE_STORAGE_READ_ERROR: {
        errorText = "There was an error reading secure storage. You can try again or clear saved auth data and login again.";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
              onPressed: () => _reload(),
              text: "Retry"
          ),
          UserErrorActionButton(
            onPressed: () => _reLogin(),
            text: "Clear and login again",
          )
        ]
        );
        break;
      }
      case ErrorCode.DISCONNECTED: {
        errorText = "Disconnected";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
              onPressed: () => _reload(),
              text: "Reconnect"
          ),
          UserErrorActionButton(
            onPressed: () => _goToAppSettings(context),
            text: "Check application settings",
          )
        ]
        );
        break;
      }
      case ErrorCode.CONNECTION_TIMEOUT: {
        errorText = "Connection timeout";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
              onPressed: () => _reload(),
              text: "Reconnect"
            ),
          UserErrorActionButton(
              onPressed: () => _goToAppSettings(context),
              text: "Check application settings",
            )
          ]
        );
        break;
      }
      case ErrorCode.NOT_CONFIGURED: {
        errorText = "Looks like HA Client is not configured yet.";
        buttons.add(UserErrorActionButton(
          onPressed: () => _goToAppSettings(context),
          text: "Open application settings",
        ));
        break;
      }
      case ErrorCode.ERROR_GETTING_PANELS:
      case ErrorCode.ERROR_GETTING_CONFIG:
      case ErrorCode.ERROR_GETTING_STATES: {
        errorText = "Couldn't get data from Home Assistant. ${error.message ?? ""}";
        buttons.add(UserErrorActionButton(
          onPressed: () => _reload(),
          text: "Try again",
        ));
        break;
      }
      case ErrorCode.ERROR_GETTING_LOVELACE_CONFIG: {
        errorText = "Couldn't get Lovelace UI config. You can try to disable it and use group-based UI istead.";
        buttons.addAll(<Widget>[
          UserErrorActionButton(
            onPressed: () => _reload(),
            text: "Retry",
          ),
          UserErrorActionButton(
            onPressed: () => _disableLovelace(),
            text: "Disable Lovelace UI",
          )
        ]);
        break;
      }
      case ErrorCode.NOT_LOGGED_IN: {
        errorText = "You are not logged in yet. Please login.";
        buttons.add(UserErrorActionButton(
          onPressed: () => _reload(),
          text: "Login",
        ));
        break;
      }
      case ErrorCode.NO_MOBILE_APP_COMPONENT: {
        errorText = "Looks like mobile_app component is not enabled on your Home Assistant instance. Please add it to your configuration.yaml";
        buttons.add(UserErrorActionButton(
          onPressed: () => Launcher.launchURLInCustomTab(context: context, url: "https://www.home-assistant.io/components/mobile_app/"),
          text: "Help",
        ));
        break;
      }
      default: {
        errorText = "There was an error. Code ${this.error.code}";
        buttons.add(UserErrorActionButton(
          onPressed: () => _reload(),
          text: "Reload",
        ));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(
          color: Colors.deepOrange,
          height: 1.0,
          indent: 8.0,
          endIndent: 8.0,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                errorText,
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.black87, fontSize: 18.0),
                softWrap: true,
                maxLines: 3,
              )
            ],
          ),
        ),
        ButtonBar(
          children: buttons,
        )
      ],
    );
  }
}
