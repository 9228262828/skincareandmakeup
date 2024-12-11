package com.perfectlibwrapper

import android.app.Activity
import android.graphics.Bitmap
import android.util.Base64
import android.util.Log
import com.perfectcorp.perfectlib.EffectConfig
import com.perfectcorp.perfectlib.LookSetting
import com.perfectcorp.perfectlib.MakeupCam
import com.perfectcorp.perfectlib.PerfectEffect
import com.perfectcorp.perfectlib.ProductId
import com.perfectcorp.perfectlib.VtoApplier
import com.perfectcorp.perfectlib.VtoSetting
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.lang.ref.WeakReference

class MakeupCamViewPlugin() : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private val TAG = "MakeupCamViewPlugin"
    companion object {
        const val TYPE = "type"
        const val PRODUCT = "product"
        const val SKU = "sku"
        const val PALETTE = "palette"
        const val PATTERN = "pattern"
    }

    private val METHOD_CHANNEL_BASE = "PerfectSDKMakeupCamView/"
    protected val activity get() = activityReference.get()

    private var activityReference = WeakReference<Activity>(null)
    private var flutterViewFactory: MakeupCamViewFactory? = null
    private var methodChannel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        val flutterViewFactoryCallback = object : FlutterViewFactoryCallback {
            override fun onViewCreated(viewId: Int) {
                Log.d(TAG, "onViewCreated, viewId: $viewId")
                methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_BASE + viewId)
                methodChannel?.setMethodCallHandler(this@MakeupCamViewPlugin)
                flutterViewFactory?.getView()?.setMethodChannel(methodChannel!!)
            }
        }
        flutterViewFactory =
            MakeupCamViewFactory(binding.binaryMessenger, flutterViewFactoryCallback)
        binding.platformViewRegistry.registerViewFactory("makeupCam_view", flutterViewFactory!!)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        flutterViewFactory = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        activityReference = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        activityReference.clear()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        activityReference = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        activityReference.clear()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall ${call.method}")
        when (call.method) {
            "startCamera" -> startCamera(call, result)
            "takePicture" -> takePicture(call, result)
            "apply" -> apply(call, result)
            "applyLook" -> applyLook(call, result)
            "getProductIds" -> getProductIds(result)
            "getIntensities" -> getIntensities(result)
            "setIntensities" -> setIntensities(call, result)
            "clear" -> clear(call, result)
            "clearAllEffects" -> clearAllEffects(result)
            "dispose" -> dispose(result)
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun startCamera(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "start camera")

        flutterViewFactory?.getView()?.initMakeupCamAndCreateFragment(activity)
        var id = call.argument<Int>("id");
        result.success(id);
    }

    private fun takePicture(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action takePicture")
        if (!flutterViewFactory?.getView()?.checkStatus()!!) {
            Log.d(TAG, "NOT READY")
            result.success(null)
        }
        val isFrontCamera = true
        val flipForFrontCamera = true
        val continueCapture = true
        val needOriginal = false

        flutterViewFactory?.getView()?.getMakeupCam()
            ?.takePicture(isFrontCamera, flipForFrontCamera, continueCapture, needOriginal, object : MakeupCam.PictureCallback {
                override fun onPictureTaken(originalPicture: Bitmap?, resultPicture: Bitmap) {
                    Thread {
                        val bos = ByteArrayOutputStream()
                        resultPicture.compress(Bitmap.CompressFormat.PNG, 100, bos)
                        val byteArray = bos.toByteArray()
                        val base64Png = Base64.encodeToString(byteArray, Base64.NO_PADDING or Base64.NO_WRAP)
                        result.success(base64Png)
                    }.start()
                }

                override fun onFailure(throwable: Throwable) {
                    result.error("takePicture", throwable.message, "")
                }
            })
    }

    private fun apply(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action apply")

        if (!flutterViewFactory?.getView()?.checkStatus()!!) {
            Log.d(TAG, "NOT READY")
            return
        }

        val product = call.argument<String>("product")
        val sku = call.argument<String>("sku")
        val palette = call.argument<String>("palette")
        val pattern = call.argument<String>("pattern")
        val wearingStyle = call.argument<String>("wearingStyle")

        val vtoSetting = VtoSetting.builder()
            .setProductGuid(product)
            .setSkuGuid(sku)
            .setPaletteGuid(palette)
            .setPatternGuid(pattern)
            .setWearingStyleGuid(wearingStyle)
            .build()

        flutterViewFactory?.getView()?.applier?.apply(
            listOf(vtoSetting),
            EffectConfig.DEFAULT,
            object : VtoApplier.ApplyCallback {
                override fun onSuccess(ignored: Bitmap?) {
                    result.success(true)
                }

                override fun onFailure(throwable: Throwable) {
                    result.error("apply", throwable.message, "")
                }
            })
    }

    private fun applyLook(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action applyLook")

        if (!flutterViewFactory?.getView()?.checkStatus()!!) {
            Log.d(TAG, "NOT READY")
            return
        }

        val lookGuid = call.argument<String>("lookGuid")
        flutterViewFactory?.getView()?.applier?.apply(
            LookSetting.create(lookGuid),
            object : VtoApplier.DownloadAndApplyCallback {
                override fun onSuccess(ignored: Bitmap?) {
                    result.success(true)
                }

                override fun onFailure(throwable: Throwable) {
                    result.error("applyLook", throwable.message, "")
                }

                override fun downloadProgress(ignored: Double) {}
            })
    }

    private fun getProductIds(result: MethodChannel.Result) {
        Log.d(TAG, "action getProductIds")

        if (!flutterViewFactory?.getView()?.checkStatus()!!) {
            Log.d(TAG, "NOT READY")
            return
        }

        flutterViewFactory?.getView()?.applier?.getProductIds(object :
            VtoApplier.ProductIdCallback {
            override fun onSuccess(productIds: List<ProductId>) {
                var list: MutableList<Map<String, String>> = mutableListOf()
                productIds.forEach {
                    val map = mapOf(
                        TYPE to it.type.name,
                        PRODUCT to it.productGuid,
                        SKU to it.skuGuid,
                        PALETTE to it.paletteGuid,
                        PATTERN to it.patternGuid
                    )
                    Log.d(TAG, "map: $map")
                    list.add(map)
                }
                result.success(list)
            }

            override fun onFailure(throwable: Throwable) {
                result.error("getProductIds", throwable.message, "")
            }
        })
    }

    private fun getIntensities(result: MethodChannel.Result) {
        Log.d(TAG, "action getIntensities")

        flutterViewFactory?.getView()?.applier?.getIntensities(object : VtoApplier.IntensitiesCallback {
            override fun onSuccess(intensities: Map<PerfectEffect, IntArray>) {
                Log.d(TAG, "getIntensities onSuccess")
                val map = hashMapOf<String, List<Int>>()
                intensities.forEach { 
                    val name = if (it.key == PerfectEffect.SKIN_SMOOTH) "SkinSmooth" else it.key.name
                    map[name] = it.value.asList()
                 }
                return result.success(map)
            }

            override fun onFailure(throwable: Throwable) {
                Log.e(TAG, "getIntensities onFailure", throwable)
                return result.error(TAG, "getIntensities error", throwable)
            }
        })
    }

    private fun setIntensities(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action setIntensities")

        val intensities = call.argument<Map<String, List<Int>>>("intensities");
        if (intensities.isNullOrEmpty()) {
            Log.d(TAG, "setIntensities, intensities is null or empty.")
            result.success(null)
        } 
        Log.d(TAG, "intensities: " + intensities)
        val map = mutableMapOf<PerfectEffect, IntArray>()
        intensities?.forEach { (key, value) ->
            map[effectNameToEffect(key)] = value.toIntArray()
        }
        flutterViewFactory?.getView()?.applier?.setIntensities(map, object : VtoApplier.ApplyCallback {
            override fun onSuccess(ignored: Bitmap?) {
                Log.d(TAG, "setIntensities onSuccess")
                result.success(null)
            }

            override fun onFailure(throwable: Throwable) {
                Log.e(TAG, "setIntensities onFailure", throwable)
                result.success(null)
            }
        })
    }

    private fun clear(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action clear")

        val effect = call.argument<String>("effect");
        if (effect.isNullOrEmpty()) {
            Log.d(TAG, "clear, effect is null or empty.")
            result.success(null)
        } 
        flutterViewFactory?.getView()?.applier?.clearEffect(effectNameToEffect(effect!!), object : VtoApplier.ApplyCallback {
            override fun onSuccess(ignored: Bitmap?) {
                Log.d(TAG, "clear onSuccess")
                result.success(null)
            }

            override fun onFailure(throwable: Throwable) {
                Log.e(TAG, "clear onFailure", throwable)
                result.success(null)
            }
        })
    }

    private fun clearAllEffects(result: MethodChannel.Result) {
        Log.d(TAG, "action clearAllEffects")

        flutterViewFactory?.getView()?.applier?.clearAllEffects(object : VtoApplier.ApplyCallback {
            override fun onSuccess(ignored: Bitmap?) {
                result.success(null);
            }

            override fun onFailure(throwable: Throwable) {
                result.success(null);
            }

        })
    }

    private fun dispose(result: MethodChannel.Result) {
        Log.d(TAG, "action dispose")
        flutterViewFactory?.getView()?.dispose()
        flutterViewFactory?.removeView()
        result.success(null);
    }

    fun effectNameToEffect(name: String): PerfectEffect {
        return when (name) {
            "Eyeliner" -> PerfectEffect.EYELINER
            "Eyelashes" -> PerfectEffect.EYELASHES
            "Eyeshadow" -> PerfectEffect.EYESHADOW
            "Mascara" -> PerfectEffect.MASCARA
            "Eyebrow" -> PerfectEffect.EYEBROW
            "EyeContact" -> PerfectEffect.EYE_COLOR
            "Foundation" -> PerfectEffect.FOUNDATION
            "Blush" -> PerfectEffect.BLUSH
            "SkinSmooth" -> PerfectEffect.SKIN_SMOOTH
            "Contour" -> PerfectEffect.CONTOUR
            "Highlighter" -> PerfectEffect.HIGHLIGHTER
            "Lipstick" -> PerfectEffect.LIPSTICK
            "HighlighterAndContour" -> PerfectEffect.HIGHLIGHTER_AND_CONTOUR
            "Lipliner" -> PerfectEffect.LIP_LINER
            "Eyewear" -> PerfectEffect.EYEWEAR
            "Eyewear3D" -> PerfectEffect.EYEWEAR_3D
            "Hairdye" -> PerfectEffect.HAIR_COLOR
            "Earrings" -> PerfectEffect.EARRINGS
            "Background" -> PerfectEffect.BACKGROUND
            "Bronzer" -> PerfectEffect.BRONZER
            "Concealer" -> PerfectEffect.CONCEALER
            else -> PerfectEffect.EYELINER
        }
    }
}