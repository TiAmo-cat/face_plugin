package com.example.face_plugin;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;

import androidx.annotation.NonNull;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetector;
import com.google.mlkit.vision.face.FaceDetectorOptions;
import com.google.mlkit.vision.face.FaceLandmark;

import org.tensorflow.lite.Interpreter;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FacePlugin implements FlutterPlugin, MethodCallHandler {
    private static final String CHANNEL = "face_plugin";
    private static final String MODEL_FILE = "mobilefacenet.tflite";
    
    private static final int INPUT_SIZE = 112;
    private static int FEATURE_DIM = 128; // Will be updated after loading model
    private static final float IMAGE_MEAN = 127.5f;
    private static final float IMAGE_STD = 128.0f;

    private MethodChannel channel;
    private Context context;
    private Interpreter tfliteInterpreter;
    private FaceDetector faceDetector;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        
        // Initialize TFLite interpreter for feature extraction
        try {
            tfliteInterpreter = new Interpreter(loadModelFile());

            // Auto-detect feature dimension from model output
            int[] outputShape = tfliteInterpreter.getOutputTensor(0).shape();
            if (outputShape.length >= 2) {
                FEATURE_DIM = outputShape[1];
                android.util.Log.d("FacePlugin", "TFLite model loaded successfully");
                android.util.Log.d("FacePlugin", "Model output shape: " + java.util.Arrays.toString(outputShape));
                android.util.Log.d("FacePlugin", "Feature dimension: " + FEATURE_DIM);
            } else {
                android.util.Log.e("FacePlugin", "Unexpected output shape: " + java.util.Arrays.toString(outputShape));
            }
        } catch (IOException e) {
            android.util.Log.e("FacePlugin", "Failed to load TFLite model: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Initialize ML Kit Face Detector
        FaceDetectorOptions options = new FaceDetectorOptions.Builder()
                .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
                .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
                .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
                .setMinFaceSize(0.15f)
                .enableTracking()
                .build();
        
        faceDetector = FaceDetection.getClient(options);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "detectFaces":
                detectFaces(call, result);
                break;
            case "extractFeatures":
                extractFeatures(call, result);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        if (tfliteInterpreter != null) {
            tfliteInterpreter.close();
            tfliteInterpreter = null;
        }
        if (faceDetector != null) {
            faceDetector.close();
            faceDetector = null;
        }
    }

    private void detectFaces(@NonNull MethodCall call, @NonNull Result result) {
        try {
            byte[] imageBytes = call.argument("imageBytes");
            if (imageBytes == null) {
                result.error("INVALID_ARGUMENT", "imageBytes is null", null);
                return;
            }

            Bitmap bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
            if (bitmap == null) {
                result.error("DECODE_ERROR", "Failed to decode image", null);
                return;
            }

            // Use ML Kit to detect faces (async)
            InputImage image = InputImage.fromBitmap(bitmap, 0);
            final int imageWidth = bitmap.getWidth();
            final int imageHeight = bitmap.getHeight();

            faceDetector.process(image)
                .addOnSuccessListener(faces -> {
                    List<Map<String, Object>> faceResults = convertMLKitFacesToMap(faces, imageWidth, imageHeight);
                    result.success(faceResults);
                })
                .addOnFailureListener(e -> {
                    result.error("DETECTION_ERROR", e.getMessage(), null);
                });

        } catch (Exception e) {
            result.error("DETECTION_ERROR", e.getMessage(), null);
        }
    }

    private void extractFeatures(@NonNull MethodCall call, @NonNull Result result) {
        try {
            byte[] imageBytes = call.argument("imageBytes");
            if (imageBytes == null) {
                result.error("INVALID_ARGUMENT", "imageBytes is null", null);
                return;
            }

            Bitmap bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
            if (bitmap == null) {
                result.error("DECODE_ERROR", "Failed to decode image", null);
                return;
            }

            // First detect faces using ML Kit (async)
            InputImage image = InputImage.fromBitmap(bitmap, 0);

            faceDetector.process(image)
                .addOnSuccessListener(faces -> {
                    // Extract features for each detected face
                    List<List<Double>> features = extractFeaturesFromFaces(bitmap, faces);
                    result.success(features);
                })
                .addOnFailureListener(e -> {
                    result.error("EXTRACTION_ERROR", e.getMessage(), null);
                });

        } catch (Exception e) {
            result.error("EXTRACTION_ERROR", e.getMessage(), null);
        }
    }

    private List<Map<String, Object>> convertMLKitFacesToMap(List<Face> faces, int imageWidth, int imageHeight) {
        List<Map<String, Object>> results = new ArrayList<>();
        
        for (Face face : faces) {
            Map<String, Object> faceMap = new HashMap<>();
            
            Rect boundingBox = face.getBoundingBox();
            faceMap.put("faceX", (double) boundingBox.left);
            faceMap.put("faceY", (double) boundingBox.top);
            faceMap.put("bboxW", (double) boundingBox.width());
            faceMap.put("bboxH", (double) boundingBox.height());
            
            // Extract landmarks
            FaceLandmark leftEye = face.getLandmark(FaceLandmark.LEFT_EYE);
            FaceLandmark rightEye = face.getLandmark(FaceLandmark.RIGHT_EYE);
            FaceLandmark noseBase = face.getLandmark(FaceLandmark.NOSE_BASE);
            FaceLandmark leftMouth = face.getLandmark(FaceLandmark.MOUTH_LEFT);
            FaceLandmark rightMouth = face.getLandmark(FaceLandmark.MOUTH_RIGHT);
            
            // Right eye (from image perspective)
            if (rightEye != null) {
                faceMap.put("reyeX", (double) rightEye.getPosition().x);
                faceMap.put("reyeY", (double) rightEye.getPosition().y);
            } else {
                faceMap.put("reyeX", (double) (boundingBox.left + boundingBox.width() * 0.3));
                faceMap.put("reyeY", (double) (boundingBox.top + boundingBox.height() * 0.35));
            }
            
            // Left eye (from image perspective)
            if (leftEye != null) {
                faceMap.put("leyeX", (double) leftEye.getPosition().x);
                faceMap.put("leyeY", (double) leftEye.getPosition().y);
            } else {
                faceMap.put("leyeX", (double) (boundingBox.left + boundingBox.width() * 0.7));
                faceMap.put("leyeY", (double) (boundingBox.top + boundingBox.height() * 0.35));
            }
            
            // Nose
            if (noseBase != null) {
                faceMap.put("noseX", (double) noseBase.getPosition().x);
                faceMap.put("noseY", (double) noseBase.getPosition().y);
            } else {
                faceMap.put("noseX", (double) boundingBox.centerX());
                faceMap.put("noseY", (double) boundingBox.centerY());
            }
            
            // Mouth corners
            if (rightMouth != null) {
                faceMap.put("rmouthX", (double) rightMouth.getPosition().x);
                faceMap.put("rmouthY", (double) rightMouth.getPosition().y);
            } else {
                faceMap.put("rmouthX", (double) (boundingBox.left + boundingBox.width() * 0.35));
                faceMap.put("rmouthY", (double) (boundingBox.top + boundingBox.height() * 0.75));
            }
            
            if (leftMouth != null) {
                faceMap.put("lmouthX", (double) leftMouth.getPosition().x);
                faceMap.put("lmouthY", (double) leftMouth.getPosition().y);
            } else {
                faceMap.put("lmouthX", (double) (boundingBox.left + boundingBox.width() * 0.65));
                faceMap.put("lmouthY", (double) (boundingBox.top + boundingBox.height() * 0.75));
            }
            
            faceMap.put("width", (double) imageWidth);
            faceMap.put("height", (double) imageHeight);
            faceMap.put("faceScore", (double) (face.getTrackingId() != null ? 1.0 : 0.9));
            faceMap.put("faceTv", face.getTrackingId() != null ? face.getTrackingId() : 0);
            faceMap.put("clsId", 0);
            
            results.add(faceMap);
        }
        
        return results;
    }

    private List<List<Double>> extractFeaturesFromFaces(Bitmap bitmap, List<Face> faces) {
        List<List<Double>> features = new ArrayList<>();
        
        if (tfliteInterpreter == null) {
            android.util.Log.e("FacePlugin", "TFLite interpreter is null!");
            return features;
        }

        android.util.Log.d("FacePlugin", "Extracting features for " + faces.size() + " faces");

        for (int faceIndex = 0; faceIndex < faces.size(); faceIndex++) {
            Face face = faces.get(faceIndex);
            try {
                // Crop face region
                Rect boundingBox = face.getBoundingBox();
                
                android.util.Log.d("FacePlugin", "Face " + faceIndex + " bounding box: " + boundingBox.toString());

                // Expand bounding box slightly
                int padding = (int) (Math.max(boundingBox.width(), boundingBox.height()) * 0.2);
                int left = Math.max(0, boundingBox.left - padding);
                int top = Math.max(0, boundingBox.top - padding);
                int right = Math.min(bitmap.getWidth(), boundingBox.right + padding);
                int bottom = Math.min(bitmap.getHeight(), boundingBox.bottom + padding);
                
                int width = right - left;
                int height = bottom - top;
                
                android.util.Log.d("FacePlugin", "Crop region: left=" + left + ", top=" + top + ", width=" + width + ", height=" + height);

                if (width <= 0 || height <= 0) {
                    android.util.Log.e("FacePlugin", "Invalid crop dimensions for face " + faceIndex);
                    continue;
                }
                
                // Crop and resize face
                Bitmap faceBitmap = Bitmap.createBitmap(bitmap, left, top, width, height);
                Bitmap resizedFace = Bitmap.createScaledBitmap(faceBitmap, INPUT_SIZE, INPUT_SIZE, true);
                
                android.util.Log.d("FacePlugin", "Face cropped and resized to " + INPUT_SIZE + "x" + INPUT_SIZE);

                // Preprocess and extract features
                ByteBuffer inputBuffer = convertBitmapToByteBuffer(resizedFace);
                float[][] output = new float[1][FEATURE_DIM];

                android.util.Log.d("FacePlugin", "Running TFLite inference...");
                tfliteInterpreter.run(inputBuffer, output);
                
                // Convert to List<Double>
                List<Double> feature = new ArrayList<>();
                for (int i = 0; i < FEATURE_DIM; i++) {
                    feature.add((double) output[0][i]);
                }
                features.add(feature);
                
                android.util.Log.d("FacePlugin", "Feature extracted successfully for face " + faceIndex + ", vector length: " + feature.size());

                // Clean up
                faceBitmap.recycle();
                resizedFace.recycle();
                
            } catch (Exception e) {
                android.util.Log.e("FacePlugin", "Error extracting features for face " + faceIndex + ": " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        android.util.Log.d("FacePlugin", "Total features extracted: " + features.size());
        return features;
    }

    private ByteBuffer convertBitmapToByteBuffer(Bitmap bitmap) {
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4 * INPUT_SIZE * INPUT_SIZE * 3);
        byteBuffer.order(ByteOrder.nativeOrder());
        
        int[] intValues = new int[INPUT_SIZE * INPUT_SIZE];
        bitmap.getPixels(intValues, 0, bitmap.getWidth(), 0, 0, bitmap.getWidth(), bitmap.getHeight());
        
        int pixel = 0;
        for (int i = 0; i < INPUT_SIZE; i++) {
            for (int j = 0; j < INPUT_SIZE; j++) {
                final int val = intValues[pixel++];
                
                // Extract RGB values and normalize
                float r = ((val >> 16) & 0xFF);
                float g = ((val >> 8) & 0xFF);
                float b = (val & 0xFF);
                
                // Normalize: (pixel - mean) / std
                byteBuffer.putFloat((r - IMAGE_MEAN) / IMAGE_STD);
                byteBuffer.putFloat((g - IMAGE_MEAN) / IMAGE_STD);
                byteBuffer.putFloat((b - IMAGE_MEAN) / IMAGE_STD);
            }
        }
        
        return byteBuffer;
    }

    private MappedByteBuffer loadModelFile() throws IOException {
        AssetFileDescriptor fileDescriptor = context.getAssets().openFd(MODEL_FILE);
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }
}

