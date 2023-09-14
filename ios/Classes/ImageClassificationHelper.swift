
import TensorFlowLiteTaskVision
import UIKit

/// A result from the `Classifications`.
struct ImageClassificationResult {
  let inferenceTime: Double
  let data: [ClassificationCategory]
}

/// Information about a model file or labels file.
typealias FileInfo = (name: String, extension: String)

/// This class handles all data preprocessing and makes calls to run inference on a given frame
/// by invoking the TFLite `ImageClassifier`. It then returns the top N results for a successful
/// inference.
class ImageClassificationHelper {

  // MARK: - Model Parameters

  /// TensorFlow Lite `Interpreter` object for performing inference on a given model.
  private var classifier: ImageClassifier

  /// Information about the alpha component in RGBA data.
  private let alphaComponent = (baseOffset: 4, moduloRemainder: 3)

  // MARK: - Initialization

  /// A failable initializer for `ClassificationHelper`. A new instance is created if the model and
  /// labels files are successfully loaded from the app's main bundle. Default `threadCount` is 1.
  init?(modelPath: String, threadCount: Int, resultCount: Int, scoreThreshold: Float) {
   

    // Configures the initialization options.
    let options = ImageClassifierOptions(modelPath: modelPath)
    options.baseOptions.computeSettings.cpuSettings.numThreads = threadCount
    options.classificationOptions.maxResults = resultCount
    options.classificationOptions.scoreThreshold = scoreThreshold

    do {
      classifier = try ImageClassifier.classifier(options: options)
    } catch let error {
      print("Failed to create the interpreter with error: \(error.localizedDescription)")
      return nil
    }
  }

  // MARK: - Internal Methods

  /// Performs image preprocessing, invokes the `ImageClassifier`, and processes the inference
  /// results.
  func classify(frame pixelBuffer: CVPixelBuffer) -> ImageClassificationResult? {
    // Convert the `CVPixelBuffer` object to an `MLImage` object.
    guard let mlImage = MLImage(pixelBuffer: pixelBuffer) else { return nil }

    // Run inference using the `ImageClassifier{ object.
    do {
      let startDate = Date()
      let classificationResults = try classifier.classify(mlImage: mlImage)
      let inferenceTime = Date().timeIntervalSince(startDate) * 1000

      // As all models used in this sample app are single-head models, gets the classification
      // result from the first (and only) classification head and return to the view controller to
      // display.
      guard let classifications = classificationResults.classifications.first else { return ImageClassificationResult(
        inferenceTime: inferenceTime, data: []) }
      return ImageClassificationResult(
        inferenceTime: inferenceTime, data: classifications.categories)
    } catch let error {
      print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
      return nil
    }
  }
}
