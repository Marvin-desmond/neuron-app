package com.example.flutter_native;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

// BitMap image decoding
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

// PyTorch
import org.pytorch.IValue;
import org.pytorch.LiteModuleLoader;
import org.pytorch.Module;
import org.pytorch.LiteModuleLoader;
import org.pytorch.Tensor;
import org.pytorch.torchvision.TensorImageUtils;
import org.pytorch.MemoryFormat;

// TensorFlow
import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.DataType;
import org.tensorflow.lite.support.image.ImageProcessor;
import org.tensorflow.lite.support.image.TensorImage;
import org.tensorflow.lite.support.image.ops.ResizeOp;
import org.tensorflow.lite.support.common.ops.NormalizeOp;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;

// Java IO for reading Model
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import android.content.Context;
// Get file buffer
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;

// List handling
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

// Logging
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/battery";
    private static final String CHANNEL_ML = "samples.neuron.face/tools";


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("getBatteryLevel")) {
                    int batteryLevel = getBatteryLevel();

                    if (batteryLevel != -1) {
                        result.success(batteryLevel);
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null);
                    }
                }
            }
        );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_ML)
        .setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("getMachineVersion")) {
                    try {
                        String mVersion = getMachineVersion();
                        String[] assetList = getAssets().list("");
                        // root directory of getAssets is :app:android/src/main/assets
                        // put your images in assets
                        Bitmap bitmap = BitmapFactory.decodeStream(getAssets().open("input.jpeg"));
                        Module module = LiteModuleLoader.load(assetFilePath(this, "model.pt"));
                        Tensor inputTensor = TensorImageUtils.bitmapToFloat32Tensor(bitmap,
                            TensorImageUtils.TORCHVISION_NORM_MEAN_RGB, TensorImageUtils.TORCHVISION_NORM_STD_RGB);
                        Tensor outputTensor = module.forward(IValue.from(inputTensor)).toTensor();
                        float[] scores = outputTensor.getDataAsFloatArray();
                        List<Prediction> post_results = postProcessor(scores, 2);
                        ColoredLog(" PyTorch ===> " + ImageNetClasses.IMAGENET_CLASSES[post_results.get(0).getIndex()]);
                        String className = ImageNetClasses.IMAGENET_CLASSES[post_results.get(0).getIndex()];

                        File model = new File(assetFilePath(this, "classification_model.tflite"));
                        try (Interpreter interpreter = new Interpreter(model)) {
                            Interpreter.Options tfliteOptions = (new Interpreter.Options());
                            ImageProcessor imageProcessor = new ImageProcessor.Builder()
                                .add(new ResizeOp(224, 224, ResizeOp.ResizeMethod.BILINEAR))
                                .add(new NormalizeOp(0, 255))
                                .build();
                            int inputIndex = 0; // Adjust this based on your model's input index
                            int outputIndex = 0; // Adjust this based on your model's output index
                            int[] inputShape = interpreter.getInputTensor(inputIndex).shape();
                            int[] outputShape = interpreter.getOutputTensor(outputIndex).shape();

                            TensorImage tensorImage = new TensorImage(DataType.FLOAT32);
                            tensorImage.load(bitmap);
                            tensorImage = imageProcessor.process(tensorImage);
                            TensorBuffer probabilityBuffer = TensorBuffer.createFixedSize(outputShape, DataType.FLOAT32);
                            interpreter.run(tensorImage.getBuffer(), probabilityBuffer.getBuffer());
                            float[] results = probabilityBuffer.getFloatArray();
                            post_results = postProcessor(results, 2);
                            ColoredLog("TensorFlow ====>" + ImageNetClasses.IMAGENET_CLASSES[post_results.get(0).getIndex()]);
                        } catch(Exception e) {
                            ColoredLog("ERROR: " + e);
                        }

                        result.success(mVersion + className);
                    } catch (Exception e) {
                        System.out.println(e);
                        result.error("NULL", "Machine not found", null);
                    }

                }
            }
        );
    }


    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
        return batteryLevel;
    }

    private String getMachineVersion() {
        return "Serving of TensorFlow, topping of PyTorch";
    }

    public static String assetFilePath(Context context, String assetName) throws IOException {
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

    private static void ColoredLog(String input) {
        String ANSI_RESET = "\u001B[0m";
        String ANSI_GREEN = "\u001B[32m";
        String logContent = ANSI_GREEN + input + ANSI_RESET;
        Log.d("================\n", logContent);
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
