package com.pflibwrapper

import android.graphics.Bitmap
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import android.util.Base64
import android.util.Log
import android.app.Activity
import android.content.pm.PackageManager
import java.lang.ref.WeakReference
import com.perfectcorp.perfectlib.SkinCare
import com.perfectcorp.perfectlib.SkinAnalysisData
import com.perfectcorp.perfectlib.SkinTypeAnalysisData
import java.io.ByteArrayOutputStream

class SkinCareCamViewPlugin() : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private val TAG = "SkinCareCamViewPlugin"
    private val METHOD_CHANNEL_BASE = "PerfectSDKSkinCareView/"
    private var bindingReference = WeakReference<ActivityPluginBinding>(null)
    private var flutterViewFactory: SkinCareCamViewFactory? = null
    private var methodChannel: MethodChannel? = null

    fun getActivity(): Activity? {
        return bindingReference.get()?.activity
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        val flutterViewFactoryCallback = object: FlutterViewFactoryCallback {
            override fun onViewCreated(viewId: Int) {
                Log.d(TAG, "onViewCreated, viewId: $viewId")
                methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_BASE + viewId)
                methodChannel?.setMethodCallHandler(this@SkinCareCamViewPlugin)
                flutterViewFactory?.getView()?.setMethodChannel(methodChannel!!)
            }
        }
        flutterViewFactory = SkinCareCamViewFactory(binding.binaryMessenger, flutterViewFactoryCallback)
        binding.platformViewRegistry.registerViewFactory("skincare_view", flutterViewFactory!!)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { 
        Log.d(TAG, "onDetachedFromEngine")
        flutterViewFactory = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    val requestPermisionResultListener = object: PluginRegistry.RequestPermissionsResultListener {
        override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
            when (requestCode) {
                SkinCareCamView.Companion.PERMISSION_CAMERA_REQUEST -> {
                    if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                        Log.d(TAG, "camera permission is granted.")
                        flutterViewFactory?.getView()?.initSkinCareAndCreateFragment(getActivity())
                        return true
                    } else {
                        val message = "camera permission is denied."
                        flutterViewFactory?.getView()?.showAlertDialog(message)
                        Log.e(TAG, message)
                    }
                }
            }
            return false
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) { 
        Log.d(TAG, "onAttachedToActivity")
        bindingReference = WeakReference(binding)
        binding.addRequestPermissionsResultListener(requestPermisionResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() { 
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        bindingReference.get()?.removeRequestPermissionsResultListener(requestPermisionResultListener)
        bindingReference.clear()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        bindingReference = WeakReference(binding)
        binding.addRequestPermissionsResultListener(requestPermisionResultListener)
     }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        bindingReference.get()?.removeRequestPermissionsResultListener(requestPermisionResultListener)
        bindingReference.clear()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall ${call.method}")
        when (call.method) {
            "takePicture" -> takePicture(call, result)
            "start" -> start(call, result)
            "stop" -> stop(call, result)
            "pause" -> pause(call, result)
            "resume" -> resume(call, result)
            "analyzeImage" -> analyzeImage(call, result)
            "getAvailableFeatures" -> getAvailableFeatures(call, result)
            "getOverallScore" -> getOverallScore(call, result)
            "getReports" -> getReports(call, result)
            "getAnalyzedImage" -> getAnalyzedImage(call, result)
            "getSkinTypes" -> getSkinTypes(call, result)
            "getSkinTypeAnalyzedImage" -> getSkinTypeAnalyzedImage(call, result)
            "dispose" -> dispose(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun takePicture(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action takePicture")

        flutterViewFactory?.getView()?.takePicture()

        var id = call.argument<Int>("id");
        result.success(id);
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action start")
        flutterViewFactory?.getView()?.initSkinCareAndCreateFragment(getActivity())

        var id = call.argument<Int>("id");
        result.success(id);
    }

    private fun stop(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action stop")

        flutterViewFactory?.getView()?.stop()
        var id = call.argument<Int>("id");
        result.success(id);
    }

    private fun pause(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action pause")

        flutterViewFactory?.getView()?.pause()
        var id = call.argument<Int>("id");
        result.success(id);
    }

    private fun resume(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action resume")

        flutterViewFactory?.getView()?.resume()
        var id = call.argument<Int>("id");
        result.success(id);
    }

    private fun analyzeImage(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action analyzeImage")

        var image = call.argument<String>("image")
        if (image.isNullOrEmpty()) {
            Log.e(TAG, "action analyzeImage image is null")
            result.error("analyzeImage", "image is null", "")
        }
        flutterViewFactory?.getView()?.setImage(image!!, object: SkinCare.SetImageCallback {
            override fun onSuccess() {
                Log.d(TAG, "action analyzeImage success")
                result.success(true);
            }

            override fun onFailure(throwable: Throwable) {
                val message = throwable.message.toString()
                Log.e(TAG, "action analyzeImage failed, error: " + message)
                runOnMainThread { 
                    flutterViewFactory?.getView()?.showAlertDialog(message)
                }
                result.error("setImage", throwable.message, "")
            }
        })
    }

    private fun getAvailableFeatures(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getAvailableFeatures")

        val features = flutterViewFactory?.getView()?.getAvailableFeatures()
        result.success(features);
    }

    private fun getOverallScore(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getOverallScore")

        flutterViewFactory?.getView()?.getOverallScore(object : SkinCare.GetOverallScoreCallback {
            override fun onSuccess(overallScore: Int, skinAge: Int) {
                Log.d(TAG, "overallScore: $overallScore, skinAge: $skinAge")
                val onCheckResult: HashMap<String, String> = hashMapOf()
                onCheckResult["overallScore"] = overallScore.toString()
                onCheckResult["skinAge"] = skinAge.toString()
                result.success(onCheckResult);
            }

            override fun onFailure(throwable: Throwable) {
                result.error("getOverallScore", throwable.message, "")
            }
        })
    }

    private fun getReports(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getReports")

        flutterViewFactory?.getView()?.getReports(object: SkinCare.GetReportsCallback {
            override fun onSuccess(reports: List<SkinAnalysisData>) {
                val onCheckResult: HashMap<String, String> = hashMapOf()
                reports.forEach({
                    onCheckResult[it.feature] = it.score.toString()
                })
                result.success(onCheckResult);
            }

            override fun onFailure(throwable: Throwable) {
                result.error("getReports", throwable.message, "")
            }
        })
    }

    private fun getBase64Png(bitmap: Bitmap): String {
        val bos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos)
        val byteArray = bos.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_PADDING or Base64.NO_WRAP)
    }

    private fun getAnalyzedImage(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getAnalyzedImage")

        var features = call.argument<List<String>>("features");
        flutterViewFactory?.getView()?.getAnalyzedImage(features!!, object: SkinCare.GetAnalyzedImageCallback{
            override fun onSuccess(resultBitmap: Bitmap) {
                Thread {
                    val base64Png = getBase64Png(resultBitmap)
                    result.success(base64Png)
                }.start()
            }

            override fun onFailure(throwable: Throwable) {
                result.error("getAnalyzedImage", throwable.message, "")
            }
        })
    }

    private fun getSkinTypes(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getSkinTypes")

        flutterViewFactory?.getView()?.getSkinTypes(object: SkinCare.GetSkinTypesCallback {
            override fun onSuccess(reports: List<SkinTypeAnalysisData>) {
                val onCheckResult: HashMap<String, String> = hashMapOf()
                reports.forEach({
                    onCheckResult[it.feature] = it.skinType.toString()
                })
                result.success(onCheckResult);
            }

            override fun onFailure(throwable: Throwable) {
                result.error("getSkinTypes", throwable.message, "")
            }
        })
    }

    private fun getSkinTypeAnalyzedImage(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getSkinTypeAnalyzedImage")

        flutterViewFactory?.getView()?.getSkinTypeAnalyzedImage(object: SkinCare.GetSkinTypeAnalyzedImageCallback {
            override fun onSuccess(resultBitmap: Bitmap) {
                Thread {
                    val base64Png = getBase64Png(resultBitmap)
                    result.success(base64Png)
                }.start()
            }

            override fun onFailure(throwable: Throwable) {
                result.error("getSkinTypeAnalyzedImage", throwable.message, "")
            }
        })
    }

    private fun dispose(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action dispose")
        flutterViewFactory?.getView()?.dispose()
        flutterViewFactory?.removeView()
        var id = call.argument<Int>("id");
        result.success(id);
    }
}