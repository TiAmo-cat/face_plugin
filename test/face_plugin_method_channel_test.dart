import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:face_plugin/face_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelFacePlugin platform = MethodChannelFacePlugin();
  const MethodChannel channel = MethodChannel('face_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'detectFaces':
          return [
            {
              'faceX': 10.0, 'faceY': 20.0, 'bboxW': 100.0, 'bboxH': 110.0,
              'reyeX': 30.0, 'reyeY': 50.0, 'leyeX': 80.0, 'leyeY': 50.0,
              'noseX': 55.0, 'noseY': 75.0,
              'rmouthX': 35.0, 'rmouthY': 100.0, 'lmouthX': 75.0, 'lmouthY': 100.0,
              'width': 640.0, 'height': 480.0,
              'faceScore': 0.95, 'faceTv': 1, 'clsId': 0,
            }
          ];
        case 'extractFeatures':
          return [List.filled(192, 0.01)];
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('detectFaces returns parsed Face list', () async {
    final faces = await platform.detectFaces(Uint8List(0));
    expect(faces.length, 1);
    expect(faces[0].faceX, 10.0);
    expect(faces[0].bboxW, 100.0);
  });

  test('extractFeatures returns feature vectors', () async {
    final features = await platform.extractFeatures(Uint8List(0));
    expect(features.length, 1);
    expect(features[0].length, 192);
  });
}
