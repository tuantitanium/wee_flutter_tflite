import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wee_flutter_tflite.dart';
import 'wee_flutter_tflite_platform_interface.dart';

class MethodChannelWeeFlutterTflite extends WeeFlutterTflitePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('wee_flutter_tflite');

  @override
  void init(
    String modelPath,
    TFLiteUsing using,
    int maxResult,
    double scoreThreshold,
  ) {
    methodChannel.invokeMethod("init", {
      "model": modelPath,
      "type": using.value,
      "maxResult": maxResult,
      "scoreThreshold": scoreThreshold,
    });
  }

  @override
  void initWithLabels(String modelPath, List<String> labels, TFLiteUsing using, int maxResult) {
    methodChannel.invokeMethod("initWithLabels", {
      "model": modelPath,
      "labels": labels,
      "type": using.value,
      "maxResult": maxResult,
    });
  }

  @override
  Future<DetectionResult> detection(String imageFilePath) async{


    return await Future.microtask(() async {
      var completer = Completer<DetectionResult>();
      methodChannel.setMethodCallHandler((call) {
        if (call.method == "detectionResult") {
          var args = call.arguments;
          completer.complete(DetectionResult.fromMap(args));
        }
        return completer.future;
      });
      methodChannel.invokeMethod("detection", {
        "imageFilePath": imageFilePath,
      });
      return completer.future;
    });
  }
}
