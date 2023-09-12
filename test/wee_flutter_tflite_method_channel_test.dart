import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wee_flutter_tflite/wee_flutter_tflite_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWeeFlutterTflite platform = MethodChannelWeeFlutterTflite();
  const MethodChannel channel = MethodChannel('wee_flutter_tflite');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
