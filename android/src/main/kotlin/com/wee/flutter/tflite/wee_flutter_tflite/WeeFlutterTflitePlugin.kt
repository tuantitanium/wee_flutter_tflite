package com.wee.flutter.tflite.wee_flutter_tflite

import android.content.Context
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.tensorflow.lite.task.vision.classifier.Classifications


class WeeFlutterTflitePlugin : FlutterPlugin, MethodCallHandler,
    ImageClassifierHelper.ClassifierListener {

    final val tag = "WeeTFLite"

    private lateinit var channel: MethodChannel

    private lateinit var imageClassifierHelper: ImageClassifierHelper
    private lateinit var context: Context
    var inited = false


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wee_flutter_tflite")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                val type = call.arguments as Int
                imageClassifierHelper = ImageClassifierHelper(
                    context = context,
                    imageClassifierListener = this,
                    currentDelegate = type,
                )
                inited = true
            }

            else -> {
                Log.e(tag, "Method not implement ${call.method}")
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onError(error: String) {

    }

    override fun onResults(results: List<Classifications>?, inferenceTime: Long) {

    }
}
