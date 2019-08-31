part of '../main.dart';

class StartupUserMessagesManager {

  static final StartupUserMessagesManager _instance = StartupUserMessagesManager
      ._internal();

  factory StartupUserMessagesManager() {
    return _instance;
  }

  StartupUserMessagesManager._internal() {}

  bool _locationTrackingMessageShown;
  bool _supportAppDevelopmentMessageShown;
  static final _locationTrackingMessageKey = "user-message-shown-location_1";
  static final _supportAppDevelopmentMessageKey = "user-message-shown-support-development_1";

  void checkMessagesToShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _locationTrackingMessageShown = prefs.getBool(_locationTrackingMessageKey) ?? false;
    _supportAppDevelopmentMessageShown = prefs.getBool(_supportAppDevelopmentMessageKey) ?? false;
    if (!_locationTrackingMessageShown) {
      _showLocationTrackingMessage();
    } else if (!_supportAppDevelopmentMessageShown) {
      _showSupportAppDevelopmentMessage();
    }
  }

  void _showLocationTrackingMessage() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "Device location tracking is here!",
      body: "HA Client now support sending your device gps data to device_tracker instance created for current app integration. You can control location tracking in Configuration.",
      positiveText: "Enable now",
      negativeText: "Cancel",
      onPositive: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool("location-enabled", true);
          prefs.setBool(_locationTrackingMessageKey, true);
          LocationManager().startLocationService();
          LocationManager().updateDeviceLocation();
        });
      },
      onNegative: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool(_locationTrackingMessageKey, true);
        });
      }
    ));
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
            eventBus.fire(ShowPageEvent("/configuration"));
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