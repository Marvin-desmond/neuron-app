import 'package:flutter_native/global.dart';
import 'package:flutter_native/ml_store/ml_model_class.dart';
import 'package:flutter_native/ml_store/ml_models.dart';
import 'package:flutter_native/download_progress.dart';

class ModelCatalog extends StatelessWidget {
  const ModelCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(15.0),
          decoration: const BoxDecoration(
            color: Color(0XFFFAFDFE),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 20),
                  child: Text(
                    "Model Catalog",
                    style:
                        TextStyle(fontSize: 35.0, fontFamily: 'SourceSansPro'),
                  ),
                ),
                ModelsInfoHeader(),
                ModelsInfoCatalog(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.skip_previous),
        ),
      ),
    );
  }
}

class ModelsInfoHeader extends StatelessWidget {
  const ModelsInfoHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 20.0),
        width: MediaQuery.of(context).size.width,
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
              // width: MediaQuery.of(context).size.width * 0.7,
              width: MediaQuery.of(context).size.width * 1.0,
              child: const Text(
                "This section shows the info of the models currently in this playground",
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'SourceSansPro'),
              )),
        ));
  }
}

class ModelsInfoCatalog extends StatefulWidget {
  const ModelsInfoCatalog({
    Key? key,
  }) : super(key: key);

  @override
  State<ModelsInfoCatalog> createState() => _ModelsInfoCatalogState();
}

class _ModelsInfoCatalogState extends State<ModelsInfoCatalog> {
  final List<MLModel> modelsInfoCatalog = mlModels;
  bool _mounted = true;

  String? activeModel;

  @override
  void initState() {
    super.initState();
    fetchData().catchError((e) {
      print("STACK ERROR: $e");
    });
  }

  Future<void> fetchData() async {
    for (var i = 0; i < modelsInfoCatalog.length; i++) {
      var name = modelsInfoCatalog[i].name;
      var url = modelsInfoCatalog[i].url;

      try {
        await getFileSizeInRemote(url).then((size) {
          if (!_mounted) {
            return;
          } else {
            setState(() {
              modelsInfoCatalog[i].size = getSizeInMB(size);
            });
          }
        });
        await getFileFromName(name).then((file) {
          checkFileInLocal(file, url).then((downloaded) {
            if (!_mounted) {
              return;
            } else {
              setState(() {
                modelsInfoCatalog[i].downloaded = downloaded;
              });
              print("$name $downloaded");
            }
          });
        });
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  void closeProgress() {
    setState(() {
      activeModel = null;
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var mlModel in mlModels)
          Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(width: 1.0, color: const Color(0xFFF3F4F6)),
                color: const Color(0xFFFEFEFE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 1.0,
                    spreadRadius: 1.0,
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mlModel.name,
                            style: const TextStyle(
                                fontSize: 17.0,
                                fontFamily: 'SourceSansPro',
                                fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Image.asset(
                                "assets/core/${mlModel.framework.name}.png",
                                height: 25.0,
                                width: 25.0),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            mlModel.size ?? "0.00MB",
                            style: const TextStyle(
                                fontFamily: "IBMPlexMono", fontSize: 16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                mlModel.downloaded
                                    ? IconButton(
                                        hoverColor: Colors.grey[100],
                                        focusColor: Colors.grey[100],
                                        onPressed: () => showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  Theme(
                                                data: ThemeData(
                                                    colorSchemeSeed:
                                                        const Color(0xff6750a4),
                                                    useMaterial3: true),
                                                child: AlertDialog(
                                                  title: Row(
                                                    children: [
                                                      Image.asset(
                                                          "assets/core/${mlModel.framework.name}.png",
                                                          width: 25.0,
                                                          height: 25.0),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        mlModel.name,
                                                        style: const TextStyle(
                                                            fontSize: 18.0,
                                                            fontFamily:
                                                                'SourceSansPro',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Text(
                                                      'Confirm deleting ${mlModel.name}?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context,
                                                              'Cancel'),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context, 'OK');
                                                        deleteFileInLocal(
                                                                mlModel.name)
                                                            .then((_) {
                                                          fetchData()
                                                              .catchError((e) {
                                                            print(
                                                                "STACK ERROR: $e");
                                                          });
                                                        });
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey[700],
                                        ))
                                    : IconButton(
                                        hoverColor: Colors.grey[100],
                                        focusColor: Colors.grey[100],
                                        icon: Icon(Icons.download,
                                            color: Colors.grey[700]),
                                        tooltip: 'Download',
                                        onPressed: () => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              Theme(
                                            data: ThemeData(
                                                colorSchemeSeed:
                                                    const Color(0xff6750a4),
                                                useMaterial3: true),
                                            child: AlertDialog(
                                              title: Row(
                                                children: [
                                                  Image.asset(
                                                      "assets/core/${mlModel.framework.name}.png",
                                                      width: 25.0,
                                                      height: 25.0),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    mlModel.name,
                                                    style: const TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            'SourceSansPro',
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ],
                                              ),
                                              content: Text(
                                                  'Do you want to download ${mlModel.name} (${mlModel.size}) for ${mlModel.tag} tasks?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'Cancel'),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      activeModel =
                                                          mlModel.name;
                                                    });
                                                    Navigator.pop(
                                                        context, 'OK');
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  mlModel.name == activeModel
                      ? DownloadProgress(
                          name: mlModel.name,
                          url: mlModel.url,
                          updateData: () async => await fetchData(),
                          closeProgress: () => closeProgress(),)
                      : const SizedBox.shrink(),
                ],
              ))
      ],
    );
  }
}
