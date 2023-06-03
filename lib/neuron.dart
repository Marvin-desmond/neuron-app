import 'package:flutter_native/global.dart';
import 'package:flutter_native/ml_store/ml_model_class.dart';
import 'package:image/image.dart' as imgr;
import 'dart:ui' as ui;

class Neuron {
  static const machineLearningChannel =
      MethodChannel('samples.neuron.face/tools');
  dynamic neuronInterpreter;
  String? neuronFramework;

  static Future<dynamic> fromAsset(String asset, String framework) async {
    dynamic result;
    print("INPUT ASSET: $asset FRAMEWORK: $framework");
    var arguments = {"asset": asset, "framework": framework};
    try {
      result = await machineLearningChannel.invokeMethod(
          'getInterpreterFromAsset', arguments);
      String data = result["data"];
      int status = result["status"];
      // var module = json.decode(result["module"]);
      print("RESULT: $data ==> $status");
    } catch (e) {
      throw "FROM ASSET METHOD INVOKE ERROR: $e";
    }
    return result;
  }

  static Future<dynamic> preProcess(
      Uint8List bitmap, Preprocessing preprocessors) async {
    var jsonPreprocessors = preprocessors.toJson();
    var arguments = {
      "bitmap": bitmap,
      "framework": "tensorflow",
      "preprocessors": jsonPreprocessors
    };
    var preprocessedImage = await machineLearningChannel.invokeMethod(
        "getPreprocessing", arguments);
    return preprocessedImage;
  }

  static Future<dynamic> getPredictions(
      XFile image, Preprocessing preprocessors, String tag,
      {bool imagenet = false}) async {
    try {
      Map<String, Object> metaData = await imageToBitmap(image);
      if (!metaData.containsKey("bytes")) {
        throw "Error getting image metadata";
      }
      Uint8List? bytes = metaData["bytes"] as Uint8List;
      int height = metaData["height"] as int;
      int width = metaData["width"] as int;
      var jsonPreprocessors = preprocessors.toJson();
      var arguments = {
        "bytes": bytes,
        "height": height,
        "width": width,
        "preprocessors": jsonPreprocessors,
        "tag": tag,
        "imagenet": imagenet
      };
      var result = await machineLearningChannel.invokeMethod(
          "getPredictions", arguments);
      var predictions = json.decode(result["predictions"]);
      return result;
    } catch (e) {
      print("GET PREDICTIONS: $e");
    }
  }

  static Future<Map<String, Object>> imageToBitmap(XFile pickedImage) async {
    Map<String, Object> response = {};
    final path = pickedImage.path;
    final bytes = await File(path).readAsBytes();
    final imgr.Image? image = imgr.decodeImage(bytes);
    if (image != null) {
      int height = image.height;
      int width = image.width;
      final bytes = image.getBytes();
      response['height'] = height;
      response['width'] = width;
      response['bytes'] = bytes;
    }
    return response;
  }
}
