import 'package:flutter_native/global.dart';
import 'package:flutter_native/ml_store/ml_models.dart';
import 'package:flutter_native/ml_store/ml_model_class.dart';
import 'package:flutter_native/neuron.dart';
import 'package:flutter_native/download_progress.dart';

part 'model_upload.dart';
part 'picture_upload.dart';
part 'picture_render.dart';
part 'output_render.dart';

class ModelPlayground extends StatefulWidget {
  final String icon;
  final String tag;
  final String playground;

  const ModelPlayground(
      {super.key,
      required this.icon,
      this.tag = "classification",
      this.playground = "General playground"});

  @override
  State<ModelPlayground> createState() => _ModelPlaygroundState();
}

class _ModelPlaygroundState extends State<ModelPlayground> {
  XFile? pickedImage;
  MLModel? playgroundModel;
  late List<MLModel> models;
  dynamic resultPredictions;

  @override
  void initState() {
    super.initState();
    models = mlModels;
  }

  void setImagePicked(XFile? image) {
    setState(() {
      pickedImage = image;
    });
  }

  void setPlaygroundModel(MLModel model) {
    setState(() {
      playgroundModel = model;
    });
  }

  void setPredictions(var modelPredictions) {
    setState(() {
      resultPredictions = modelPredictions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  widget.playground,
                  style: const TextStyle(fontSize: 22.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  children: [
                    PictureUpload(
                      widget: widget,
                      setImagePicked: (x) => setImagePicked(x),
                    ),
                    ModelUpload(
                      tag: widget.tag,
                      setPlaygroundModel: (x) => setPlaygroundModel(x),
                    ),
                    PictureRender(
                      pickedImage: pickedImage,
                      model: playgroundModel,
                      setPredictions: (x) => setPredictions(x),
                    ),
                    OutputRender(
                      resultPredictions: resultPredictions,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    ));
  }
}
