part of 'model_playground.dart';

class ModelUpload extends StatefulWidget {
  const ModelUpload({
    Key? key,
    this.tag = "classification",
  }) : super(key: key);
  final String tag;

  @override
  State<ModelUpload> createState() => _ModelUploadState();
}

class _ModelUploadState extends State<ModelUpload> {
  ValueNotifier<FrameWork?> frameWork =
      ValueNotifier<FrameWork>(FrameWork.tensorflow);
  List<MLModel> cardModels = [];
  List<MLModel> frameworkModels = [];

  @override
  void initState() {
    super.initState();
    cardModels = mlModels.where((e) => e.tag == widget.tag).toList();
    frameworkModels = getFrameworkModels(frameWork.value!);
    frameWork.addListener(() {
      frameworkModels = getFrameworkModels(frameWork.value!);
    });
  }

  List<MLModel> getFrameworkModels(FrameWork current) {
    var filteredModels =
        cardModels.where((i) => i.framework == frameWork.value).toList();
    return filteredModels;
  }

  @override
  void dispose() {
    frameWork.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: frameWork,
        builder: (BuildContext context, FrameWork? value, Widget? child) {
          return Container(
            margin: const EdgeInsets.only(top: 15.0),
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                color: Colors.white),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Framework',
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic),
                ),
              ),
              Row(
                children: <Widget>[
                  //   children: frameworkModels
                  //       .map<Widget>((model) => Text(model.name))
                  //       .toList(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        frameWork.value = FrameWork.tensorflow;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 15.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(
                            width: 1.0, color: const Color(0xFFF3F4F6)),
                        color: const Color(0xFFFEFEFE),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Radio<FrameWork>(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: FrameWork.tensorflow,
                            groupValue: frameWork.value,
                            onChanged: (FrameWork? value) {
                              setState(() {
                                frameWork.value = value;
                              });
                            },
                          ),
                          const Text('tensorflow'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        frameWork.value = FrameWork.pytorch;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(right: 15.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(
                            width: 1.0, color: const Color(0xFFF3F4F6)),
                        color: const Color(0xFFFEFEFE),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Radio<FrameWork>(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: FrameWork.pytorch,
                            groupValue: frameWork.value,
                            onChanged: (FrameWork? value) {
                              setState(() {
                                frameWork.value = value;
                              });
                            },
                          ),
                          const Text('PyTorch'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 15.0, bottom: 5.0, right: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    frameworkModels.isNotEmpty
                        ? DropdownModels(modelOptions: frameworkModels)
                        : const SizedBox.shrink(),
                    TextButton.icon(
                        onPressed: () => {
                              // context.go("/model_catalog")
                              GoRouter.of(context)
                                  .pushNamed(ScreenPaths.modelCatalog)
                            },
                        icon: Image.asset(
                          "assets/core/logo.png",
                          height: 30.0,
                          width: 30.0,
                        ),
                        label: const Text(
                          "Catalog",
                          style: TextStyle(color: Colors.deepPurple),
                        ))
                  ],
                ),
              ),
            ]),
          );
        });
  }
}

class DropdownModels extends StatefulWidget {
  final List<MLModel> modelOptions;
  const DropdownModels({super.key, this.modelOptions = const []});

  @override
  State<DropdownModels> createState() => _DropdownModelsState();
}

class _DropdownModelsState extends State<DropdownModels> {
  MLModel? currentModel;

  @override
  void initState() {
    super.initState();
    if (widget.modelOptions.isNotEmpty) {
      currentModel = widget.modelOptions[0];
    }
  }

  @override
  void didUpdateWidget(DropdownModels oldWidget) {
    super.didUpdateWidget(oldWidget);
      if (!widget.modelOptions.contains(currentModel)) {
        if (widget.modelOptions.isNotEmpty) {
          currentModel = widget.modelOptions[0];
        } else {
          currentModel = null;
        }
      }

  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<MLModel>(
      value: currentModel,
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        child: Image.asset("assets/core/${currentModel!.framework.name}.png",
            width: 25.0, height: 25.0),
      ),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple, fontSize: 18.0),
      underline: Container(
        height: 1,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (MLModel? value) {
        getRemoteFile(value!.name, value.url).then((result) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final snackBar = SnackBar(
            content: Text(result.message),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
        setState(() {
          currentModel = value;
        });
      },
      items:
          widget.modelOptions.map<DropdownMenuItem<MLModel>>((MLModel option) {
        return DropdownMenuItem<MLModel>(
          value: option,
          child: Text(option.name),
        );
      }).toList(),
    );
  }
}
