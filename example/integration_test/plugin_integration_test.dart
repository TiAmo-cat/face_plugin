// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:face_plugin/face_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('detectFaces returns a list (may be empty on blank image)',
      (WidgetTester tester) async {
    // Use the sample asset bundled with the example app.
    // If the image contains a face, the list will be non-empty.
    final ByteData data =
        await rootBundle.load('assets/sample_face.jpg');
    final Uint8List imageBytes = data.buffer.asUint8List();

    final List<Face> faces = await FacePlugin.detectFaces(imageBytes);

    // Should not throw — result is always a list (possibly empty).
    expect(faces, isA<List<Face>>());

    if (faces.isNotEmpty) {
      final Face f = faces.first;
      // Bounding box must be positive
      expect(f.bboxW, greaterThan(0));
      expect(f.bboxH, greaterThan(0));
      // faceScore is landmarkCount / 5, so in [0.0, 1.0]
      expect(f.faceScore, inInclusiveRange(0.0, 1.0));
      // landmarkCount is 0-5
      expect(f.landmarkCount, inInclusiveRange(0, 5));
    }
  });

  testWidgets('extractFeatures returns vectors matching detected faces',
      (WidgetTester tester) async {
    final ByteData data =
        await rootBundle.load('assets/sample_face.jpg');
    final Uint8List imageBytes = data.buffer.asUint8List();

    final List<Face> faces = await FacePlugin.detectFaces(imageBytes);
    final List<List<double>> features =
        await FacePlugin.extractFeatures(imageBytes);

    // Feature vector count must match detected face count.
    expect(features.length, equals(faces.length));

    for (final List<double> vec in features) {
      // MobileFaceNet output is typically 128 or 192 floats.
      expect(vec.length, greaterThan(0));
      // Values are normalised floats, not all zero.
      expect(vec.any((v) => v != 0.0), isTrue);
    }
  });
}
