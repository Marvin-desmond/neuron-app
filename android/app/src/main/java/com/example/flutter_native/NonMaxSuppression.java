package com.example.flutter_native;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class NonMaxSuppression {
    public static float[][][] non_max_suppression(float[][][] prediction, float confThres, float iouThres) {
        int batchSize = 1;
        int numBoxes = 25200;
        int numClasses = 80;

        List<float[][]> output = new ArrayList<>();

        for (int batchIndex = 0; batchIndex < batchSize; batchIndex++) {
            float[][] predBatch = prediction[batchIndex];

            List<float[]> selected = new ArrayList<>();

            // Filter based on confidence threshold
            for (float[] pred : predBatch) {
                if (pred[4] > confThres) {
                    float[] objClsConf = Arrays.copyOfRange(pred, 5, numClasses + 5);
                    float[] box = batchXYWHtoXYXY(Arrays.copyOfRange(pred, 0, 4));
                    float maxConf = 0;
                    int maxIndex = -1;

                    for (int i = 0; i < numClasses; i++) {
                        float score = objClsConf[i] * pred[4];
                        if (score > maxConf) {
                            maxConf = score;
                            maxIndex = i;
                        }
                    }

                    float[] selectedPred = Arrays.copyOf(box, 6);
                    selectedPred[4] = maxConf;
                    selectedPred[5] = maxIndex;
                    selected.add(selectedPred);
                }
            }

            // Sort selected predictions based on confidence score
            selected.sort(Comparator.comparingDouble(pred -> pred[4]));
            if (selected.size() > 100) {
                selected = selected.subList(selected.size() - 100, selected.size());
            }

            // Apply non-maximum suppression
            List<float[]> nmsOutput = applyNMS(selected, iouThres);

            // Pad with zeros to match output shape
            int maxDet = 300;
            if (nmsOutput.size() < maxDet) {
                while (nmsOutput.size() < maxDet) {
                    nmsOutput.add(new float[6]);
                }
            } else {
                nmsOutput = nmsOutput.subList(0, maxDet);
            }

            output.add(nmsOutput.toArray(new float[0][]));
        }

        return output.toArray(new float[0][][]);
    }

    private static float[] batchXYWHtoXYXY(float[] box) {
        float x = box[0];
        float y = box[1];
        float w = box[2];
        float h = box[3];

        float[] xyxy = new float[4];
        xyxy[0] = x - w / 2f;
        xyxy[1] = y - h / 2f;
        xyxy[2] = x + w / 2f;
        xyxy[3] = y + h / 2f;

        return xyxy;
    }

    private static List<float[]> applyNMS(List<float[]> predictions, float iouThres) {
        List<float[]> selected = new ArrayList<>();

        while (!predictions.isEmpty()) {
            float[] pred = predictions.get(predictions.size() - 1);
            selected.add(pred);

            float[] predBox = Arrays.copyOfRange(pred, 0, 4);

            List<float[]> remaining = new ArrayList<>();
            for (float[] p : predictions) {
                float[] box = Arrays.copyOfRange(p, 0, 4);
                float iou = calculateIOU(predBox, box);
                if (iou <= iouThres) {
                    remaining.add(p);
                }
            }

            predictions = remaining;
        }

        return selected;
    }

    private static float calculateIOU(float[] box1, float[] box2) {
        float x1 = Math.max(box1[0], box2[0]);
        float y1 = Math.max(box1[1], box2[1]);
        float x2 = Math.min(box1[2], box2[2]);
        float y2 = Math.min(box1[3], box2[3]);

        float intersection = Math.max(0, x2 - x1) * Math.max(0, y2 - y1);
        float area1 = (box1[2] - box1[0]) * (box1[3] - box1[1]);
        float area2 = (box2[2] - box2[0]) * (box2[3] - box2[1]);

        return intersection / (area1 + area2 - intersection);
    }

    public static void main(String[] args) {
        // Test the function
        float[][][] prediction = new float[1][25200][85];  // Replace with actual prediction data
        float[][][] result = non_max_suppression(prediction, 0.25f, 0.45f);
        System.out.println(Arrays.deepToString(result));
    }
}
