import 'package:flutter_native/global.dart';

final dio = Dio();

void main() {
  runApp(const FileProgress());
}

class FileProgress extends StatelessWidget {
  const FileProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gallery Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  double progress = 0;
  

  Future<bool> saveVideo(String url, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          if (directory != null && await directory.exists()) {
            File file = File("${directory.path}/$fileName");

            final files = await Directory(directory.path).list().toList();
            files.forEach((f) {
              print("==> ${f.path}");
            });

            bool fileExists = await file.exists();
            if (fileExists) {
              print(
                  "FILE ALREADY EXISTS: ${file.lengthSync() ~/ pow(1024, 2)} MB");
              bool completeFile = await isFullyDownloaded(file, url);
              if (completeFile) {
                return true;
              } else {
                return false;
              }
            } else {
              print("STARTING DOWNLOAD...");
              await dio.download(url, file.path,
                  onReceiveProgress: (value1, value2) {
                setState(() {
                  progress = value1 / value2;
                });
              });
            }
          } else {
            print("DIRECTORY NOT EXISTING");
          }

          // directory = Directory(newPath);
        } else {
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> isFullyDownloaded(File file, String url) async {
    if (!await file.exists()) {
      return false;
    }

    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var expectedSize = response.contentLength;
    print(
        "FILE: ${await file.length() / pow(1024, 2)} EXPECTED: ${expectedSize / pow(1024, 2)}");
    return file.lengthSync() == expectedSize;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<List<Map<String, String>>> fetchFiles() async {
    Directory? directory;
    List<FileSystemEntity> files = [];
    List<Map<String, String>> fileDataList = [];
    directory = await getExternalStorageDirectory();
    if (directory != null && await directory.exists()) {
      files = await Directory(directory.path).list().toList();
      for (var file in files) {
        String fileName = basename(file.path);
        int fileSize = await File(file.path).length();
        fileDataList.add({
          "name": fileName,
          "size": "${(fileSize / pow(1024, 2)).toStringAsFixed(3)}MB"
        });
      }
    }
    return fileDataList;
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });

    // saveVideo will download and save file to Device and will return a boolean
    // for if the file is successfully or not
    bool downloaded = await saveVideo(
        "https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5m6.pt",
        "yolov5m6.pt");
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }

    setState(() {
      loading = false;
      futureFiles = fetchFiles();
    });
  }

  late Future<List<Map<String, String>>> futureFiles;

  @override
  void initState() {
    super.initState();
    futureFiles = fetchFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              loading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: LinearProgressIndicator(
                                minHeight: 10,
                                value: progress,
                              ),
                            ),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%...",
                            style: const TextStyle(
                                fontSize: 20.0, fontFamily: "IBMPlexMono"),
                          )
                        ],
                      ),
                    )
                  : TextButton.icon(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                      ),
                      onPressed: downloadFile,
                      label: const Text(
                        "Download Video",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
              Expanded(
                child: FutureBuilder(
                    future: futureFiles,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print("LENGTH: ${snapshot.data!.length}");
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                                border: Border.all(
                                    width: 1.0, color: const Color(0xFFF3F4F6)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8.0,
                                    spreadRadius: 1.0,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "FILE: ${snapshot.data![index]['name']}",
                                    style: const TextStyle(
                                        fontFamily: 'SourceSansPro',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  ),
                                  Text(
                                    "${snapshot.data![index]['size']}",
                                    style: const TextStyle(
                                        fontFamily: 'IBMPlexMono',
                                        fontSize: 20.0),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
