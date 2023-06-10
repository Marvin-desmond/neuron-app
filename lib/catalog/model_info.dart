part of 'model_catalog.dart';

class ModelInfo extends StatefulWidget {
  const ModelInfo(
      {super.key,
      required this.mlModel,
      this.activeModel,
      required this.setActiveModel,
      required this.updateData,
      required this.closeProgress});
  final MLModel mlModel;
  final String? activeModel;
  final Function(String) setActiveModel;
  final Function() updateData;
  final Function() closeProgress;

  @override
  State<ModelInfo> createState() => _ModelInfoState();
}

class _ModelInfoState extends State<ModelInfo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      widget.mlModel.name,
                      style: const TextStyle(
                          fontSize: 17.0,
                          fontFamily: 'SourceSansPro',
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Image.asset(
                          "assets/core/${widget.mlModel.framework.name}.png",
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
                      widget.mlModel.size ?? "0.00MB",
                      style: const TextStyle(
                          fontFamily: "IBMPlexMono", fontSize: 16.0),
                    ),
                    widget.mlModel.downloaded
                        ? IconButton(
                            hoverColor: Colors.grey[100],
                            focusColor: Colors.grey[100],
                            onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => Theme(
                                    data: ThemeData(
                                        colorSchemeSeed:
                                            const Color(0xff6750a4),
                                        useMaterial3: true),
                                    child: AlertDialog(
                                      title: Row(
                                        children: [
                                          Image.asset(
                                              "assets/core/${widget.mlModel.framework.name}.png",
                                              width: 25.0,
                                              height: 25.0),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            widget.mlModel.name,
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: 'SourceSansPro',
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                          'Confirm deleting ${widget.mlModel.name}?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'OK');
                                            deleteFileInLocal(
                                                    widget.mlModel.name)
                                                .then((_) {
                                              widget
                                                  .updateData()
                                                  .catchError((e) {
                                                print("STACK ERROR: $e");
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
                            icon: Icon(Icons.download, color: Colors.grey[700]),
                            tooltip: 'Download',
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => Theme(
                                data: ThemeData(
                                    colorSchemeSeed: const Color(0xff6750a4),
                                    useMaterial3: true),
                                child: AlertDialog(
                                  title: Row(
                                    children: [
                                      Image.asset(
                                          "assets/core/${widget.mlModel.framework.name}.png",
                                          width: 25.0,
                                          height: 25.0),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        widget.mlModel.name,
                                        style: const TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'SourceSansPro',
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                      'Do you want to download ${widget.mlModel.name} (${widget.mlModel.size}) for ${widget.mlModel.tag} tasks?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        widget.setActiveModel(
                                            widget.mlModel.name);
                                        Navigator.pop(context, 'OK');
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                  ],
                )
              ],
            ),
            widget.mlModel.name == widget.activeModel
                ? DownloadProgress(
                    name: widget.mlModel.name,
                    url: widget.mlModel.url,
                    updateData: () async => await widget.updateData(),
                    closeProgress: () => widget.closeProgress(),
                  )
                : const SizedBox.shrink(),
          ],
        ));
  }
}
