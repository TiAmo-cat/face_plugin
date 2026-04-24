# Changelog

All notable changes to this project will be documented in this file.

## [0.0.2] - 2026-04-24

### Added
- `Face.landmarkCount` — number of landmarks actually detected by ML Kit (0–5).
  Use as a quality gate to filter false-positive detections.
- `Face.headEulerAngleX/Y/Z` — head pose angles from ML Kit (pitch / yaw / roll, degrees).
  Useful for rejecting non-frontal faces before feature extraction.

### Changed
- `Face.faceScore` is now `landmarkCount / 5.0` (real quality signal) instead of a
  hardcoded `1.0`.
- `Face.faceTv` returns `-1` (not `0`) when ML Kit tracking is unavailable, avoiding
  confusion with a real `trackingId = 0`.
- Android: `FEATURE_DIM` changed from a `static` field to an instance field so each
  plugin instance independently auto-detects the model output shape on attach.
  Fixes a shape mismatch crash (`[1,192] vs [1,128]`) on models with 192-dim output.
- Android: `detectFaces` and `extractFeatures` now decode the image and run ML Kit
  on a background `ExecutorService` thread, with results posted back to the main thread.
  Eliminates potential "Must not be called on the main application thread" errors and
  keeps large-image decoding off the UI thread.
- Cleaned up documentation: removed all intermediate dev/debug markdown files.
  The repository now contains only `README.md` and `CHANGELOG.md`.

### Fixed
- Unit tests (`test/`) rewrote to cover the actual `detectFaces` / `extractFeatures` API
  instead of the removed `getPlatformVersion()` stub.
- Integration test (`example/integration_test/`) updated accordingly.

---

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
