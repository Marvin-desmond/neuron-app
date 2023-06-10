part of 'model_playground.dart';

class PictureRender extends StatefulWidget {
  final XFile? pickedImage;
  final MLModel? model;
  final Function(dynamic) setPredictions;
  const PictureRender(
      {super.key, this.pickedImage, this.model, required this.setPredictions});

  @override
  State<PictureRender> createState() => _PictureRenderState();
}

class _PictureRenderState extends State<PictureRender> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            border: Border.all(width: 1.0, color: const Color(0xFFF3F4F6)),
            color: const Color(0xFFFEFEFE),
          ),
          child: widget.pickedImage != null
              ? Image.file(
                  File(widget.pickedImage!.path),
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      const Center(
                          child: Text('This image type is not supported')),
                )
              : Image.asset(
                  "assets/core/default_picture_render.jpeg",
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
        ),
        Positioned(
            bottom: 20.0,
            right: 20.0,
            child: ClipOval(
              child: Material(
                color: Colors.blue,
                child: InkWell(
                  splashColor: Colors.blue[200],
                  onTap: () async {
                    try {
                      if (widget.pickedImage != null) {
                        if (widget.model != null) {
                          var res = await Neuron.getPredictions(
                              widget.pickedImage!,
                              widget.model!.preprocessing,
                              widget.model!.tag,
                              imagenet: false);
                          widget.setPredictions(res);
                        } else {
                          print("Model not selected");
                        }
                      } else {
                        print("Image not picked!");
                      }
                    } catch (e) {
                      print("Error in predictions!");
                    }
                  },
                  child: const SizedBox(
                      width: 53,
                      height: 53,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      )),
                ),
              ),
            )),
      ],
    );
  }
}
