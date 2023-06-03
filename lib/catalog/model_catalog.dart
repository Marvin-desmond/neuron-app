import 'package:flutter_native/global.dart';
import 'package:flutter_native/ml_store/ml_model_class.dart';
import 'package:flutter_native/ml_store/ml_models.dart';
import 'package:flutter_native/download_progress.dart';
import 'package:flutter_native/neuron.dart';

part 'model_info.dart';

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
            }
          });
        });
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  void setActiveModel(String active) {
    setState(() {
      activeModel = active;
    });
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
          ModelInfo(
            mlModel: mlModel,
            activeModel: activeModel,
            setActiveModel: (x) => setActiveModel(x),
            updateData: () async => await fetchData(),
            closeProgress: () => closeProgress(),
          )
      ],
    );
  }
}
