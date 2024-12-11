package com.perfectlibwrapper

import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import android.content.Context
import io.flutter.plugin.platform.PlatformView

class MakeupCamViewFactory(private val messenger: BinaryMessenger, private val callback: FlutterViewFactoryCallback?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var flutterView: MakeupCamView? = null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        flutterView = MakeupCamView(context)
        callback?.onViewCreated(viewId)
        return flutterView!!
    }

    fun getView(): MakeupCamView? {
        return flutterView
    }
    fun removeView() {
        flutterView = null
    }
}

interface FlutterViewFactoryCallback {
    fun onViewCreated(viewId: Int)
}