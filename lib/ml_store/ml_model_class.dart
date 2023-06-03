enum FrameWork { tensorflow, pytorch }

class Preprocessing {
  int inferenceSize;
  bool scaling;
  bool permute;
  bool normalization;
  List<double> normMean;
  List<double> normStd;
  Preprocessing(
      {this.inferenceSize = 224,
      this.scaling = true,
      this.permute = false,
      this.normalization = false,
      this.normMean = const [0.485, 0.456, 0.406],
      this.normStd = const [0.229, 0.224, 0.225]});

  Map<String, dynamic> toJson() {
    return {
      'inferenceSize': inferenceSize,
      'scaling': scaling,
      'permute': permute,
      'normalization': normalization,
      'normMean': normMean,
      'normStd': normStd,
    };
  }
}

class MLModel {
  final String name;
  final String url;
  final String tag;
  final FrameWork framework;
  Preprocessing preprocessing;
  String? size;
  bool downloaded = false;
  String labels;
  MLModel(this.name, this.url, this.tag, this.framework, this.labels,
      [Preprocessing? preprocessing])
      : preprocessing = preprocessing ?? Preprocessing();

  @override
  String toString() => "$name : $size";
}
