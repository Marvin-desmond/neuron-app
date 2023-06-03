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
  public static float[] TORCHVISION_NORM_MEAN_RGB = new float[] {
    0.485f,
    0.456f,
    0.406f,
  };
  public static float[] TORCHVISION_NORM_STD_RGB = new float[] {
    0.229f,
    0.224f,
    0.225f,
  };

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

  // Scale a bitmap by diving by 255, (into the range 0 - 1)
  public static Bitmap scaleBitmapToOne(Bitmap bitmap) {
    int width = bitmap.getWidth();
    int height = bitmap.getHeight();

    Bitmap scaledBitmap = Bitmap.createBitmap(
      width,
      height,
      Bitmap.Config.ARGB_8888
    );

    int maxPixelValue = 255;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = bitmap.getPixel(x, y);

        int alpha = (pixel >> 24) & 0xFF;
        int red = (pixel >> 16) & 0xFF;
        int green = (pixel >> 8) & 0xFF;
        int blue = pixel & 0xFF;

        float scaledAlpha = (float) alpha / maxPixelValue;
        float scaledRed = (float) red / maxPixelValue;
        float scaledGreen = (float) green / maxPixelValue;
        float scaledBlue = (float) blue / maxPixelValue;

        int scaledPixel =
          ((int) (scaledAlpha * maxPixelValue) << 24) |
          ((int) (scaledRed * maxPixelValue) << 16) |
          ((int) (scaledGreen * maxPixelValue) << 8) |
          (int) (scaledBlue * maxPixelValue);

        scaledBitmap.setPixel(x, y, scaledPixel);
      }
    }
    return scaledBitmap;
  }

  // Normalize a bitmap using the specified mean and std
  public static Bitmap normalizeBitmap(
    Bitmap bitmap,
    float[] meanRGB,
    float[] stdRGB
  ) {
    int width = bitmap.getWidth();
    int height = bitmap.getHeight();
    Bitmap normalizedBitmap = Bitmap.createBitmap(
      width,
      height,
      Bitmap.Config.ARGB_8888
    );

    float normMeanR = meanRGB[0];
    float normMeanG = meanRGB[1];
    float normMeanB = meanRGB[2];
    float normStdR = stdRGB[0];
    float normStdG = stdRGB[1];
    float normStdB = stdRGB[2];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = bitmap.getPixel(x, y);

        float r = ((pixel >> 16) & 0xff) / 255.0f;
        float g = ((pixel >> 8) & 0xff) / 255.0f;
        float b = (pixel & 0xff) / 255.0f;

        float normalizedR = (r - normMeanR) / normStdR;
        float normalizedG = (g - normMeanG) / normStdG;
        float normalizedB = (b - normMeanB) / normStdB;

        int normalizedPixel =
          ((int) (normalizedR * 255) << 16) |
          ((int) (normalizedG * 255) << 8) |
          (int) (normalizedB * 255);

        normalizedBitmap.setPixel(x, y, normalizedPixel);
      }
    }

    return normalizedBitmap;
  }

  // Normalize scale bitmap
  public static Bitmap normalizeScaleBitmap(
    Bitmap bitmap,
    float[] mean,
    float[] std
  ) {
    int width = bitmap.getWidth();
    int height = bitmap.getHeight();

    Bitmap normalizedBitmap = Bitmap.createBitmap(
      width,
      height,
      Bitmap.Config.ARGB_8888
    );

    float maxPixelValue = 255.0f;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = bitmap.getPixel(x, y);

        int alpha = (pixel >> 24) & 0xFF;
        int red = (pixel >> 16) & 0xFF;
        int green = (pixel >> 8) & 0xFF;
        int blue = pixel & 0xFF;

        float normalizedRed = ((red / maxPixelValue) - mean[0]) / std[0];
        float normalizedGreen = ((green / maxPixelValue) - mean[1]) / std[1];
        float normalizedBlue = ((blue / maxPixelValue) - mean[2]) / std[2];

        int normalizedAlpha = alpha;
        int normalizedRedByte = (int) (normalizedRed * maxPixelValue);
        int normalizedGreenByte = (int) (normalizedGreen * maxPixelValue);
        int normalizedBlueByte = (int) (normalizedBlue * maxPixelValue);

        int normalizedPixel =
          (normalizedAlpha << 24) |
          (normalizedRedByte << 16) |
          (normalizedGreenByte << 8) |
          normalizedBlueByte;

        normalizedBitmap.setPixel(x, y, normalizedPixel);
      }
    }

    return normalizedBitmap;
  }

  // Permute the color channels in a bitmap (BGR to RGB)
  public static Bitmap permuteChannels(Bitmap bitmap) {
    int width = bitmap.getWidth();
    int height = bitmap.getHeight();

    Bitmap permutedBitmap = Bitmap.createBitmap(
      width,
      height,
      Bitmap.Config.ARGB_8888
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = bitmap.getPixel(x, y);

        int r = (pixel >> 16) & 0xff;
        int g = (pixel >> 8) & 0xff;
        int b = pixel & 0xff;

        int permutedPixel = (b << 16) | (g << 8) | r;

        permutedBitmap.setPixel(x, y, permutedPixel);
      }
    }
    return permutedBitmap;
  }

  // Convert a bitmap to a PyTorch tensor
  public static Tensor bitmapToFloat32Tensor(
    Bitmap bitmap,
    long[] shape,
    float[] meanRGB,
    float[] stdRGB
  ) {
    int width = bitmap.getWidth();
    int height = bitmap.getHeight();
    int[] pixels = new int[width * height];
    bitmap.getPixels(pixels, 0, width, 0, 0, width, height);

    ByteBuffer buffer = ByteBuffer.allocateDirect(width * height * 3 * 4);
    buffer.order(null);
    FloatBuffer floatBuffer = buffer.asFloatBuffer();

    for (int pixel : pixels) {
      floatBuffer.put(((pixel >> 16) & 0xff) / 255.0f);
      floatBuffer.put(((pixel >> 8) & 0xff) / 255.0f);
      floatBuffer.put((pixel & 0xff) / 255.0f);
    }

    Tensor tensor = Tensor.fromBlob(buffer, shape, MemoryFormat.CONTIGUOUS);
    return tensor;
  }

  // Convert a PyTorch tensor to a bitmap
  // ***********************************

  // Output predictions to three-dimension
  public static float[][][] reconstructPredictions(float[] results) {
    int[] shape = {1, 25200, 85};
    float[][][] outputData = new float[1][25200][85];
    for (int i = 0; i < shape[1]; i++) {
      for (int j = 0; j < shape[2]; j++) {
        outputData[0][i][j] = results[i * shape[2] + j];
      }
    }
    return outputData;
  }
}
