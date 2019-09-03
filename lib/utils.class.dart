part of 'main.dart';

class Logger {

  static List<String> _log = [];

  static String getLog() {
    String res = '';
    _log.forEach((line) {
      res += "$line\n";
    });
    return res;
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;

    assert(inDebugMode = true);

    return inDebugMode;
  }

  static void e(String message) {
    _writeToLog("Error", message);
  }

  static void w(String message) {
    _writeToLog("Warning", message);
  }

  static void d(String message) {
    _writeToLog("Debug", message);
  }

  static void _writeToLog(String level, String message) {
    if (isInDebugMode) {
      debugPrint('$message');
    }
    DateTime t = DateTime.now();
    _log.add("${formatDate(t, ["mm","dd"," ","HH",":","nn",":","ss"])} [$level] :  $message");
    if (_log.length > 100) {
      _log.removeAt(0);
    }
  }

}

/*class HAError {
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

  const HAErrorAction.loginAgain({this.title = "Login again", this.type = HAErrorActionType.FULL_RELOAD, this.url});

}

class HAErrorActionType {
  static const FULL_RELOAD = 0;
  static const QUICK_RELOAD = 1;
  static const LOGOUT = 2;
  static const URL = 3;
  static const OPEN_CONNECTION_SETTINGS = 4;
}*/

class StateChangedEvent {
  String entityId;
  String newState;
  bool needToRebuildUI;

  StateChangedEvent({
    this.entityId,
    this.newState,
    this.needToRebuildUI: false
  });
}

class SettingsChangedEvent {
  bool reconnect;

  SettingsChangedEvent(this.reconnect);
}

class RefreshDataFinishedEvent {
  RefreshDataFinishedEvent();
}

class ReloadUIEvent {
  final bool full;

  ReloadUIEvent(this.full);
}

class StartAuthEvent {
  String oauthUrl;
  bool starting;

  StartAuthEvent(this.oauthUrl, this.starting);
}

class ServiceCallEvent {
  String domain;
  String service;
  String entityId;
  Map<String, dynamic> additionalParams;

  ServiceCallEvent(this.domain, this.service, this.entityId, this.additionalParams);
}

class ShowPopupDialogEvent {
  final String title;
  final String body;
  final String positiveText;
  final String negativeText;
  final  onPositive;
  final  onNegative;

  ShowPopupDialogEvent({this.title, this.body, this.positiveText: "Ok", this.negativeText: "Cancel", this.onPositive, this.onNegative});
}

class ShowPopupMessageEvent {
  final String title;
  final String body;
  final String buttonText;
  final  onButtonClick;

  ShowPopupMessageEvent({this.title, this.body, this.buttonText: "Ok", this.onButtonClick});
}

class ShowEntityPageEvent {
  Entity entity;

  ShowEntityPageEvent(this.entity);
}

class ShowPageEvent {
  final String path;
  final bool goBackFirst;

  ShowPageEvent({@required this.path, this.goBackFirst: false});
}

class ShowErrorEvent {
  final UserError error;

  ShowErrorEvent(this.error);
}