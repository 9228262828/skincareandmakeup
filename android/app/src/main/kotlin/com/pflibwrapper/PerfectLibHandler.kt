package com.pflibwrapper

import android.content.Context
import android.net.http.HttpResponseCache
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Log.e
import com.perfectcorp.perfectlib.Configuration
import com.perfectcorp.perfectlib.Configuration.ImageSource
import com.perfectcorp.perfectlib.DebugMode
import com.perfectcorp.perfectlib.Functionality
import com.perfectcorp.perfectlib.PerfectLib
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.io.IOException

private val handler = Handler(Looper.getMainLooper())

internal fun runOnMainThread(block: () -> Unit) =
    handler.post(block)

class PerfectLibHandler internal constructor(val applicationContext: Context?): MethodCallHandler {
    private val TAG = "MainActivity"
    companion object {
        const val IMAGE_SOURCE = "imageSource"
        const val PREVIEW_MODE = "previewMode"
        const val MAPPING_MODE = "mappingMode"
        const val DEVELOPER_MODE = "developerMode"
        const val USER_ID = "userId"
        const val MODEL_FOLDER = "modelFolder"
        const val CONFIG_FILE = "configFile"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
            call.method == "init" -> {
                init(call, result)
            }
            call.method == "getLocaleCode" -> {
                getLocaleCode(result)
            }
            call.method == "setLocaleCode" -> {
                setLocaleCode(call, result)
            }
            call.method == "getCountryCode" -> {
                getCountryCode(result)
            }
            call.method == "setCountryCode" -> {
                setCountryCode(call, result)
            }
        }
    }

    fun init(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "init PerfectLib")
        var arg = call.arguments
        Log.d(TAG, "arg: $arg")
        var imageSourceInt = call.argument<Int>(IMAGE_SOURCE)
        Log.d(TAG, "imageSource: $imageSourceInt")
        var imageSource : ImageSource
        imageSource = if(imageSourceInt == 0){
            ImageSource.FILE
        } else{
            ImageSource.URL
        }
        var developerMode = call.argument<Boolean>(DEVELOPER_MODE)
        Log.d(TAG, "developerMode: $developerMode")
        var configFile = call.argument<String>(CONFIG_FILE)
        Log.d(TAG, "configFile: $configFile")
        var mappingMode = call.argument<Boolean>(MAPPING_MODE)
        Log.d(TAG, "mappingMode: $mappingMode")
        var modelFolder = call.argument<String>(MODEL_FOLDER)
        Log.d(TAG, "modelFolder: $modelFolder")
        var previewMode = call.argument<Boolean>(PREVIEW_MODE)
        Log.d(TAG, "previewMode: $previewMode")
        var userId = call.argument<String>(USER_ID)
        Log.d(TAG, "userId: $userId")

        runOnMainThread {
            val builder = Configuration.builder()
                .setModelPath(PerfectLib.ModelPath.assets("model"))
                .setImageSource(imageSource)
                .setPreviewMode(previewMode ?: false)
                .setMappingMode(mappingMode ?: false)
                .setDeveloperMode(developerMode ?: false)
                .setUserId(userId)
//                .setConfigFile()
//                .setSkinCareRecommendationId(configuration.getString(SURVEY_ID) ?: "", configuration.getString(SETTING_ID))
            PerfectLib.setDebugMode(DebugMode.builder().enableLogcat(Log.DEBUG).build())

            enableHttpCache(50)

            PerfectLib.init(applicationContext, builder.build(), object : PerfectLib.InitialCallback {
                override fun onInitialized(availableFunctionalities: Set<Functionality>, preloadErrors: Map<String, Throwable>) {
                    Log.d(TAG, "init onInitialized")
                    result.success(true)
                }

                override fun onFailure(throwable: Throwable, preloadErrors: Map<String, Throwable>) {
                    Log.d(TAG, "onFailure")
                    result.error("false","init failed.", throwable.toString())
                }
            })
        }
    }

    private fun enableHttpCache(cacheSize : Int) {
        val httpCacheDir: File = File(applicationContext!!.cacheDir, "http")
        val httpCacheSize = (cacheSize * 1024 * 1024).toLong()

        try {
            HttpResponseCache.install(httpCacheDir, httpCacheSize)
        } catch (e: IOException) {
            e.message?.let { e("[enableHttpCache] failed.", it) }
        }
    }

    fun getCountryCode(result: MethodChannel.Result) =
        result.success(PerfectLib.getCountryCode())

    fun getLocaleCode(result: MethodChannel.Result) =
        result.success(PerfectLib.getLocaleCode())

    fun setCountryCode(call: MethodCall, result: MethodChannel.Result) {
        val countryCode = call.argument<String>("countryCode")
        PerfectLib.setCountryCode(countryCode)
        result.success(null)
    }

    fun setLocaleCode(call: MethodCall, result: MethodChannel.Result) {
        val localeCode = call.argument<String>("localeCode")
        PerfectLib.setLocaleCode(localeCode)
        result.success(null)
    }
}