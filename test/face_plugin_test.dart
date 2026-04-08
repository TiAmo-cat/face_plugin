import 'package:flutter_test/flutter_test.dart';
import 'package:face_plugin/face_plugin.dart';
import 'package:face_plugin/face_plugin_platform_interface.dart';
import 'package:face_plugin/face_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFacePluginPlatform
    with MockPlatformInterfaceMixin
    implements FacePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FacePluginPlatform initialPlatform = FacePluginPlatform.instance;

  test('$MethodChannelFacePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFacePlugin>());
  });

  test('getPlatformVersion', () async {
    FacePlugin facePlugin = FacePlugin();
    MockFacePluginPlatform fakePlatform = MockFacePluginPlatform();
    FacePluginPlatform.instance = fakePlatform;

    expect(await facePlugin.getPlatformVersion(), '42');
  });
}
