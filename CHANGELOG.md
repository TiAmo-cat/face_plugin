# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2026-04-07

### Added
- Initial release of face_plugin
- Face detection with bounding boxes and facial landmarks (5 key points)
- Feature extraction using MobileFaceNet (128-dimensional vectors)
- Complete Android implementation (Java + TensorFlow Lite 2.14.0)
- Complete iOS implementation (Swift + TensorFlow Lite 2.14.0)
- Cross-platform API through Method Channel
- Comprehensive documentation (README, QUICK_START, MODEL_GUIDE, PROJECT_SUMMARY)
- Example application with UI demonstration
- Support for image preprocessing (resize to 112x112, normalization)

### Features
- `detectFaces(Uint8List imageBytes)` - Detect faces in images
- `extractFeatures(Uint8List imageBytes)` - Extract 128-D feature vectors
- Face model with bounding boxes, 5 facial landmarks, and confidence scores

### Platform Support
- Android: minSdk 21 (Android 5.0+)
- iOS: 12.0+
- Flutter: >=3.3.0

### Dependencies
- TensorFlow Lite 2.14.0 for both platforms
- plugin_platform_interface ^2.0.2

### Notes
- Current implementation uses simplified face detection (for demonstration)
- For production, integrate professional face detection (ML Kit, MTCNN, Vision Framework)
- Feature extraction is production-ready using MobileFaceNet
- Requires mobilefacenet.tflite model file (not included, see MODEL_GUIDE.md)
