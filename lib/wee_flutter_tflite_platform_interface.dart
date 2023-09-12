import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wee_flutter_tflite/wee_flutter_tflite.dart';

import 'wee_flutter_tflite_method_channel.dart';

abstract class WeeFlutterTflitePlatform extends PlatformInterface {
  WeeFlutterTflitePlatform() : super(token: _token);

  static final Object _token = Object();

  static WeeFlutterTflitePlatform _instance = MethodChannelWeeFlutterTflite();

  static WeeFlutterTflitePlatform get instance => _instance;

  static set instance(WeeFlutterTflitePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void init(TFLiteUsing using, int maxResult){
    instance.init(using, maxResult);
  }
}
