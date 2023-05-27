import 'ml_model_class.dart';

List<MLModel> mlModels = [
  MLModel(
      "mobilenet-v3l",
      "https://tfhub.dev/google/lite-model/imagenet/mobilenet_v3_large_100_224/classification/5/default/1?lite-format=tflite",
      "classification",
      FrameWork.tensorflow,
      "imagenet"),
  MLModel(
      "mobilenet-v3s",
      "https://tfhub.dev/google/lite-model/imagenet/mobilenet_v3_small_100_224/classification/5/default/1?lite-format=tflite",
      "classification",
      FrameWork.tensorflow,
      "imagenet"),
  MLModel(
      "mobilenet-v3-pt",
      "https://drive.google.com/uc?id=1e-8U2iqi7paoWQrfLe4uCWWmOQtTB3-4",
      "classification",
      FrameWork.pytorch,
      "imagenet"),
  MLModel(
      "multi-axis-vit",
      "https://drive.google.com/uc?id=1i7l5G5-peQz5oL36dPbiXOwYwPwyfyqV",
      "classification",
      FrameWork.pytorch,
      "imagenet",
      Preprocessing(permute: true, normalization: true)),
  MLModel(
      "u-yolo-m",
      "https://drive.google.com/uc?id=1WHIBEedYMnSNeXOxqvE3dO2L45EWsKA-",
      "detection",
      FrameWork.pytorch,
      "coco",
      Preprocessing(inferenceSize: 640, permute: true)),
  MLModel(
      "u-yolo-m-tflite",
      "https://drive.google.com/uc?id=1R8lXLjNOP7BJV47A0tiPENXjjWrH7wxA",
      "detection",
      FrameWork.tensorflow,
      "coco",
      Preprocessing(inferenceSize: 640, permute: true)),
];
