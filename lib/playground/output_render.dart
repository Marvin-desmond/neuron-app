part of 'model_playground.dart';

class OutputRender extends StatefulWidget {
  final dynamic resultPredictions;
  const OutputRender({super.key, this.resultPredictions});

  @override
  State<OutputRender> createState() => _OutputRenderState();
}

class _OutputRenderState extends State<OutputRender> {
  List<String> outputs = [
    "ostrich, Struthio camelus",
    "bustard",
    "zebra",
    "Border collie",
    "African elephant, Loxodonta africana"
  ];
  Map<int, double> processedPredictions = {};
  double totalSumOfPredictions = 0;

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
        processedPredictions =
            PostProcessor.postTagProcessor(listPredictions, imagenet, tag);
        double totalSum = 0;
        processedPredictions.forEach((key, value) {
          totalSum += value;
        });
        totalSumOfPredictions = totalSum;
      });
    }
  }

  @override
  void didUpdateWidget(OutputRender oldWidget) {
    super.didUpdateWidget(oldWidget);
    getProcessedPredictions();
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
      child: processedPredictions.isNotEmpty
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...List<Widget>.generate(
                processedPredictions.length,
                (i) => Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 6.0,
                              width: (processedPredictions.values.toList()[i] *
                                  MediaQuery.of(context).size.width /
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                            Text(
                              ImageNet.classes[
                                  processedPredictions.keys.toList()[i]],
                              style: const TextStyle(fontFamily: "IBMPlexMono"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "${processedPredictions.values.toList()[i].toStringAsFixed(2)}%",
                      style: const TextStyle(fontFamily: 'IBMPlexMono'),
                    )
                  ],
                ),
              )
            ])
          : const Text("No predictions"),
    );
  }
}
