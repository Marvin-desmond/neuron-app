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

// Java IO for reading Model
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import android.content.Context;

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
                        Bitmap bitmap = BitmapFactory.decodeStream(getAssets().open("input_2.jpeg"));
                        // int width = bitmap.getWidth();
                        // int height = bitmap.getHeight();
                        Module module = LiteModuleLoader.load(assetFilePath(this, "model.pt"));
                        Tensor inputTensor = TensorImageUtils.bitmapToFloat32Tensor(bitmap,
                            TensorImageUtils.TORCHVISION_NORM_MEAN_RGB, TensorImageUtils.TORCHVISION_NORM_STD_RGB);
                        Tensor outputTensor = module.forward(IValue.from(inputTensor)).toTensor();
                        float[] scores = outputTensor.getDataAsFloatArray();
                        float maxScore = -Float.MAX_VALUE;
                        int maxScoreIdx = -1;
                        for (int i = 0; i < scores.length; i++) {
                            if (scores[i] > maxScore) {
                                maxScore = scores[i];
                                maxScoreIdx = i;
                            }
                        }
                        String className = ImageNetClasses.IMAGENET_CLASSES[maxScoreIdx];

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
}
