package com.example.flutter_native;

import android.content.Context;
// BitMap image decoding
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
// Logging
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.gson.Gson;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
// Java IO for reading Model
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
// Get file buffer
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
// List handling
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// PyTorch
import org.pytorch.IValue;
import org.pytorch.LiteModuleLoader;
import org.pytorch.Module;
import org.pytorch.Tensor;
import org.pytorch.torchvision.TensorImageUtils;
import org.tensorflow.lite.DataType;
// TensorFlow
import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.support.common.ops.NormalizeOp;
import org.tensorflow.lite.support.image.ImageProcessor;
import org.tensorflow.lite.support.image.TensorImage;
import org.tensorflow.lite.support.image.ops.ResizeOp;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "samples.flutter.dev/battery";
  private static final String CHANNEL_ML = "samples.neuron.face/tools";
  private Object neuronModel;
  private Gson gson = new Gson();

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    new MethodChannel(
      flutterEngine.getDartExecutor().getBinaryMessenger(),
      CHANNEL_ML
    )
    .setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("getMachineVersion")) {
            try {
              String mVersion = getMachineVersion();
              String[] assetList = getAssets().list("");
              // root directory of getAssets is :app:android/src/main/assets
              // put your images in assets
              Bitmap bitmap = BitmapFactory.decodeStream(
                getAssets().open("input.jpeg")
              );
              long totalBytes = bitmap.getByteCount();
              int width = bitmap.getWidth();
              int height = bitmap.getHeight();
              Bitmap.Config config = bitmap.getConfig();
              /* */
              String myasset = getAssetPath(this, "yolov5m.torchscript.ptl");
              Module mymodule = LiteModuleLoader.load(myasset);
              ColoredLog("YOLO ==> " + mymodule);
              /* */
              String asset = getAssetPath(this, "model.pt");
              Module module = LiteModuleLoader.load(asset);

              Tensor inputTensor = TensorImageUtils.bitmapToFloat32Tensor(
                bitmap,
                TensorImageUtils.TORCHVISION_NORM_MEAN_RGB,
                TensorImageUtils.TORCHVISION_NORM_STD_RGB
              );
              Tensor outputTensor = module
                .forward(IValue.from(inputTensor))
                .toTensor();
              float[] scores = outputTensor.getDataAsFloatArray();
              List<Prediction> post_results = postProcessor(scores, 2);
              ColoredLog(
                " PyTorch ===> " +
                ImageNetClasses.IMAGENET_CLASSES[post_results.get(0).getIndex()]
              );
              String className =
                ImageNetClasses.IMAGENET_CLASSES[post_results
                    .get(0)
                    .getIndex()];

              File model = new File(
                assetFilePath(this, "classification_model.tflite")
              );
              try (Interpreter interpreter = new Interpreter(model)) {
                Interpreter.Options tfliteOptions = (new Interpreter.Options());
                ImageProcessor imageProcessor = new ImageProcessor.Builder()
                  .add(new ResizeOp(224, 224, ResizeOp.ResizeMethod.BILINEAR))
                  .add(new NormalizeOp(0, 255))
                  .build();
                int inputIndex = 0; // Adjust this based on your model's input index
                int outputIndex = 0; // Adjust this based on your model's output index
                int[] inputShape = interpreter
                  .getInputTensor(inputIndex)
                  .shape();
                int[] outputShape = interpreter
                  .getOutputTensor(outputIndex)
                  .shape();

                TensorImage tensorImage = new TensorImage(DataType.FLOAT32);
                tensorImage.load(bitmap);
                tensorImage = imageProcessor.process(tensorImage);
                TensorBuffer probabilityBuffer = TensorBuffer.createFixedSize(
                  outputShape,
                  DataType.FLOAT32
                );
                interpreter.run(
                  tensorImage.getBuffer(),
                  probabilityBuffer.getBuffer()
                );
                float[] results = probabilityBuffer.getFloatArray();
                List<Prediction> postResults = postProcessor(results, 5);
                ColoredLog(
                  "TensorFlow ====>" +
                  ImageNetClasses.IMAGENET_CLASSES[postResults
                      .get(0)
                      .getIndex()]
                );
              } catch (Exception e) {
                ColoredLog("ERROR: " + e);
              }

              result.success(mVersion + className);
            } catch (Exception e) {
              ColoredLog("ERROR: " + e);
              result.error("NULL", "Machine not found", null);
            }
          } else if (call.method.equals("getInterpreterFromAsset")) {
            try {
              String asset = call.argument("asset");
              String framework = call.argument("framework");
              String assetPath = getAssetPath(this, asset);
              if (framework.equals("pytorch")) {
                Module module = LiteModuleLoader.load(assetPath);
                neuronModel = module;
                Map<String, Object> response = new HashMap<>();
                // String jsonModule = gson.toJson(module); // DON'T UNCOMMENT, IT CRASHES THE APP
                response.put("data", "PYTORCH " + asset + "OK");
                response.put("status", 200);
                // response.put("module", jsonModule);
                result.success(response);
              } else if (framework.equals("tensorflow")) {
                File model = new File(assetPath);
                Interpreter interpreter = new Interpreter(model);
                neuronModel = interpreter;
                Map<String, Object> response = new HashMap<>();
                response.put("data", "TENSORFLOW " + asset + "OK");
                response.put("status", 200);
                result.success(response);
              } else {
                result.error("NULL", "Incorrect framework mode passed!", null);
              }
            } catch (Exception e) {
              ColoredLog("FROM ASSET ERROR: " + e);
              result.error("NULL", "Error encountered!", null);
            }
          } else if (call.method.equals("getPreprocessing")) {
            try {
              byte[] bytes = call.argument("bitmap");
              String framework = call.argument("framework");
              HashMap<String, Object> preprocessors = call.argument(
                "preprocessors"
              );

              Bitmap bitmap = Bitmap.createBitmap(
                500,
                500,
                Bitmap.Config.ARGB_8888
              );
              bitmap.copyPixelsFromBuffer(ByteBuffer.wrap(bytes));

              int width = bitmap.getWidth();
              int height = bitmap.getHeight();

              int inferenceSize = (Integer) preprocessors.get("inferenceSize");
              boolean scaling = (Boolean) preprocessors.get("scaling");
              boolean permute = (Boolean) preprocessors.get("permute");
              boolean normalization = (Boolean) preprocessors.get(
                "normalization"
              );
              List<Double> normMean = (List<Double>) preprocessors.get(
                "normMean"
              );
              List<Double> normStd = (List<Double>) preprocessors.get(
                "normStd"
              );
              float[] mean = listToFloat(normMean);
              float[] std = listToFloat(normStd);

              if (framework.equals("pytorch")) {} else if (
                framework.equals("tensorflow")
              ) {}
              result.success("Hello world");
            } catch (Exception e) {
              ColoredLog("PP ERROR: " + e);
              result.error("NULL", "Error encountered!", null);
            }
          } else if (call.method.equals("getPredictions")) {
            try {
              if (neuronModel == null) {
                result.error("NULL", "Model not set!", null);
              }
              byte[] bytes = call.argument("bytes");
              int height = call.argument("height");
              int width = call.argument("width");
              boolean imagenet = call.argument("imagenet");
              String tag = call.argument("tag");
              HashMap<String, Object> preprocessors = call.argument(
                "preprocessors"
              );
              int pixelCount = width * height;
              int[] pixels = new int[pixelCount];

              // Convert RGB image bytes to ARGB pixels
              for (int i = 0; i < pixelCount; i++) {
                int r = bytes[i * 3] & 0xFF; // Red channel
                int g = bytes[i * 3 + 1] & 0xFF; // Green channel
                int b = bytes[i * 3 + 2] & 0xFF; // Blue channel

                // Combine RGB channels and set alpha to fully opaque
                int argb = 0xFF << 24 | r << 16 | g << 8 | b;
                pixels[i] = argb;
              }

              // Create the Bitmap with ARGB_8888 configuration
              Bitmap bitmap = Bitmap.createBitmap(
                pixels,
                width,
                height,
                Bitmap.Config.ARGB_8888
              );
              int inferenceSize = (Integer) preprocessors.get("inferenceSize");
              boolean scaling = (Boolean) preprocessors.get("scaling");
              boolean permute = (Boolean) preprocessors.get("permute");
              boolean normalization = (Boolean) preprocessors.get(
                "normalization"
              );
              List<Double> normMean = (List<Double>) preprocessors.get(
                "normMean"
              );
              List<Double> normStd = (List<Double>) preprocessors.get(
                "normStd"
              );
              float[] mean = listToFloat(normMean);
              float[] std = listToFloat(normStd);

              Map<String, Object> predictions = new HashMap<>();

              if (neuronModel instanceof Module) {
                Tensor inputImage = getPreprocessedImageForPytorch(
                  bitmap,
                  inferenceSize
                );
                Module model = (Module) neuronModel;
                Tensor outputTensor = model
                  .forward(IValue.from(inputImage))
                  .toTensor();
                float[] scores = outputTensor.getDataAsFloatArray();
                if (imagenet == true) {
                  List<Prediction> postResults = postProcessor(scores, 5);
                  String jsonRes = gson.toJson(postResults);
                  predictions.put("predictions", jsonRes);
                } else {
                  String jsonRes = gson.toJson(scores);
                  predictions.put("predictions", jsonRes);
                }
                predictions.put("tag", tag);
                predictions.put("imagenet", imagenet);
                result.success(predictions);
              } else if (neuronModel instanceof Interpreter) {
                TensorImage inputImage = getPreprocessedImageForTensorFlow(
                  bitmap,
                  inferenceSize,
                  scaling,
                  permute,
                  normalization,
                  mean,
                  std
                );
                Interpreter model = (Interpreter) neuronModel;
                int outputIndex = 0;
                int[] outputShape = model.getOutputTensor(outputIndex).shape();
                TensorBuffer probabilityBuffer = TensorBuffer.createFixedSize(
                  outputShape,
                  DataType.FLOAT32
                );
                model.run(
                  inputImage.getBuffer(),
                  probabilityBuffer.getBuffer()
                );
                 float[] results = probabilityBuffer.getFloatArray();
                if (imagenet == true) {
                  List<Prediction> postResults = postProcessor(results, 5);
                  String jsonRes = gson.toJson(postResults);
                  predictions.put("predictions", jsonRes);
                } else if (tag == "detection"){
                  float[][][] preds = PreprocessorUtils.reconstructPredictions(results);
                  int[] shape = new int[]{preds.length, preds[0].length, preds[0][0].length};
                  ColoredLog("Reconstructed shape: " + Arrays.toString(shape));
                } else {
                  String jsonRes = gson.toJson(results);
                  predictions.put("predictions", jsonRes);
                }
                predictions.put("tag", tag);
                predictions.put("imagenet", imagenet);
                result.success(predictions);
              } else {
                result.error("NULL", "Model cannot be read!", null);
                ColoredLog(
                  "MODEL READ ERROR:" + neuronModel.getClass().getName()
                );
              }
            } catch (Exception e) {
              ColoredLog("PP ERROR: " + e);
              result.error("NULL", "Error encountered!", null);
            }
          } else if (call.method.equals("closeModel")) {
            if (neuronModel instanceof Module) {
              Module model = (Module) neuronModel;
              model.destroy();
            } else if (neuronModel instanceof Interpreter) {
              Interpreter model = (Interpreter) neuronModel;
              model.close();
            }
          } else {
            result.notImplemented();
          }
        }
      );
  }

  private TensorImage getPreprocessedImageForTensorFlow(
    Bitmap bitmap,
    int inferenceSize,
    boolean scaling,
    boolean permute,
    boolean normalization,
    float[] normMean,
    float[] normStd
  ) {
    ImageProcessor.Builder builder = new ImageProcessor.Builder();
    builder.add(
      new ResizeOp(inferenceSize, inferenceSize, ResizeOp.ResizeMethod.BILINEAR)
    );
    if (scaling) {
      builder.add(new NormalizeOp(0, 255));
    }
    if (permute) {}
    if (normalization) {
      builder.add(new NormalizeOp(normMean, normStd));
    }
    ImageProcessor imageProcessor = builder.build();
    TensorImage tensorImage = new TensorImage(DataType.FLOAT32);
    tensorImage.load(bitmap);
    tensorImage = imageProcessor.process(tensorImage);
    ColoredLog(
      "H: " + tensorImage.getHeight() + "W: " + tensorImage.getWidth()
    );
    return tensorImage;
  }

  private Tensor getPreprocessedImageForPytorch(
    Bitmap bitmap,
    int inferenceSize
    /*boolean scaling, 
        boolean permute, 
        boolean normalization,
        float[] mean,
        float[] std */
  ) {
    bitmap =
      PreprocessorUtils.resizeBitmap(bitmap, inferenceSize, inferenceSize);
    /*
            if (scaling) {
                bitmap = PreprocessorUtils.scaleBitmapToOne(bitmap);
            }
            if (permute) {
                bitmap = PreprocessorUtils.permuteChannels(bitmap);
            }
            if (normalization) {
                bitmap = PreprocessorUtils.normalizeBitmap(
                    bitmap, 
                    mean,
                    std
                    );
            }
            */
    Tensor inputTensor = TensorImageUtils.bitmapToFloat32Tensor(
      bitmap,
      TensorImageUtils.TORCHVISION_NORM_MEAN_RGB,
      TensorImageUtils.TORCHVISION_NORM_STD_RGB
    );
    return inputTensor;
  }

  private String getMachineVersion() {
    return "Serving of TensorFlow, topping of PyTorch";
  }

  private String _getAssetPath(String asset) throws IOException {
    String filePath = "";
    Context context = getApplicationContext();
    File externalFilesDir = context.getExternalFilesDir(null);
    File file = new File(externalFilesDir, asset);
    if (file.exists() && file.length() > 0) {
      filePath = file.getAbsolutePath();
    }
    return filePath;
  }

  private String getAssetPath(Context context, String asset)
    throws IOException {
    File externalFilesDir = context.getExternalFilesDir(null);
    File file = new File(externalFilesDir, asset);
    if (file.exists() && file.length() > 0) {
      return file.getAbsolutePath();
    } else {
      try (InputStream is = context.getAssets().open(asset)) {
        try (OutputStream os = new FileOutputStream(file)) {
          byte[] buffer = new byte[4 * 1024];
          int read;
          while ((read = is.read(buffer)) != -1) {
            os.write(buffer, 0, read);
          }
          os.flush();
        }
        return file.getAbsolutePath();
      }
    }
  }

  private void getAssetPathArchive(Context context, String name)
    throws IOException {
    // Access the Android/data folder
    File externalFilesDir = context.getExternalFilesDir(null);
    // File dataFolder = new File(externalFilesDir, "data");
    String dataFolderPath = externalFilesDir.getAbsolutePath();
    ColoredLog("DATA FOLDER PATH: " + dataFolderPath);
    // Perform operations with the data folder
    if (externalFilesDir.exists()) {
      File[] files = externalFilesDir.listFiles();
      if (files != null) {
        for (File file : files) {
          String fileName = file.getName();
          ColoredLog("DATA FILE: " + fileName);
        }
      }
    } else {
      ColoredLog("DATA FOLDER NOT FOUND");
    }
  }

  public static String assetFilePath(Context context, String assetName)
    throws IOException {
    File file = new File(context.getFilesDir(), assetName);
    if (file.exists() && file.length() > 0) {
      return file.getAbsolutePath();
    }

    try (InputStream is = context.getAssets().open(assetName)) {
      try (OutputStream os = new FileOutputStream(file)) {
        byte[] buffer = new byte[4 * 1024];
        int read;
        while ((read = is.read(buffer)) != -1) {
          os.write(buffer, 0, read);
        }
        os.flush();
      }
      return file.getAbsolutePath();
    }
  }

  private List<Prediction> postProcessor(float[] inputs, int numPreds) {
    List<Prediction> predictions = new ArrayList<>();
    for (int i = 0; i < inputs.length; i++) {
      predictions.add(new Prediction(i, inputs[i]));
    }
    Collections.sort(predictions, Collections.reverseOrder());
    List<Prediction> topPredictions = new ArrayList<>();
    for (int i = 0; i < Math.min(numPreds, predictions.size()); i++) {
      topPredictions.add(predictions.get(i));
    }
    return topPredictions;
  }

  private static float[] listToFloat(List<Double> listDouble) {
    float[] floatArray = new float[listDouble.size()];
    for (int i = 0; i < listDouble.size(); i++) {
      floatArray[i] = listDouble.get(i).floatValue();
    }
    return floatArray;
  }

  private static void ColoredLog(String input) {
    String ANSI_RESET = "\u001B[0m";
    String ANSI_GREEN = "\u001B[32m";
    String logContent = ANSI_GREEN + input + ANSI_RESET;
    Log.d("================\n", logContent);
  }

  private static List<String> getListStrings(List<Prediction> predictions) {
    List<String> predictionStrings = new ArrayList<>();
    for (Prediction prediction : predictions) {
      String predictionString =
        prediction.getIndex() + " " + prediction.getScore();
      predictionStrings.add(predictionString);
    }
    return predictionStrings;
  }

  public class Prediction implements Comparable<Prediction> {
    private final int index;
    private final float score;

    public Prediction(int index, float score) {
      this.index = index;
      this.score = score;
    }

    public int getIndex() {
      return index;
    }

    public float getScore() {
      return score;
    }

    @Override
    public int compareTo(Prediction other) {
      return Float.compare(this.score, other.score);
    }
  }
}
