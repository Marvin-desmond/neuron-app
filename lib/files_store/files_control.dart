import 'package:flutter_native/global.dart';

final dio = Dio();
final cancelToken = CancelToken();

Future<String> getStoragePath() async {
  Directory? storageDirectory = await getExternalStorageDirectory();
  return storageDirectory!.path;
}

Future<List<Map<String, String>>> getFiles(String storagePath) async {
  List<Map<String, String>> finalFiles = [];
  List<FileSystemEntity> preprocessedFiles =
      await Directory(storagePath).list().toList();
  for (var file in preprocessedFiles) {
    String name = basename(file.path);
    int size = await File(file.path).length();
    finalFiles.add({
      "file": name,
      "size": "${(size / pow(1024, 2)).toStringAsFixed(2)}MB"
    });
  }
  return finalFiles;
}

Future<File> getFileFromName(String name) async {
  var storagePath = await getStoragePath();
  File file = File("$storagePath/$name");
  return file;
}

Future<bool> checkFileComplete(File file, String url) async {
  var expectedSize = await getFileSizeInRemote(url);
  var foundFileSize = file.lengthSync();
  return foundFileSize >= expectedSize;
}

Future<bool> checkFileInLocal(File file, String? url) async {
  bool exists = await file.exists();
  if (exists && url != null) {
    bool fileComplete = await checkFileComplete(file, url);
    if (fileComplete) {
      return true;
    } else {
      await file.delete();
      return false;
    }
  } else {
    return false;
  }
}

Future<bool> checkInternetConnection() async {
  bool result = await InternetConnectionChecker().hasConnection;
  return result;
}

Future<bool> checkFileInLocalOffline(File file) async {
  bool exists = await file.exists();
  return exists;
}

Future<int> getFileSizeInLocal(String name) async {
  String? storagePath = await getStoragePath();
  File file = File("$storagePath/$name");
  return file.lengthSync();
}

Future<void> deleteFileInLocal(String name) async {
  String? storagePath = await getStoragePath();
  File file = File("$storagePath/$name");
  await file.delete();
}

Future<int> getFileSizeInRemote(String url) async {
  var httpClient = HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  var expectedSize = response.contentLength;
  return expectedSize;
}

String getSizeInMB(int size) {
  double megaBytes = size / pow(1024, 2);
  String megaBytesPrecision = megaBytes.toStringAsFixed(3);
  return "${megaBytesPrecision}MB";
}

void getFileDownload(
    File file, String url, Function(int, int, double) progressCallback) {
  int totalBytes = 0;
  int receivedBytes = 0;

  dio.download(url, file.path, onReceiveProgress: (received, total) {
    if (total != -1) {
      if (totalBytes == 0) {
        totalBytes = total;
      }
      receivedBytes = received;
      final progress = received / total;
      progressCallback(receivedBytes, totalBytes, progress);
    }
  }, cancelToken: cancelToken);
}

Future<RemoteFileResultMessage> getRemoteFile(String name, String url) async {
  String? storagePath;
  RemoteFileResultMessage result =
      RemoteFileResultMessage(message: "Initialising", download: false);
  try {
    // Ensure permission is allowed first in preceeding function
    storagePath = await getStoragePath();
    File file = File("$storagePath/$name");
    bool exists = await checkFileInLocal(file, url);
    if (exists) {
      int fileSize = await file.length();
      result.message =
          "File already exists: ${(fileSize / pow(1024, 2)).toStringAsFixed(3)}MB";
      result.download = false;
    } else {
      result.message = "$name starting downloading...";
      result.download = true;
    }
  } catch (e) {
    result.message = "Error: $e";
    result.download = false;
  }
  return result;
}

class RemoteFileResultMessage {
  String message;
  bool download;
  RemoteFileResultMessage({required this.message, required this.download});
}
