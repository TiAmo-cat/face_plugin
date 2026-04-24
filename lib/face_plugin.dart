import 'dart:typed_data';
import 'face_plugin_platform_interface.dart';

/// Face detection and feature extraction result
///
/// Coordinate system: origin (0,0) at top-left of image, X→right, Y→down.
/// [faceX], [faceY] = top-left corner of the bounding box (pixels).
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

  /// Number of landmarks actually detected by ML Kit (0–5).
  /// Covers: leftEye, rightEye, noseBase, leftMouth, rightMouth.
  /// A low value (0–1) is a strong indicator of a false-positive detection.
  final int landmarkCount;

  /// Head rotation angles reported by ML Kit (degrees).
  /// Useful for quality checks — extreme values may indicate a non-frontal or
  /// low-quality face crop before feeding into MobileFaceNet.
  final double headEulerAngleX;
  final double headEulerAngleY;
  final double headEulerAngleZ;

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
    this.landmarkCount = 5,
    this.headEulerAngleX = 0.0,
    this.headEulerAngleY = 0.0,
    this.headEulerAngleZ = 0.0,
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
      faceTv: (map['faceTv'] as int?) ?? -1,
      clsId: map['clsId'] as int,
      landmarkCount: (map['landmarkCount'] as int?) ?? 5,
      headEulerAngleX: (map['headEulerAngleX'] as num?)?.toDouble() ?? 0.0,
      headEulerAngleY: (map['headEulerAngleY'] as num?)?.toDouble() ?? 0.0,
      headEulerAngleZ: (map['headEulerAngleZ'] as num?)?.toDouble() ?? 0.0,
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
      'landmarkCount': landmarkCount,
      'headEulerAngleX': headEulerAngleX,
      'headEulerAngleY': headEulerAngleY,
      'headEulerAngleZ': headEulerAngleZ,
    };
  }
}

/// FacePlugin — Face detection (ML Kit) + feature extraction (MobileFaceNet).
class FacePlugin {
  /// Detect all faces in the image.
  /// Returns a list of [Face] objects containing bounding boxes, landmarks,
  /// quality signals ([landmarkCount], [Face.faceScore]) and head angles.
  static Future<List<Face>> detectFaces(Uint8List imageBytes) async {
    return await FacePluginPlatform.instance.detectFaces(imageBytes);
  }

  /// Extract feature vectors for each detected face.
  /// Returns a [List<List<double>>] where each inner list is the MobileFaceNet
  /// embedding for the corresponding face in [detectFaces] order.
  /// The vector length equals the model's output dimension (typically 192).
  static Future<List<List<double>>> extractFeatures(Uint8List imageBytes) async {
    return await FacePluginPlatform.instance.extractFeatures(imageBytes);
  }
}
