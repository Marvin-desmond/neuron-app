import 'ml_model_class.dart';

List<MLModel> mlModels = [
  MLModel(
      "mobilenet-v3l.tflite",
      "https://tfhub.dev/google/lite-model/imagenet/mobilenet_v3_large_100_224/classification/5/default/1?lite-format=tflite",
      "classification",
      FrameWork.tensorflow,
      "imagenet"),
  MLModel(
      "mobilenet-v3s.tflite",
      "https://tfhub.dev/google/lite-model/imagenet/mobilenet_v3_small_100_224/classification/5/default/1?lite-format=tflite",
      "classification",
      FrameWork.tensorflow,
      "imagenet"),
  MLModel(
      "model.pt",
      "https://drive.google.com/uc?id=19ab020RNdy5j9_g6CJJ0Nt5c3GVASkw6",
      "classification",
      FrameWork.pytorch,
      "imagenet",
      Preprocessing(permute: true, normalization: true)),
  MLModel(
      "multi-axis-vit.pt",
      "https://github.com/Marvin-desmond/neuron-models-tests/releases/download/v1.0.0/multiaxis-vision-transformer.ptl",
      "classification",
      FrameWork.pytorch,
      "imagenet",
      Preprocessing(permute: true, normalization: true)),
  MLModel(
      "yolov5s-script.pt",
      "https://pytorch-mobile-demo-apps.s3.us-east-2.amazonaws.com/yolov5s.torchscript.ptl",
      "detection",
      FrameWork.pytorch,
      "coco",
      Preprocessing(inferenceSize: 640, permute: true)),
  MLModel(
      "yolo-5m-tf.tflite",
      "https://github.com/Marvin-desmond/neuron-models-tests/releases/download/v1.0.0/yolov5m-fp16.tflite",
      "detection",
      FrameWork.tensorflow,
      "coco",
      Preprocessing(inferenceSize: 640, permute: true)),
];
