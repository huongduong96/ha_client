part of '../main.dart';

class HAError {
  String message;
  final List<HAErrorAction> actions;

  HAError(this.message, {this.actions: const [HAErrorAction.tryAgain()]});

  HAError.unableToConnect({this.actions = const [HAErrorAction.tryAgain()]}) {
    this.message = "Unable to connect to Home Assistant";
  }

  HAError.disconnected({this.actions = const [HAErrorAction.reconnect()]}) {
    this.message = "Disconnected";
  }

  HAError.checkConnectionSettings({this.actions = const [HAErrorAction.reload(), HAErrorAction(title: "Settings", type: HAErrorActionType.OPEN_CONNECTION_SETTINGS)]}) {
    this.message = "Check connection settings";
  }
}

class HAErrorAction {
  final String title;
  final int type;
  final String url;

  const HAErrorAction({@required this.title, this.type: HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.tryAgain({this.title = "Try again", this.type = HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.reconnect({this.title = "Reconnect", this.type = HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.reload({this.title = "Reload", this.type = HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.loginAgain({this.title = "Login again", this.type = HAErrorActionType.RELOGIN, this.url});

}

class HAErrorActionType {
  static const FULL_RELOAD = 0;
  static const QUICK_RELOAD = 1;
  static const URL = 3;
  static const OPEN_CONNECTION_SETTINGS = 4;
  static const RELOGIN = 5;
}