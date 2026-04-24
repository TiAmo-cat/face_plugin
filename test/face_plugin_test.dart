import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:face_plugin/face_plugin.dart';
import 'package:face_plugin/face_plugin_platform_interface.dart';
import 'package:face_plugin/face_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock platform that returns predefined results
class MockFacePluginPlatform
    with MockPlatformInterfaceMixin
    implements FacePluginPlatform {
  @override
  Future<List<Face>> detectFaces(Uint8List imageBytes) async {
    return [
      Face(
        faceX: 100, faceY: 80, bboxW: 120, bboxH: 130,
        reyeX: 130, reyeY: 110, leyeX: 190, leyeY: 110,
        noseX: 160, noseY: 145,
        rmouthX: 135, rmouthY: 175, lmouthX: 185, lmouthY: 175,
        width: 640, height: 480,
        faceScore: 0.98, faceTv: 1, clsId: 0,
        landmarkCount: 5,
        headEulerAngleX: 2.0, headEulerAngleY: -3.0, headEulerAngleZ: 1.5,
      )
    ];
  }

  @override
  Future<List<List<double>>> extractFeatures(Uint8List imageBytes) async {
    return [List.filled(192, 0.01)];
  }
}

void main() {
  final FacePluginPlatform initialPlatform = FacePluginPlatform.instance;

  test('$MethodChannelFacePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFacePlugin>());
  });

  group('FacePlugin API', () {
    setUp(() {
      FacePluginPlatform.instance = MockFacePluginPlatform();
    });

    test('detectFaces returns list of Face objects', () async {
      final faces = await FacePlugin.detectFaces(Uint8List(0));
      expect(faces.length, 1);
      expect(faces[0].faceX, 100);
      expect(faces[0].faceY, 80);
      expect(faces[0].bboxW, 120);
      expect(faces[0].faceScore, 0.98);
      expect(faces[0].landmarkCount, 5);
      expect(faces[0].headEulerAngleY, -3.0);
    });

    test('extractFeatures returns feature vectors', () async {
      final features = await FacePlugin.extractFeatures(Uint8List(0));
      expect(features.length, 1);
      expect(features[0].length, 192);
    });

    test('Face.fromMap parses correctly', () {
      final map = <dynamic, dynamic>{
        'faceX': 10.0, 'faceY': 20.0, 'bboxW': 100.0, 'bboxH': 110.0,
        'reyeX': 30.0, 'reyeY': 50.0, 'leyeX': 80.0, 'leyeY': 50.0,
        'noseX': 55.0, 'noseY': 75.0,
        'rmouthX': 35.0, 'rmouthY': 100.0, 'lmouthX': 75.0, 'lmouthY': 100.0,
        'width': 640.0, 'height': 480.0,
        'faceScore': 0.95, 'faceTv': 2, 'clsId': 0,
        'landmarkCount': 4,
        'headEulerAngleX': 1.0, 'headEulerAngleY': -5.0, 'headEulerAngleZ': 2.0,
      };
      final face = Face.fromMap(map);
      expect(face.faceX, 10.0);
      expect(face.bboxW, 100.0);
      expect(face.faceScore, 0.95);
      expect(face.faceTv, 2);
      expect(face.landmarkCount, 4);
      expect(face.headEulerAngleY, -5.0);
    });

    test('Face.toMap round-trips correctly', () {
      final original = Face(
        faceX: 10, faceY: 20, bboxW: 100, bboxH: 110,
        reyeX: 30, reyeY: 50, leyeX: 80, leyeY: 50,
        noseX: 55, noseY: 75,
        rmouthX: 35, rmouthY: 100, lmouthX: 75, lmouthY: 100,
        width: 640, height: 480,
        faceScore: 0.95, faceTv: 2, clsId: 0,
        landmarkCount: 3,
        headEulerAngleX: 1.0, headEulerAngleY: -5.0, headEulerAngleZ: 2.0,
      );
      final restored = Face.fromMap(original.toMap());
      expect(restored.faceX, original.faceX);
      expect(restored.faceScore, original.faceScore);
      expect(restored.landmarkCount, original.landmarkCount);
      expect(restored.headEulerAngleY, original.headEulerAngleY);
    });
  });
}
