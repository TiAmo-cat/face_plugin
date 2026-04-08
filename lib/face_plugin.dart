import 'dart:typed_data';
import 'face_plugin_platform_interface.dart';

/// Face detection and feature extraction result
class Face {
  final double faceX;
  final double faceY;
  final double bboxW;
  final double bboxH;

  final double reyeX;
  final double reyeY;
  final double leyeX;
  final double leyeY;
  final double noseX;
  final double noseY;
  final double rmouthX;
  final double rmouthY;
  final double lmouthX;
  final double lmouthY;

  final double width;
  final double height;

  final double faceScore;
  final int faceTv;
  final int clsId;

  Face({
    required this.faceX,
    required this.faceY,
    required this.bboxW,
    required this.bboxH,
    required this.reyeX,
    required this.reyeY,
    required this.leyeX,
    required this.leyeY,
    required this.noseX,
    required this.noseY,
    required this.rmouthX,
    required this.rmouthY,
    required this.lmouthX,
    required this.lmouthY,
    required this.width,
    required this.height,
    required this.faceScore,
    required this.faceTv,
    required this.clsId,
  });

  factory Face.fromMap(Map<dynamic, dynamic> map) {
    return Face(
      faceX: (map['faceX'] as num).toDouble(),
      faceY: (map['faceY'] as num).toDouble(),
      bboxW: (map['bboxW'] as num).toDouble(),
      bboxH: (map['bboxH'] as num).toDouble(),
      reyeX: (map['reyeX'] as num).toDouble(),
      reyeY: (map['reyeY'] as num).toDouble(),
      leyeX: (map['leyeX'] as num).toDouble(),
      leyeY: (map['leyeY'] as num).toDouble(),
      noseX: (map['noseX'] as num).toDouble(),
      noseY: (map['noseY'] as num).toDouble(),
      rmouthX: (map['rmouthX'] as num).toDouble(),
      rmouthY: (map['rmouthY'] as num).toDouble(),
      lmouthX: (map['lmouthX'] as num).toDouble(),
      lmouthY: (map['lmouthY'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      faceScore: (map['faceScore'] as num).toDouble(),
      faceTv: map['faceTv'] as int,
      clsId: map['clsId'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faceX': faceX,
      'faceY': faceY,
      'bboxW': bboxW,
      'bboxH': bboxH,
      'reyeX': reyeX,
      'reyeY': reyeY,
      'leyeX': leyeX,
      'leyeY': leyeY,
      'noseX': noseX,
      'noseY': noseY,
      'rmouthX': rmouthX,
      'rmouthY': rmouthY,
      'lmouthX': lmouthX,
      'lmouthY': lmouthY,
      'width': width,
      'height': height,
      'faceScore': faceScore,
      'faceTv': faceTv,
      'clsId': clsId,
    };
  }
}

/// FacePlugin - Face detection and feature extraction
class FacePlugin {
  /// Detect all faces in the image
  /// Returns a list of Face objects containing bounding boxes and landmarks
  static Future<List<Face>> detectFaces(Uint8List imageBytes) async {
    return await FacePluginPlatform.instance.detectFaces(imageBytes);
  }

  /// Extract 128-dimensional feature vectors for each detected face
  /// Returns a list of feature vectors, indexed corresponding to detectFaces results
  static Future<List<List<double>>> extractFeatures(Uint8List imageBytes) async {
    return await FacePluginPlatform.instance.extractFeatures(imageBytes);
  }
}
