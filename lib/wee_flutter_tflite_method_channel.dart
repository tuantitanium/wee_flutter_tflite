import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wee_flutter_tflite.dart';
import 'wee_flutter_tflite_platform_interface.dart';

class MethodChannelWeeFlutterTflite extends WeeFlutterTflitePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('wee_flutter_tflite');

  @override
  void init(TFLiteUsing using, int maxResult) {
    methodChannel.invokeMethod("init", {
      "type": using.value,
      "maxResult": maxResult,
    });
  }
}
