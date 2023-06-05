package com.example.flutter_native;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

import android.util.Log;


class Result {
    int classIndex;
    Float score;
    float left;
    float top;
    float right;
    float bottom;


    public Result(int cls, Float output, float left, float top, float right, float bottom) {
        this.classIndex = cls;
        this.score = output;
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }
};

public class PrePostProcessor {
    // for yolov5 model, no need to apply MEAN and STD
    static float[] NO_MEAN_RGB = new float[] {0.0f, 0.0f, 0.0f};
    static float[] NO_STD_RGB = new float[] {1.0f, 1.0f, 1.0f};

    // model input image size
    static int inferenceWidth = 640;
    static int inferenceHeight = 640;

    // model output is of size 25200*(num_of_class+5)
    private static int mOutputRow = 25200; // as decided by the YOLOv5 model for input image of size 640*640
    private static int mOutputColumn = 85; // left, top, right, bottom, score and 80 class probability
    private static float mThreshold = 0.30f; // score above which a detection is generated
    private static int mNmsLimit = 15;

    static String[] mClasses;

    // The two methods nonMaxSuppression and IOU below are ported from https://github.com/hollance/YOLO-CoreML-MPSNNGraph/blob/master/Common/Helpers.swift
    /**
     Removes bounding boxes that overlap too much with other boxes that have
     a higher score.
     - Parameters:
     - boxes: an array of bounding boxes and their scores
     - limit: the maximum number of boxes that will be selected
     - threshold: used to decide whether boxes overlap too much
     */
    static ArrayList<Result> nonMaxSuppression(ArrayList<Result> boxes, int limit, float threshold) {

        // Do an argsort on the confidence scores, from high to low.
        Collections.sort(boxes,
                new Comparator<Result>() {
                    @Override
                    public int compare(Result o1, Result o2) {
                        return o1.score.compareTo(o2.score);
                    }
                });

        ArrayList<Result> selected = new ArrayList<>();
        boolean[] active = new boolean[boxes.size()];
        Arrays.fill(active, true);
        int numActive = active.length;

        // The algorithm is simple: Start with the box that has the highest score.
        // Remove any remaining boxes that overlap it more than the given threshold
        // amount. If there are any boxes left (i.e. these did not overlap with any
        // previous boxes), then repeat this procedure, until no more boxes remain
        // or the limit has been reached.
        boolean done = false;
        for (int i=0; i<boxes.size() && !done; i++) {
            if (active[i]) {
                Result boxA = boxes.get(i);
                selected.add(boxA);
                if (selected.size() >= limit) break;

                for (int j=i+1; j<boxes.size(); j++) {
                    if (active[j]) {
                        Result boxB = boxes.get(j);
                        if (IOU(boxA, boxB) > threshold) {
                            active[j] = false;
                            numActive -= 1;
                            if (numActive <= 0) {
                                done = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return selected;
    }

    /**
     Computes intersection-over-union overlap between two bounding boxes.
     */
    static float IOU(Result a, Result b) {
        float areaA = (a.right - a.left) * (a.bottom - a.top);
        if (areaA <= 0.0) return 0.0f;

        float areaB = (b.right - b.left) * (b.bottom - b.top);
        if (areaB <= 0.0) return 0.0f;

        float intersectionMinX = Math.max(a.left, b.left);
        float intersectionMinY = Math.max(a.top, b.top);
        float intersectionMaxX = Math.min(a.right, b.right);
        float intersectionMaxY = Math.min(a.bottom, b.bottom);
        float intersectionArea = Math.max(intersectionMaxY - intersectionMinY, 0) *
                Math.max(intersectionMaxX - intersectionMinX, 0);
        return intersectionArea / (areaA + areaB - intersectionArea);
    }

    static ArrayList<Result> outputsToNMSPredictions(float[] outputs, int height, int width) {

        ArrayList<Result> results = new ArrayList<>();
        for (int i = 0; i< mOutputRow; i++) {
            if (outputs[i* mOutputColumn +4] > mThreshold) {
                float x = outputs[i* mOutputColumn];
                float y = outputs[i* mOutputColumn +1];
                float w = outputs[i* mOutputColumn +2];
                float h = outputs[i* mOutputColumn +3];

                float left = x - w/2;
                float top = y - h/2;
                float right = x + w/2;
                float bottom = y + h/2;

                float[] resized = resizeValues(top, left, bottom, right, (float) height, (float) width);
                top = resized[0];
                left = resized[1];
                bottom = resized[2];
                right = resized[3];
                float max = outputs[i * mOutputColumn + 5];
                int cls = 0;
                for (int j = 0; j < mOutputColumn - 5; j++) {
                    if (outputs[i* mOutputColumn + 5 + j] > max) {
                        max = outputs[i* mOutputColumn + 5 + j];
                        cls = j;
                    }
                }

                Result result = new Result(cls, outputs[i * mOutputColumn + 4], left, top, right, bottom);
                results.add(result);
            }
        }

        return nonMaxSuppression(results, mNmsLimit, mThreshold);
    }

    public static float[] resizeValues(float top, float left, float bottom, float right, float finalHeight, float finalWidth) {
        float widthRatio = finalWidth / inferenceWidth;
        float heightRatio = finalHeight / inferenceHeight;
        
        float resizedTop = Math.max(top * heightRatio, 0);
        float resizedLeft = Math.max(left * widthRatio, 0);
        float resizedBottom = Math.min(bottom * heightRatio, finalHeight);
        float resizedRight = Math.min(right * widthRatio, finalWidth);
        return new float[]{resizedTop, resizedLeft, resizedBottom, resizedRight};
    }
}