# Changelog

All notable changes to this project will be documented in this file.

## [0.0.4] - 2026-05-21

### Changed
- **Relaxed SDK constraints**: lowered Flutter requirement from `>=3.3.0` (effectively 3.27.x due to `sdk: ^3.6.0`) to `>=3.10.0`, Dart SDK from `^3.6.0` to `>=3.0.0 <4.0.0`. The plugin has no Dart 3.x exclusive syntax, so projects using Flutter 3.10+ can now use `face_plugin` without forced upgrade.
- Synchronized `ios/face_plugin.podspec` version to `0.0.4`.
- Lowered `flutter_lints` from `^5.0.0` to `^4.0.0` for Dart 3.0+ compatibility.
- Lowered `compileSdk` from 35 to 34 for broader Flutter version support.
- Raised example app Java compatibility from 1.8 to 11 to match plugin.

### Fixed
- `pubspec.yaml` Dart SDK constraint no longer conflicts with the Flutter version constraint.
- Enabled `PrivacyInfo.xcprivacy` in podspec for Apple privacy manifest compliance.
- Removed hardcoded HTTP proxy settings from example `gradle.properties`.
- Removed aliyun Maven mirrors from Gradle repositories for global compatibility.
- Added Podfile to example iOS project so `pod install` works out of the box.
- Removed stale unit tests that tested removed `getPlatformVersion` API.

---

## [0.0.3] - 2026-05-12

### Added
- **L2 normalization** for feature vectors on both Android and iOS platforms.
  Ensures cosine similarity equals dot product for accurate face comparison.
- **Head pose angles** (`headEulerAngleX/Y/Z`) support on iOS via Vision Framework.
  Now consistent with Android — enables cross-platform quality filtering.
- **Advanced utility classes** documented in README:
  - `FaceHelper` — best face selection with center/area/score weighting
  - `FaceTracker` — consecutive-frame confirmation to filter transient false positives
  - Quality filtering examples using `landmarkCount` and head angles

### Changed
- **Android**: Removed background thread execution for ML Kit detection.
  Simplified threading model — ML Kit handles async internally.
- **Android**: Disabled `enableTracking()` to prevent "ghost detection" issue
  where faces persist after leaving the frame.
- **Android**: Raised `minFaceSize` from 0.15 to 0.20 to reduce small noise detections.
- **iOS**: Fixed coordinate system to use `image.size` instead of `cgImage` dimensions.
- **iOS**: Improved `landmarkCount` calculation accuracy for better quality signals.
- **iOS**: Simplified model loading — removed redundant asset lookup fallback.
- **iOS**: `faceScore` now uses `observation.confidence` directly (more reliable).
- Updated README with comprehensive production-ready examples and iOS BGRA→JPEG guide.

### Fixed
- Feature vector normalization ensures consistent similarity scores across platforms.
- iOS head angle availability check for iOS 16+ pitch support.
- Documentation clarity: removed intermediate dev files, consolidated into single README.

---

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
