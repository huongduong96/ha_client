part of '../main.dart';

class LocationManager {

  static void updateDeviceLocation(List<LocationData> locations) {
    print("[GPS isolate #${Isolate.current.hashCode}] Got device location update");
    SharedPreferences.getInstance().then((prefs){
      print("[GPS isolate #${Isolate.current.hashCode}] loading settings");
      String webhookId = prefs.getString('app-webhook-id');
      String domain = prefs.getString('hassio-domain');
      String port = prefs.getString('hassio-port');
      String httpWebHost =
          "${prefs.getString('hassio-res-protocol')}://$domain:$port";
      if (webhookId != null && webhookId.isNotEmpty) {
        int battery = DateTime.now().hour;
        try {
          print("[GPS isolate #${Isolate.current.hashCode}] Sending data home...");
          String url = "$httpWebHost/api/webhook/$webhookId";
          Map<String, String> headers = {};
          headers["Content-Type"] = "application/json";
          var data = {
            "type": "update_location",
            "data": {
              "gps": [locations[0].latitude, locations[0].longitude],
              "gps_accuracy": locations[0].accuracy,
              "battery": battery
            }
          };
          http.post(
              url,
              headers: headers,
              body: json.encode(data)
          );
        } on PlatformException catch (e) {
          if (e.code == 'PERMISSION_DENIED') {
            print("[GPS isolate #${Isolate.current.hashCode}] No location permission. Aborting");
          }
        }
      } else {
        print("[GPS isolate #${Isolate.current.hashCode}] No webhook id. Aborting");
      }
    });
  }

  static void updateTestEntity() {
    print("[Test isolate #${Isolate.current.hashCode}] alarm service callback");
    SharedPreferences.getInstance().then((prefs){
      print("[Test isolate #${Isolate.current.hashCode}] loading settings");
      String webhookId = prefs.getString('app-webhook-id');
      String domain = prefs.getString('hassio-domain');
      String port = prefs.getString('hassio-port');
      String httpWebHost =
          "${prefs.getString('hassio-res-protocol')}://$domain:$port";
      if (webhookId != null && webhookId.isNotEmpty) {
        DateTime currentTime = DateTime.now();
        String timeData = "${currentTime.year}-${currentTime.month}-${currentTime.day} ${currentTime.hour}:${currentTime.minute}";
        try {
          print("[Test isolate #${Isolate.current.hashCode}] Sending data home...");
          String url = "$httpWebHost/api/webhook/$webhookId";
          Map<String, String> headers = {};
          headers["Content-Type"] = "application/json";
          var data = {
            "type": "call_service",
            "data": {
              "domain": "input_datetime",
              "service": "set_datetime",
              "service_data": {
                "entity_id": "input_datetime.app_alarm_service_test",
                "datetime": timeData
              }
            }
          };
          http.post(
              url,
              headers: headers,
              body: json.encode(data)
          );
        } catch (e) {
          print("[Test isolate #${Isolate.current.hashCode}] Error: ${e.toString()}");
        }
      } else {
        print("[Test isolate #${Isolate.current.hashCode}] No webhook id. Aborting");
      }
    });
  }

  static final LocationManager _instance = LocationManager
      ._internal();

  factory LocationManager() {
    return _instance;
  }

  LocationManager._internal() {
    _registerLocationListener();
  }

  final int alarmId = 349011;
  final Duration testAlarmUpdateInterval = Duration(minutes: 10);

  void _registerLocationListener() async {
    var _locationService = Location();
    bool _permission = await _locationService.requestPermission();
    if (_permission) {
      Logger.d("Activating device location tracking");
      _locationService.changeSettings(interval: 10000, accuracy: LocationAccuracy.BALANCED);
      bool statusBackgroundLocation = await _locationService.registerBackgroundLocation(LocationManager.updateDeviceLocation);
      Logger.d("Location listener status: $statusBackgroundLocation");
    } else {
      Logger.e("Location permission not granted");
    }
    //await AndroidAlarmManager.cancel(alarmId);
    Logger.d("Activating alarm service test");
    await AndroidAlarmManager.periodic(testAlarmUpdateInterval, alarmId, LocationManager.updateTestEntity);
  }

}