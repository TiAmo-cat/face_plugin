import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'face_plugin_method_channel.dart';
import 'face_plugin.dart';

abstract class FacePluginPlatform extends PlatformInterface {
  /// Constructs a FacePluginPlatform.
  FacePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FacePluginPlatform _instance = MethodChannelFacePlugin();

  /// The default instance of [FacePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFacePlugin].
  static FacePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FacePluginPlatform] when
  /// they register themselves.
  static set instance(FacePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Face>> detectFaces(Uint8List imageBytes) {
    throw UnimplementedError('detectFaces() has not been implemented.');
  }

  Future<List<List<double>>> extractFeatures(Uint8List imageBytes) {
    throw UnimplementedError('extractFeatures() has not been implemented.');
  }
}
