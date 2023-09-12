import 'package:flutter_test/flutter_test.dart';
import 'package:wee_flutter_tflite/wee_flutter_tflite.dart';
import 'package:wee_flutter_tflite/wee_flutter_tflite_platform_interface.dart';
import 'package:wee_flutter_tflite/wee_flutter_tflite_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWeeFlutterTflitePlatform
    with MockPlatformInterfaceMixin
    implements WeeFlutterTflitePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WeeFlutterTflitePlatform initialPlatform = WeeFlutterTflitePlatform.instance;

  test('$MethodChannelWeeFlutterTflite is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWeeFlutterTflite>());
  });

  test('getPlatformVersion', () async {
    WeeFlutterTflite weeFlutterTflitePlugin = WeeFlutterTflite();
    MockWeeFlutterTflitePlatform fakePlatform = MockWeeFlutterTflitePlatform();
    WeeFlutterTflitePlatform.instance = fakePlatform;

    expect(await weeFlutterTflitePlugin.getPlatformVersion(), '42');
  });
}
