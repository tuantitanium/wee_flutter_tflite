
import 'wee_flutter_tflite_platform_interface.dart';


enum TFLiteUsing{
  CPU(0),
  GPU(1),
  NNAPI(2);

  const TFLiteUsing(this.value);
  final int value;

}



class WeeFlutterTflite {
  void init(TFLiteUsing using, {int maxResult = 10}) {
    return WeeFlutterTflitePlatform.instance.init(using, maxResult);
  }
}
