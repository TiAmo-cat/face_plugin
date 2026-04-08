import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'face_plugin_platform_interface.dart';
import 'face_plugin.dart';

/// An implementation of [FacePluginPlatform] that uses method channels.
class MethodChannelFacePlugin extends FacePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('face_plugin');

  @override
  Future<List<Face>> detectFaces(Uint8List imageBytes) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'detectFaces',
      {'imageBytes': imageBytes},
    );

    if (result == null) {
      return [];
    }

    return result.map((faceData) => Face.fromMap(faceData as Map<dynamic, dynamic>)).toList();
  }

  @override
  Future<List<List<double>>> extractFeatures(Uint8List imageBytes) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'extractFeatures',
      {'imageBytes': imageBytes},
    );

    if (result == null) {
      return [];
    }

    return result.map((feature) {
      final featureList = feature as List<dynamic>;
      return featureList.map((value) => (value as num).toDouble()).toList();
    }).toList();
  }
}
