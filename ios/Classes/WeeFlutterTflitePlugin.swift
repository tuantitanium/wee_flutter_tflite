import Flutter
import UIKit

enum DefaultConstants {
  static let threadCount = 4
  
}

public class WeeFlutterTflitePlugin: NSObject, FlutterPlugin {
  var registrar: FlutterPluginRegistrar!
  var channel: FlutterMethodChannel!
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "wee_flutter_tflite", binaryMessenger: registrar.messenger())
    let instance = WeeFlutterTflitePlugin()
    instance.registrar = registrar
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  
  var imageClassifierHelper : ImageClassificationHelper!
  
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      let args = call.arguments as! Dictionary<String,Any>
      let modelPath = args["model"] as! String
      let type = args["type"] as! Int
      let maxResult = args["maxResult"] as! Int
      let scoreTheshold = args["scoreThreshold"] as! Double
      let key = registrar.lookupKey(forAsset: modelPath)
      let path = Bundle.main.path(forResource: key, ofType: nil)
      
      
      imageClassifierHelper = ImageClassificationHelper(modelPath: path!, threadCount: DefaultConstants.threadCount, resultCount: maxResult, scoreThreshold: Float(scoreTheshold))
    case "detection":
      let args = call.arguments as! Dictionary<String,Any>
      let imagePath = args["imageFilePath"] as! String
      let uiimage = UIImage(contentsOfFile: imagePath)!
      let pixel = pixelBufferFromImage(image: uiimage)
      
      if let result = self.imageClassifierHelper?.classify(frame: pixel){
        self.channel.invokeMethod("detectionResult", arguments: ["time": result.inferenceTime, "data": result.data.map({ cat in
          return ["label": cat.label, "score": cat.score] as [String : Any]
        })])
      }else{
        self.channel.invokeMethod("detectionResult", arguments: ["time": 0, "data": []] as [String : Any])
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer {
    let ciimage = CIImage(image: image)
    //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
    let tmpcontext = CIContext(options: nil)
    let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
    
    let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
    let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
    let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
    let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
    let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
    let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
    keysPointer.initialize(to: keys)
    valuesPointer.initialize(to: values)
    
    let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
    
    let width = cgimage!.width
    let height = cgimage!.height
    
    var pxbuffer: CVPixelBuffer?
    // if pxbuffer = nil, you will get status = -6661
    var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                     kCVPixelFormatType_32BGRA, options, &pxbuffer)
    status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
    
    let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);
    
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
    let context = CGContext(data: bufferAddress,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: bytesperrow,
                            space: rgbColorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
    context?.concatenate(CGAffineTransform(rotationAngle: 0))
    context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
    //        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
    
    
    context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
    status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
    return pxbuffer!;
    
  }
}
