package com.gomla.store

import android.os.Build
import android.util.Log
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.pflibwrapper.SkinCareCamViewPlugin
import com.pflibwrapper.PerfectLibHandler
import com.pflibwrapper.SkinCareCamView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.perfectlibwrapper.MakeupCamViewPlugin
import com.perfectlibwrapper.PerfectLookHandler
import com.perfectlibwrapper.PerfectSkuHandler

class MainActivity: FlutterFragmentActivity() {
    private val TAG = "MainActivity"
    private val PERFECTLIB_CHANNEL = "PerfectLibMethodChannel"
    private val EVENT_CHANNEL = "PerfectSDKSkinCareEventChannel"
    private val PERFECTLOOKHANDLER_CHANNEL = "PerfectSDKLookHandlerMethodChannel"
    private val PERFECTSKUHANDLER_CHANNEL = "PerfectSDKSkuHandlerMethodChannel"

    var lookMethodChannel: MethodChannel? = null
    var skuMethodChannel: MethodChannel? = null

    var methodChannel: MethodChannel? = null
    var eventChannel: EventChannel? = null

    @RequiresApi(Build.VERSION_CODES.O)
    @ExperimentalStdlibApi
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "configureFlutterEngine")

        val perfectLibHandler = PerfectLibHandler(this)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERFECTLIB_CHANNEL)
        methodChannel!!.setMethodCallHandler(perfectLibHandler)

        val perfectLookHandler = PerfectLookHandler(this)
        lookMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERFECTLOOKHANDLER_CHANNEL)
        lookMethodChannel!!.setMethodCallHandler(perfectLookHandler)

        skuMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERFECTSKUHANDLER_CHANNEL)
        val perfectSkuHandler = PerfectSkuHandler(this, skuMethodChannel)
        skuMethodChannel!!.setMethodCallHandler(perfectSkuHandler)


        flutterEngine.plugins.add(SkinCareCamViewPlugin())
        Log.d(TAG, "plugin skin added")

        flutterEngine.plugins.add(MakeupCamViewPlugin())
        Log.d(TAG, "plugin makeup added")

        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                Log.d(TAG, "eventChannel onListen arguments:" + arguments)
                eventSink.success("success")
            }

            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "eventChannel onCancel")
            }
        })
    }
}
