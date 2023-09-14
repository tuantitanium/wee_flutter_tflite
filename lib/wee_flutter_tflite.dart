import 'wee_flutter_tflite_platform_interface.dart';

enum TFLiteUsing {
  CPU(0),
  GPU(1),
  NNAPI(2);

  const TFLiteUsing(this.value);

  final int value;
}

class DetectionResult{
  double time;
  List<String> data;
  DetectionResult(this.time, this.data);

  factory DetectionResult.fromMap(Map map){
    return DetectionResult(double.parse(map["time"].toString()), (map["data"] as List).map((e) => (e as Map)["label"].toString()).toList());
  }
}

class WeeFlutterTflite {
  // modelPath: 'assets/...
  // Chỉ dùng với model có sẵn label tích hợp
  static void init({
    required String modelPath,
    TFLiteUsing using = TFLiteUsing.CPU,
    int maxResult = 10,
    double scoreThreshold = 0,
  }) {
    return WeeFlutterTflitePlatform.instance.init(
      modelPath,
      using,
      maxResult,
      scoreThreshold,
    );
  }

  static Future<DetectionResult> detect(String imageFilePath) {
    return WeeFlutterTflitePlatform.instance.detection(imageFilePath);
  }
}
