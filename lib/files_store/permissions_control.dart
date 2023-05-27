import 'package:flutter_native/global.dart';

Future<bool> checkPermissionStatus(Permission permission) async {
  return (await permission.isGranted);
}

Future<bool> initialPermissionRequest(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

Future<bool> appSettingsPermissionRequest(Permission permission) async {
  await openAppSettings();
  bool hasPermission =
      await permission.request().then((status) => status.isGranted);
  return hasPermission;
}