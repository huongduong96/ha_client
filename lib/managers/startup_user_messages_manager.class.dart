part of '../main.dart';

class StartupUserMessagesManager {

  static final StartupUserMessagesManager _instance = StartupUserMessagesManager
      ._internal();

  factory StartupUserMessagesManager() {
    return _instance;
  }

  StartupUserMessagesManager._internal() {}

  bool _supportAppDevelopmentMessageShown;
  static final _supportAppDevelopmentMessageKey = "user-message-shown-support-development_3";

  void checkMessagesToShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _supportAppDevelopmentMessageShown = prefs.getBool(_supportAppDevelopmentMessageKey) ?? false;
    if (!_supportAppDevelopmentMessageShown) {
      _showSupportAppDevelopmentMessage();
    }
  }

  void _showSupportAppDevelopmentMessage() {
    eventBus.fire(ShowPopupDialogEvent(
        title: "Hi!",
        body: "As you may have noticed this app contains no ads. Also all app features are available for you for free. Following the principles of free and open source softwere this will not be changed in nearest future. But still you can support this application development materially. There is several options available, please check them in main menu -> Support app development. Thanks.",
        positiveText: "Take me there",
        negativeText: "Nope",
        onPositive: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_supportAppDevelopmentMessageKey, true);
            eventBus.fire(ShowPageEvent(path: "/putchase"));
          });
        },
        onNegative: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_supportAppDevelopmentMessageKey, true);
          });
        }
    ));
  }

}