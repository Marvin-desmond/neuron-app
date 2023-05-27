import 'package:flutter_native/global.dart';

Future<bool> requestPermission(
    Permission permission, BuildContext context) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    } else if (result == PermissionStatus.permanentlyDenied) {
      bool goToSettings = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission required'),
            content: const Text(
                'Please grant the requested permission in the app settings.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Go to settings'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
      if (goToSettings) {
        bool hasPermission =
            await permission.request().then((status) => status.isGranted);
        if (!hasPermission) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Permission error'),
                content: const Text(
                    'The app cannot function without the requested permission.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      // First one closes the AlertDialog
                      Navigator.of(context).pop();
                      // Second closes the app
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
        return hasPermission;
      }
    }
  }
  return false;
}
