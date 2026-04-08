# face_plugin

A Flutter plugin for face detection and feature extraction using MobileFaceNet on Android and iOS.

## Features

- **Face Detection**: Detect faces with bounding boxes and facial landmarks
- **Feature Extraction**: Extract 128-dimensional face feature vectors using MobileFaceNet
- **Cross-platform**: Full implementation for both Android (Java + TFLite) and iOS (Swift + TFLite)
- **Ready to use**: Simple API with out-of-the-box functionality

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  face_plugin:
    path: ../face_plugin
```

## Setup

### Model Files

Before using the plugin, you need to provide the MobileFaceNet TFLite model:

1. **Android**: Place `mobilefacenet.tflite` in `android/src/main/assets/`
2. **iOS**: Place `mobilefacenet.tflite` in `ios/Classes/`

### Model Requirements

- **Input size**: 112x112x3 (RGB image)
- **Output**: 128-dimensional feature vector
- **Preprocessing**: Normalized with mean=127.5, std=128.0

You can get pre-trained models from:
- https://github.com/sirius-ai/MobileFaceNet_TF
- https://github.com/deepinsight/insightface

## Usage

### Import

```dart
import 'package:face_plugin/face_plugin.dart';
import 'dart:typed_data';
```

### Detect Faces

```dart
// Load image as bytes
Uint8List imageBytes = await loadImageBytes();

// Detect faces
List<Face> faces = await FacePlugin.detectFaces(imageBytes);

for (Face face in faces) {
  print('Face detected at: (${face.faceX}, ${face.faceY})');
  print('Bounding box: ${face.bboxW} x ${face.bboxH}');
  print('Face score: ${face.faceScore}');
  print('Landmarks:');
  print('  Right eye: (${face.reyeX}, ${face.reyeY})');
  print('  Left eye: (${face.leyeX}, ${face.leyeY})');
  print('  Nose: (${face.noseX}, ${face.noseY})');
  print('  Mouth: (${face.rmouthX}, ${face.rmouthY}) - (${face.lmouthX}, ${face.lmouthY})');
}
```

### Extract Features

```dart
// Extract face features
List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);

for (int i = 0; i < features.length; i++) {
  print('Face ${i + 1} feature vector (${features[i].length} dimensions):');
  print('  First 5 values: ${features[i].take(5).toList()}');
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:face_plugin/face_plugin.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class FaceDetectionPage extends StatefulWidget {
  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  List<Face>? _faces;
  List<List<double>>? _features;
  bool _isLoading = false;

  Future<void> _pickAndProcessImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      Uint8List imageBytes = await image.readAsBytes();
      
      // Detect faces
      List<Face> faces = await FacePlugin.detectFaces(imageBytes);
      
      // Extract features
      List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);
      
      setState(() {
        _faces = faces;
        _features = features;
      });
      
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              CircularProgressIndicator()
            else if (_faces != null) ...[
              Text('Detected ${_faces!.length} face(s)'),
              Text('Extracted ${_features!.length} feature vector(s)'),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _faces!.length,
                  itemBuilder: (context, index) {
                    final face = _faces![index];
                    return Card(
                      child: ListTile(
                        title: Text('Face ${index + 1}'),
                        subtitle: Text(
                          'Position: (${face.faceX.toInt()}, ${face.faceY.toInt()})\n'
                          'Size: ${face.bboxW.toInt()} x ${face.bboxH.toInt()}\n'
                          'Score: ${face.faceScore.toStringAsFixed(2)}'
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            ElevatedButton(
              onPressed: _pickAndProcessImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### Face Class

```dart
class Face {
  final double faceX;        // Face bounding box X coordinate
  final double faceY;        // Face bounding box Y coordinate
  final double bboxW;        // Bounding box width
  final double bboxH;        // Bounding box height
  
  final double reyeX;        // Right eye X coordinate
  final double reyeY;        // Right eye Y coordinate
  final double leyeX;        // Left eye X coordinate
  final double leyeY;        // Left eye Y coordinate
  final double noseX;        // Nose X coordinate
  final double noseY;        // Nose Y coordinate
  final double rmouthX;      // Right mouth corner X
  final double rmouthY;      // Right mouth corner Y
  final double lmouthX;      // Left mouth corner X
  final double lmouthY;      // Left mouth corner Y
  
  final double width;        // Original image width
  final double height;       // Original image height
  
  final double faceScore;    // Detection confidence score
  final int faceTv;          // Face type value
  final int clsId;           // Classification ID
}
```

### Methods

#### `detectFaces(Uint8List imageBytes)`

Detects faces in the provided image.

- **Parameters**: 
  - `imageBytes`: Image data as Uint8List
- **Returns**: `Future<List<Face>>` - List of detected faces

#### `extractFeatures(Uint8List imageBytes)`

Extracts 128-dimensional feature vectors for each detected face.

- **Parameters**: 
  - `imageBytes`: Image data as Uint8List
- **Returns**: `Future<List<List<double>>>` - List of feature vectors (128 dimensions each)

## Platform Support

| Platform | Supported | Implementation |
|----------|-----------|----------------|
| Android  | ✅        | Java + TFLite 2.14.0 |
| iOS      | ✅        | Swift + TFLite 2.14.0 |

## Requirements

- **Flutter**: >=3.3.0
- **Dart**: ^3.6.0
- **Android**: minSdk 21 (Android 5.0)
- **iOS**: 12.0+

## Notes

- The current implementation uses simplified face detection for demonstration purposes
- For production use, consider integrating:
  - Android: Google ML Kit Face Detection or MTCNN
  - iOS: Vision Framework face detection
- Feature extraction uses MobileFaceNet which requires the model file to be placed in the appropriate platform directories

## License

See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

