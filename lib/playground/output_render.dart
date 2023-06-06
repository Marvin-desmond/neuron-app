part of 'model_playground.dart';

class OutputRender extends StatefulWidget {
  final dynamic resultPredictions;
  final XFile? image;
  final String tag;
  const OutputRender(
      {super.key, this.resultPredictions, this.image, required this.tag});

  @override
  State<OutputRender> createState() => _OutputRenderState();
}

class _OutputRenderState extends State<OutputRender> {
  final imageKey = GlobalKey();

  Map<int, double> processedPredictions = {};
  double totalSumOfPredictions = 0;
  List<Detection>? processedDetections;
  List<Detection>? processedNextDetections;

  @override
  void initState() {
    super.initState();
  }

  void getProcessedPredictions() {
    if (widget.resultPredictions != null) {
      var listPredictions = widget.resultPredictions["predictions"];
      bool imagenet = widget.resultPredictions["imagenet"];
      String tag = widget.resultPredictions["tag"];
      setState(() {
        if (tag == "classification") {
          processedPredictions =
              PostProcessor.postTagProcessor(listPredictions, imagenet, tag);
          double totalSum = 0;
          processedPredictions.forEach((key, value) {
            totalSum += value;
          });
          totalSumOfPredictions = totalSum;
        } else if (tag == "detection") {
          Iterable mapPreds = jsonDecode(listPredictions);
          processedDetections = List<Detection>.from(
              mapPreds.map((pred) => Detection.fromJson(pred)));
        }
      });
    }
  }

  @override
  void didUpdateWidget(OutputRender oldWidget) {
    super.didUpdateWidget(oldWidget);
    getProcessedPredictions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          imageKey.currentContext?.findRenderObject() as RenderBox?;
      final imageSize = renderBox?.size;

      if (widget.image != null && processedDetections != null) {
        final bytes = File(widget.image!.path).readAsBytesSync();
        final imgr.Image? image = imgr.decodeImage(bytes);
        if (image != null && imageSize != null) {
          int initialHeight = image.height;
          int initialWidth = image.width;
          double finalHeight = imageSize.height;
          double finalWidth = imageSize.width;
          double hR = finalHeight / initialHeight;
          double wR = finalWidth / initialWidth;
          print(processedDetections
              ?.toList()
              .map((e) => '${e.top} ${e.left} ${e.bottom} ${e.right}'));
          List<Detection> updatedDetections = [];
          for (var detection in processedDetections!) {
            detection.top = max(detection.top * hR, 0).toInt();
            detection.left = max(detection.left * wR, 0).toInt();
            detection.bottom = min(detection.bottom * hR, finalHeight).toInt();
            detection.right = min(detection.right * wR, finalWidth).toInt();
            updatedDetections.add(detection);
          }
          setState(() {
            processedNextDetections = updatedDetections;
          });
          print(processedDetections
              ?.toList()
              .map((e) => '${e.top} ${e.left} ${e.bottom} ${e.right}'));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 10.0),
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        border: Border.all(width: 1.0, color: const Color(0xFFF3F4F6)),
        color: const Color(0xFFFEFEFE),
      ),
      child: processedPredictions.isNotEmpty || processedDetections != null
          ? Column(
              children: [
                widget.tag == "classification"
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            ...List<Widget>.generate(
                              processedPredictions.length,
                              (i) => Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 5.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 6.0,
                                            width: (processedPredictions.values
                                                    .toList()[i] *
                                                MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                totalSumOfPredictions),
                                            decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment(0.8, 1),
                                                  colors: <Color>[
                                                    Color(0xffa88dfa),
                                                    Color(0xffc0adfc),
                                                    Color(0xffddd4fe),
                                                  ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                                  tileMode: TileMode.mirror,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          Text(
                                            ImageNet.classes[
                                                processedPredictions.keys
                                                    .toList()[i]],
                                            style: const TextStyle(
                                                fontFamily: "IBMPlexMono"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${processedPredictions.values.toList()[i].toStringAsFixed(2)}%",
                                    style: const TextStyle(
                                        fontFamily: 'IBMPlexMono'),
                                  )
                                ],
                              ),
                            )
                          ])
                    : const SizedBox.shrink(),
                widget.tag == "detection"
                    ? Column(
                        children: [
                          Stack(
                            children: [
                              processedNextDetections != null
                                  ? Stack(
                                      children: [
                                        Image.file(
                                          key: imageKey,
                                          File(widget.image!.path),
                                          errorBuilder: (BuildContext context,
                                                  Object error,
                                                  StackTrace? stackTrace) =>
                                              const Center(
                                                  child: Text(
                                                      'This image type is not supported')),
                                        ),
                                        CustomPaint(
                                          painter: BoundingBoxPainter(
                                              processedNextDetections!),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          // Text(widget.resultPredictions["predictions"]),
                          Text(processedNextDetections?.length.toString() ??
                              "Null"),
                          Text(processedNextDetections
                                  ?.toList()
                                  .map((e) =>
                                      '${e.top} ${e.left} ${e.bottom} ${e.right}')
                                  .toString() ??
                              "no next"),
                        ],
                      )
                    : const SizedBox.shrink(),
              ],
            )
          : const Text('No predictions'),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  List<Detection> boundingBoxes;

  BoundingBoxPainter(this.boundingBoxes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var boundingBox in boundingBoxes) {
      canvas.drawRect(boundingBox.getRect(), paint);
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) => true;
}
