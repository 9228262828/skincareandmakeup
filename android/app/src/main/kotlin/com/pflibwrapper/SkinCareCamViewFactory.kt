package com.pflibwrapper

import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import android.content.Context
import io.flutter.plugin.platform.PlatformView
import com.perfectcorp.common.utility.Log

class SkinCareCamViewFactory(private val messenger: BinaryMessenger, private val callback: FlutterViewFactoryCallback?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var flutterView: SkinCareCamView? = null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        flutterView = SkinCareCamView(context)
        callback?.onViewCreated(viewId)
        return flutterView!!
    }

    fun getView(): SkinCareCamView? {
        return flutterView
    }
    fun removeView() {
        flutterView = null
    }
}

interface FlutterViewFactoryCallback {
    fun onViewCreated(viewId: Int)
}