package com.example.flutter_native;

import android.graphics.Bitmap;
import android.graphics.ImageFormat;
import android.media.Image;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.Locale;
import org.pytorch.MemoryFormat;
import org.pytorch.Tensor;

public class PreprocessorUtils {
  // Resize a bitmap to the specified width and height
  public static Bitmap resizeBitmap(Bitmap bitmap, int width, int height) {
    return Bitmap.createScaledBitmap(bitmap, width, height, true);
  }

  // Scale a bitmap by the specified factor
  public static Bitmap scaleBitmap(Bitmap bitmap, float scaleFactor) {
    int width = Math.round(bitmap.getWidth() * scaleFactor);
    int height = Math.round(bitmap.getHeight() * scaleFactor);
    return resizeBitmap(bitmap, width, height);
  }

  // Output predictions to three-dimension
  public static float[][][] reconstructPredictions(float[] results) {
    int[] shape = { 1, 25200, 85 };
    float[][][] outputData = new float[1][25200][85];
    for (int i = 0; i < shape[1]; i++) {
      for (int j = 0; j < shape[2]; j++) {
        outputData[0][i][j] = results[i * shape[2] + j];
      }
    }
    return outputData;
  }
}
