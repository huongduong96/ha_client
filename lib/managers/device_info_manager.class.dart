part of '../main.dart';

class DeviceInfoManager {

  static final DeviceInfoManager _instance = DeviceInfoManager._internal();

  factory DeviceInfoManager() {
    return _instance;
  }

  String unicDeviceId;
  String manufacturer;
  String model;
  String osName;
  String osVersion;

  DeviceInfoManager._internal();

  loadDeviceInfo() {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((androidInfo) {
      unicDeviceId = "${androidInfo.model.toLowerCase().replaceAll(' ', '_')}_${androidInfo.androidId}";
      manufacturer = "${androidInfo.manufacturer}";
      model = "${androidInfo.model}";
      osName = "Android";
      osVersion = "${androidInfo.version.release}";
    });
  }
}