part of '../main.dart';

class LocationManager {

  static void updateDeviceLocation() {
    print("[Location isolate #${Isolate.current.hashCode}] started");
    SharedPreferences.getInstance().then((prefs){
      print("[Location isolate #${Isolate.current.hashCode}] loading settings");
      String webhookId = prefs.getString('app-webhook-id');
      String domain = prefs.getString('hassio-domain');
      String port = prefs.getString('hassio-port');
      String httpWebHost =
          "${prefs.getString('hassio-res-protocol')}://$domain:$port";
      if (webhookId != null && webhookId.isNotEmpty) {
        DateTime currentTime = DateTime.now();
        String timeData = "${currentTime.year}-${currentTime.month}-${currentTime.day} ${currentTime.hour}:${currentTime.minute}";
        try {
          print("[Location isolate #${Isolate.current.hashCode}] Sending test time data home...");
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
          print("[Location isolate #${Isolate.current.hashCode}] Error: ${e.toString()}");
        }
        Logger.d("[Location isolate #${Isolate.current.hashCode}] Getting device location...");
        Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).then((location) {
          Logger.d("[Location isolate #${Isolate.current.hashCode}] Got location: ${location.latitude} ${location.longitude}. Sending home...");
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
            print("[Location isolate #${Isolate.current.hashCode}] Error sending location: ${e.toString()}");
          }
        });

      } else {
        print("[Location isolate #${Isolate.current.hashCode}] No webhook id. Aborting");
      }
    });
  }

  static final LocationManager _instance = LocationManager
      ._internal();

  factory LocationManager() {
    return _instance;
  }

  LocationManager._internal() {
    _startLocationService();
  }

  final int alarmId = 34901199;

  void _startLocationService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    Duration locationUpdateInterval = Duration(minutes: prefs.getInt("location-interval") ?? 10);
    Logger.d("Canceling previous schedule if any...");
    await AndroidAlarmManager.cancel(alarmId);
    Logger.d("Scheduling location update for every ${locationUpdateInterval.inMinutes} minutes...");
    await AndroidAlarmManager.periodic(
        locationUpdateInterval,
      alarmId,
      LocationManager.updateDeviceLocation,
      wakeup: true,
      rescheduleOnReboot: true
    );
  }

}