# face_plugin

A Flutter plugin for **face detection** and **face feature extraction** on Android and iOS.

- **Detection** — Google ML Kit (Android) / Apple Vision (iOS)
- **Feature extraction** — MobileFaceNet TFLite model (bundled, no download required)
- **Output** — bounding box, 5-point landmarks, 192-dim feature vector, quality signals

---

## Requirements

| Requirement | Minimum |
|-------------|---------|
| Flutter     | 3.3.0   |
| Dart SDK    | 3.0.0   |
| Android     | API 21 (Android 5.0) |
| iOS         | 12.0    |

---

## Platform Support

| Platform | Detection Engine        | Min Version |
|----------|------------------------|-------------|
| Android  | Google ML Kit          | API 21 (Android 5.0) |
| iOS      | Apple Vision Framework | iOS 12.0    |

---

## Installation

```yaml
dependencies:
  face_plugin: ^0.0.2
```

### Android

No extra configuration needed. The TFLite model is bundled in `android/src/main/assets/`.

Make sure your app's `build.gradle` has:

```groovy
android {
    defaultConfig {
        minSdk 21
    }
}
```

### iOS

Add the following to your `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

The TFLite model is bundled inside the plugin pod (`ios/Classes/mobilefacenet.tflite`).
No additional steps are needed — CocoaPods handles everything automatically.

> **iOS AppDelegate tip — BGRA frame → JPEG**
>
> If you are feeding raw camera frames (e.g. from a `CameraImage` in BGRA format) into the plugin,
> you need to convert them to JPEG first. Add a native helper in your `AppDelegate.swift`:
>
> ```swift
> @main
> @objc class AppDelegate: FlutterAppDelegate {
>   override func application(
>     _ application: UIApplication,
>     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
>   ) -> Bool {
>     GeneratedPluginRegistrant.register(with: self)
> 
>     let controller = window?.rootViewController as! FlutterViewController
>     let channel = FlutterMethodChannel(
>       name: "com.yourapp/bridge",
>       binaryMessenger: controller.binaryMessenger)
> 
>     channel.setMethodCallHandler { (call, result) in
>       if call.method == "convertBgraToJpeg" {
>         guard let args = call.arguments as? [String: Any],
>               let bgraData  = args["bgraData"]  as? FlutterStandardTypedData,
>               let width     = args["width"]     as? Int,
>               let height    = args["height"]    as? Int else {
>           result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
>           return
>         }
>         let quality    = (args["quality"]     as? NSNumber)?.floatValue ?? 85.0
>         let bytesPerRow = args["bytesPerRow"] as? Int ?? (width * 4)
> 
>         DispatchQueue.global(qos: .userInitiated).async {
>           let jpegData = self.convertBgraToJpeg(
>             bgraData: bgraData.data, width: width, height: height,
>             bytesPerRow: bytesPerRow, quality: CGFloat(quality))
>           DispatchQueue.main.async {
>             if let jpeg = jpegData {
>               result(FlutterStandardTypedData(bytes: jpeg))
>             } else {
>               result(FlutterError(code: "CONVERT_FAILED",
>                                   message: "BGRA to JPEG conversion failed", details: nil))
>             }
>           }
>         }
>       } else {
>         result(FlutterMethodNotImplemented)
>       }
>     }
> 
>     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
>   }
> 
>   private func convertBgraToJpeg(bgraData: Data, width: Int, height: Int,
>                                   bytesPerRow: Int, quality: CGFloat) -> Data? {
>     let colorSpace = CGColorSpaceCreateDeviceRGB()
>     guard let context = CGContext(
>       data: UnsafeMutableRawPointer(mutating: (bgraData as NSData).bytes),
>       width: width, height: height,
>       bitsPerComponent: 8, bytesPerRow: bytesPerRow,
>       space: colorSpace,
>       bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
>                   | CGBitmapInfo.byteOrder32Little.rawValue
>     ) else { return nil }
> 
>     guard let cgImage = context.makeImage() else { return nil }
> 
>     // iOS front camera BGRA frames need .rightMirrored to match Flutter landscape orientation
>     let orientedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .rightMirrored)
> 
>     // Re-draw to bake the orientation into actual pixel data
>     let size = orientedImage.size
>     UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
>     orientedImage.draw(in: CGRect(origin: .zero, size: size))
>     let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
>     UIGraphicsEndImageContext()
> 
>     return renderedImage?.jpegData(compressionQuality: quality / 100.0)
>   }
> }
> ```

---

## API

```dart
// Detect faces — returns List<Face>
final List<Face> faces = await FacePlugin.detectFaces(imageBytes);

// Extract MobileFaceNet embeddings — returns List<List<double>>
// Index i corresponds to faces[i]
final List<List<double>> features = await FacePlugin.extractFeatures(imageBytes);
```

### `Face` model

```dart
class Face {
  // Bounding box — origin: top-left of image, X→right, Y→down
  final double faceX;   // left edge (px)
  final double faceY;   // top edge (px)
  final double bboxW;   // width (px)
  final double bboxH;   // height (px)

  // 5-point landmarks (px, same coordinate system)
  final double reyeX, reyeY;    // right eye
  final double leyeX, leyeY;    // left eye
  final double noseX, noseY;    // nose base
  final double rmouthX, rmouthY; // right mouth corner
  final double lmouthX, lmouthY; // left mouth corner

  // Image size
  final double width;   // full image width
  final double height;  // full image height

  // Quality signals
  final double faceScore;       // landmarkCount / 5  (0.0–1.0)
  final int    landmarkCount;   // how many of the 5 landmarks ML Kit actually detected
  final int    faceTv;          // ML Kit trackingId (-1 if unavailable)
  final int    clsId;           // always 0

  // Head pose (degrees)
  final double headEulerAngleX; // pitch (nodding)
  final double headEulerAngleY; // yaw   (turning left/right)
  final double headEulerAngleZ; // roll  (tilting)
}
```

---

## Quick example

```dart
import 'package:face_plugin/face_plugin.dart';

Future<void> run(Uint8List jpeg) async {
  final faces = await FacePlugin.detectFaces(jpeg);
  if (faces.isEmpty) return;

  final features = await FacePlugin.extractFeatures(jpeg);

  for (int i = 0; i < faces.length; i++) {
    final f = faces[i];
    print('Face $i  bbox=(${f.faceX.toInt()},${f.faceY.toInt()}) '
          '${f.bboxW.toInt()}x${f.bboxH.toInt()}  '
          'landmarks=${f.landmarkCount}/5  '
          'yaw=${f.headEulerAngleY.toStringAsFixed(1)}°');
    print('  embedding[0..4] = ${features[i].take(5).toList()}');
  }
}
```

---

## Advanced — FaceHelper & FaceTracker

For production use (continuous camera frames) the library ships with a ready-to-copy
utility that adds **two-layer false-positive filtering**:

1. **`landmarkCount` gate** — drops detections with fewer than 2 real landmarks
2. **`FaceTracker`** — requires a `trackingId` to appear in ≥ 2 consecutive frames before
   being considered a real face; removes transient noise that appears for only 1–2 frames

Copy the following files into your project (they depend on `face_plugin` but are
**not** shipped as part of the package because they reference project-specific types):

### `face_helper.dart`

```dart
import 'dart:math';
import 'dart:typed_data';
import 'package:face_plugin/face_plugin.dart';

// ──────────────────────────────────────────────
// FaceTracker — consecutive-frame confirmation
// ──────────────────────────────────────────────

class _TrackingState {
  int consecutiveCount = 0;
  DateTime lastSeen = DateTime.now();
  bool confirmed = false;
}

/// Filters transient false-positive detections by requiring a trackingId to
/// appear in at least [confirmFrames] consecutive frames before being trusted.
class FaceTracker {
  static const int confirmFrames = 2;
  static const Duration expireDuration = Duration(milliseconds: 500);

  final Map<int, _TrackingState> _states = {};
  DateTime? _lastUpdateTime;

  /// Feed the current-frame faces (pre-filtered by landmarkCount).
  /// Returns only confirmed faces.
  List<Face> updateAndFilter(List<Face> faces) {
    final now = DateTime.now();
    final shouldUpdate = _lastUpdateTime == null ||
        now.difference(_lastUpdateTime!) > const Duration(milliseconds: 50);

    final currentIds = <int>{};
    final confirmed = <Face>[];

    for (final face in faces) {
      final id = face.faceTv;
      if (id < 0) { confirmed.add(face); continue; }  // no trackingId → pass through

      currentIds.add(id);

      if (shouldUpdate) {
        final state = _states.putIfAbsent(id, () => _TrackingState());
        state.consecutiveCount++;
        state.lastSeen = now;
        if (!state.confirmed && state.consecutiveCount >= confirmFrames) {
          state.confirmed = true;
        }
      }

      if (_states[id]?.confirmed ?? false) confirmed.add(face);
    }

    if (shouldUpdate) {
      _lastUpdateTime = now;
      final toRemove = <int>[];
      _states.forEach((id, state) {
        if (!currentIds.contains(id)) {
          if (now.difference(state.lastSeen) > expireDuration) {
            toRemove.add(id);
          } else if (!state.confirmed) {
            state.consecutiveCount = 0;
          }
        }
      });
      toRemove.forEach(_states.remove);
    }

    return confirmed;
  }

  void reset() { _states.clear(); _lastUpdateTime = null; }
  int get confirmedCount => _states.values.where((s) => s.confirmed).length;
}

// ──────────────────────────────────────────────
// FaceHelper — detect / extract best face
// ──────────────────────────────────────────────

class FaceHelper {
  static const double centerWeight = 0.3;
  static const double areaWeight   = 0.5;
  static const double scoreWeight  = 0.2;
  static const int    MIN_LANDMARK_COUNT = 2;

  static final FaceTracker _tracker = FaceTracker();

  static void resetTracker() => _tracker.reset();

  /// Returns true when a Face has enough real landmarks to be trusted.
  static bool isValidFace(Face face) => face.landmarkCount >= MIN_LANDMARK_COUNT;

  // ── detect ──────────────────────────────────

  /// Detects faces in [imageData] (JPEG bytes) and returns the best one,
  /// or `null` if no valid face is found.
  static Future<Face?> detectBestFace(Uint8List imageData) async {
    final faces = await FacePlugin.detectFaces(imageData);
    if (faces.isEmpty) { _tracker.updateAndFilter([]); return null; }

    final landmarkValid = faces.where(isValidFace).toList();
    if (landmarkValid.isEmpty) { _tracker.updateAndFilter([]); return null; }

    final confirmed = _tracker.updateAndFilter(landmarkValid);
    if (confirmed.isEmpty) return null;

    return confirmed.length == 1 ? confirmed.first : _selectBestFace(confirmed);
  }

  // ── extract ─────────────────────────────────

  /// Detects faces **and** extracts embeddings in parallel, then returns the
  /// embedding that corresponds to the best valid face.
  static Future<List<double>?> extractBestFeature(Uint8List imageData) async {
    final results = await Future.wait([
      FacePlugin.detectFaces(imageData),
      FacePlugin.extractFeatures(imageData),
    ]);

    final faces    = results[0] as List<Face>;
    final features = results[1] as List<List<double>>;

    if (faces.isEmpty || features.isEmpty) return null;

    // Build index-preserving map of valid faces
    final validEntries = <int, Face>{};
    for (int i = 0; i < faces.length; i++) {
      if (isValidFace(faces[i])) validEntries[i] = faces[i];
    }
    if (validEntries.isEmpty) return null;

    final confirmed = _tracker.updateAndFilter(validEntries.values.toList());
    if (confirmed.isEmpty) return null;

    // Find original index of best confirmed face
    final confirmedEntries = Map.fromEntries(
      validEntries.entries.where((e) => confirmed.contains(e.value)),
    );

    final bestFace  = _selectBestFace(confirmedEntries.values.toList());
    final bestIndex = faces.indexOf(bestFace);

    if (bestIndex >= 0 && bestIndex < features.length) return features[bestIndex];
    return features.isNotEmpty ? features.first : null;
  }

  // ── internals ───────────────────────────────

  static Face _selectBestFace(List<Face> faces) {
    if (faces.length == 1) return faces.first;
    final w = faces.first.width;
    final h = faces.first.height;
    return faces.reduce((a, b) =>
        _score(a, w, h) >= _score(b, w, h) ? a : b);
  }

  static double _score(Face f, double w, double h) {
    final area   = (f.bboxW * f.bboxH) / (w * h);
    final dx     = (f.faceX + f.bboxW / 2 - w / 2) / (w / 2);
    final dy     = (f.faceY + f.bboxH / 2 - h / 2) / (h / 2);
    final center = (1.0 - sqrt(dx * dx + dy * dy) / 1.4).clamp(0.0, 1.0);
    return area * areaWeight + center * centerWeight + f.faceScore * scoreWeight;
  }
}
```

### Usage

```dart
// Detect only
final Face? face = await FaceHelper.detectBestFace(jpegBytes);

// Detect + extract embedding (parallel, one image read)
final List<double>? embedding = await FaceHelper.extractBestFeature(jpegBytes);

// Compare two embeddings (cosine similarity)
double cosineSim(List<double> a, List<double> b) {
  double dot = 0, na = 0, nb = 0;
  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na  += a[i] * a[i];
    nb  += b[i] * b[i];
  }
  return dot / (sqrt(na) * sqrt(nb));
}

// sim >= 0.5  → likely the same person
// sim <  0.3  → different persons
```

### Quality filtering tips

```dart
// Filter low-quality detections before comparison
final goodFaces = faces.where((f) =>
  f.landmarkCount >= 3 &&          // at least 3 real landmarks
  f.headEulerAngleY.abs() < 30 &&  // not turned more than 30° sideways
  f.faceScore >= 0.6,              // ≥ 3/5 landmarks
).toList();
```

---

## Coordinate system

```
(0,0) ──────────────────► X
  │
  │      ┌────────────┐
  │      │ faceX,faceY│
  │      │            │
  │      │  bboxW     │
  │      └────────────┘
  ▼ Y
```

- Origin **top-left** of the image
- All values in **pixels**
- Landmark coordinates share the same origin

---

## Embedding comparison

```
Cosine similarity ≥ 0.50  →  same person (recommended threshold)
Cosine similarity <  0.30  →  different persons
0.30 – 0.50               →  uncertain
```

Tune the threshold for your use case. Higher thresholds reduce false accepts;
lower thresholds reduce false rejects.

---

## License

MIT — see [LICENSE](LICENSE)
