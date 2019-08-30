part of '../main.dart';

class LocationManager {

  static void updateDeviceLocation() {
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
          print("[Test isolate #${Isolate.current.hashCode}] Sending test time data home...");
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
        Logger.d("[Test isolate #${Isolate.current.hashCode}] Getting device location...");
        Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).then((location) {
          Logger.d("[Test isolate #${Isolate.current.hashCode}] Got location: ${location.latitude} ${location.longitude}. Sending home...");
          int battery = DateTime.now().hour;
          try {
            String url = "$httpWebHost/api/webhook/$webhookId";
            Map<String, String> headers = {};
            headers["Content-Type"] = "application/json";
            var data = {
              "type": "update_location",
              "data": {
                "gps": [location.latitude, location.longitude],
                "gps_accuracy": location.accuracy,
                "battery": battery
              }
            };
            http.post(
                url,
                headers: headers,
                body: json.encode(data)
            );
          } catch (e) {
            print("[Test isolate #${Isolate.current.hashCode}] Error sending location: ${e.toString()}");
          }
        });

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

  final int alarmId = 34901199;
  final Duration locationUpdateInterval = Duration(minutes: 5);

  void _registerLocationListener() async {
    Logger.d("Activating alarm service test");
    await AndroidAlarmManager.periodic(
        locationUpdateInterval,
      alarmId,
      LocationManager.updateDeviceLocation,
      wakeup: true,
      rescheduleOnReboot: true
    );
  }

}