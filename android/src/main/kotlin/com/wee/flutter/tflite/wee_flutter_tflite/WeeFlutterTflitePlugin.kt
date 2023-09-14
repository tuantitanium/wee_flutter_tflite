package com.wee.flutter.tflite.wee_flutter_tflite

import android.app.Activity
import android.content.Context
import android.graphics.BitmapFactory
import android.util.DisplayMetrics
import android.util.Log
import android.view.Display

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.tensorflow.lite.task.vision.classifier.Classifications


class WeeFlutterTflitePlugin : FlutterPlugin, MethodCallHandler,
    ImageClassifierHelper.ClassifierListener, ActivityAware {

    final val tag = "WeeTFLite"

    private lateinit var channel: MethodChannel

    private lateinit var imageClassifierHelper: ImageClassifierHelper
    private lateinit var context: Context
    var inited = false
    private lateinit var flutterPluginBinding: FlutterPluginBinding
    private lateinit var activity: Activity


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wee_flutter_tflite")
        channel.setMethodCallHandler(this)
    }

    private fun getScreenOrientation(): Int {
        val outMetrics = DisplayMetrics()

        val display: Display?
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            display = activity.display
            display?.getRealMetrics(outMetrics)
        } else {
            @Suppress("DEPRECATION")
            display = activity.windowManager.defaultDisplay
            @Suppress("DEPRECATION")
            display.getMetrics(outMetrics)
        }

        return display?.rotation ?: 0
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                val type = call.argument<Int>("type")!!
                val maxResult = call.argument<Int>("maxResult")!!
                val modelPath = call.argument<String>("model")!!
                val scoreThreshold = call.argument<Double>("scoreThreshold")!!

                val fassets = flutterPluginBinding.flutterAssets.getAssetFilePathByName(modelPath)

                imageClassifierHelper = ImageClassifierHelper(
                    context = context,
                    imageClassifierListener = this,
                    currentDelegate = type,
                    maxResults = maxResult,
                    modelPath = fassets,
                    scoreThreshold = scoreThreshold
                )
                inited = true
                Log.e(tag, "Init classifier");
            }

            "detection" -> {
                var filePath = call.argument<String>("imageFilePath")!!
                var result = imageClassifierHelper.classify(
                    BitmapFactory.decodeFile(filePath),
                    getScreenOrientation()
                )
                activity.runOnUiThread {
                    this.channel.invokeMethod(
                        "detectionResult", mapOf("time" to result.time,
                            "data" to result.data.map {
                                mapOf(
                                    "label" to it.label,
                                    "score" to it.score
                                )
                            })
                    )
                }

            }
//            "initWithLabels" ->{
//                val type = call.argument<Int>("type")!!
//                val maxResult = call.argument<Int>("maxResult")!!
//                val modelPath = call.argument<String>("model")!!
//                val labels = call.argument<ArrayList<String>>("labels")!!
//                val fassets = flutterPluginBinding.flutterAssets.getAssetFilePathByName(modelPath)
//
//                imageClassifierHelper = ImageClassifierHelper(
//                    context = context,
//                    imageClassifierListener = this,
//                    currentDelegate = type,
//                    maxResults = maxResult,
//                    listLabel = labels,
//                    modelPath = fassets,
//                )
//                inited = true
//            }

            else -> {
                Log.e(tag, "Method not implement ${call.method}")
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onError(error: String) {
        Log.e(tag, "Detect error")
    }

    override fun onResults(results: List<Classifications>?, inferenceTime: Long) {
        Log.e(tag, "Detect result ")

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }
}
