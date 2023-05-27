import 'package:flutter_native/global.dart';
import 'package:flutter_native/ml_store/ml_models.dart';
import 'package:flutter_native/ml_store/ml_model_class.dart';

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
                    PictureUpload(widget: widget),
                    ModelUpload(tag: widget.tag),
                    const PictureRender(),
                    const OutputRender()
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
