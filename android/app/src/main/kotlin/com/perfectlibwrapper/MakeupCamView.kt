package com.perfectlibwrapper

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.SurfaceTexture
import android.hardware.Camera
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Message
import android.view.Surface
import android.view.SurfaceHolder
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.perfectcorp.common.utility.Log
import com.perfectcorp.perfectlib.CameraFrame
import com.perfectcorp.perfectlib.CameraView
import com.perfectcorp.perfectlib.MakeupCam
import com.perfectcorp.perfectlib.VtoApplier
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.IOException

class MakeupCamView(private val context: Context) : PlatformView {
    private val TAG = "MakeupCamView"

    val STATUS_UNKNOWN = 0
    val STATUS_LOADING = 1
    val STATUS_READY = 2

    var loadStatus = STATUS_LOADING


    private var cameraView: CameraView? = null
    val relativeLayout: RelativeLayout

    private var firstAttach = true
    private var attachToWindow = true
    private lateinit var makeupCam: MakeupCam
    lateinit var applier: VtoApplier
    private var activity: Activity? = null
    private val PERMISSION_CAMERA_REQUEST = 2
    private var methodChannel: MethodChannel? = null
    private var isCameraViewCreated: Boolean = false
    private var isPaused = false

    companion object {
        const val PERMISSION_CAMERA_REQUEST = 6789
    }

    fun getMakeupCam() : MakeupCam {
        return this.makeupCam
    }

    init {
        relativeLayout = RelativeLayout(context);
        relativeLayout.setBackgroundColor(Color.RED)
        initCameraView()
    }

    override fun dispose() {
        setMethodChannel(null)
        removeRootFragment()
    }

    fun initMakeupCamAndCreateFragment(activity: Activity?) {
        Log.d(TAG, "initMakeupCamAndCreateFragment")
        this.activity = activity
        if (activity == null) {
            Log.e(TAG, "initMakeupCamAndCreateFragment, activity is null, early return.")
            return
        }

        if (!isCameraPermissionGranted()) {
            //request Camera
            Log.d(TAG, "requestCameraPermission")
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(android.Manifest.permission.CAMERA),
                PERMISSION_CAMERA_REQUEST
            )
        }

        Log.d(TAG, "MakeupCam.create")
        MakeupCam.create(cameraView, object : MakeupCam.CreateCallback {
            override fun onSuccess(makeupCam: MakeupCam) {
                Log.d(TAG, "MakeupCam.create onSuccess")
                this@MakeupCamView.makeupCam = makeupCam

                VtoApplier.create(makeupCam, object : VtoApplier.CreateCallback {
                    override fun onSuccess(applier: VtoApplier) {
                        this@MakeupCamView.applier = applier

                        loadStatus = STATUS_READY
                        commitRootFragment(activity as FragmentActivity)
                    }

                    override fun onFailure(throwable: Throwable) {
                        val message = "VtoApplier create failed. throwable=$throwable"
                        Toast.makeText(context.applicationContext, message, Toast.LENGTH_SHORT)
                            .show()

                        loadStatus = STATUS_UNKNOWN
                    }

                })

            }

            override fun onFailure(throwable: Throwable?) {
                Log.e(TAG, "MakeupCam.create onFailure")
                val message = "MakeupCam create failed. throwable=$throwable"
                Toast.makeText(context.applicationContext, message, Toast.LENGTH_SHORT).show()
                loadStatus = STATUS_UNKNOWN
            }
        })
    }

    fun setMethodChannel(methodChannel: MethodChannel?) {
        this.methodChannel = methodChannel
    }

    private fun initCameraView() {
        Log.d(TAG, "initCameraView")
        cameraView = CameraView(context)

        cameraView?.holder?.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                Log.d(TAG, "surfaceCreated, holder = " + holder)
                isCameraViewCreated = true
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
                Log.d(TAG, "surfaceChanged, holder = " + holder)
                isCameraViewCreated = true
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                Log.d(TAG, "surfaceDestroyed, holder = " + holder)
                isCameraViewCreated = false
            }
        })

        val lp = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        relativeLayout.addView(cameraView, lp)
    }

    override fun getView(): View? {
        Log.d(TAG, "MakeupCamView getView")
        return relativeLayout
    }

    fun commitRootFragment(activity: FragmentActivity) {
        Log.d(TAG, "commitRootFragment")
        val rootFragment = RootFragment()
        rootFragment.rootLayout = this
        activity.supportFragmentManager
            .beginTransaction()
            .add(0, rootFragment, RootFragment.TAG)
            .commitAllowingStateLoss()
    }

    fun getRootFragment(): RootFragment? {
        if (activity == null) {
            return null
        }
        val currentActivity = activity as FragmentActivity
        val fragmentManager = currentActivity.supportFragmentManager
        return fragmentManager.findFragmentByTag(RootFragment.TAG) as RootFragment?
    }

    fun removeRootFragment() {
        val rootFragment = getRootFragment()
        if (rootFragment != null) {
            val currentActivity = activity as FragmentActivity
            val fragmentManager = currentActivity.supportFragmentManager
            fragmentManager.beginTransaction().remove(rootFragment).commitAllowingStateLoss()
        }
    }

    fun removeAllViews() {
        relativeLayout.removeView(cameraView)
        cameraView = null
    }

    class RootFragment : Fragment() {
        companion object {
            const val TAG = "MakeupCamViewRootFragment"
        }

        lateinit var rootLayout: MakeupCamView

        override fun onDestroyView() {
            rootLayout.removeAllViews()
            super.onDestroyView()
        }

        private lateinit var cameraLooper: Looper
        private lateinit var cameraHandler: CameraHandler

        override fun onActivityCreated(savedInstanceState: Bundle?) {
            super.onActivityCreated(savedInstanceState)

            cameraLooper = createLooper()
            cameraHandler = CameraHandler(rootLayout.makeupCam, cameraLooper)
            rootLayout.makeupCam.onCreated()
        }

        private fun createLooper(): Looper {
            val thread = HandlerThread("CameraHandlerThread")
            thread.start()
            return thread.looper
        }

        override fun onStart() {
            super.onStart()
            rootLayout.makeupCam.onStarted()
        }

        override fun onResume() {
            super.onResume()
            rootLayout.makeupCam.onResumed()
            cameraHandler.obtainMessage(CameraHandler.START_CAMERA).sendToTarget()
        }

        override fun onPause() {
            cameraHandler.sendEmptyMessage(CameraHandler.STOP_CAMERA)
            rootLayout.makeupCam.onPaused()
            super.onPause()
        }

        override fun onStop() {
            rootLayout.makeupCam.onStopped()
            super.onStop()
        }

        override fun onDestroy() {
            rootLayout.makeupCam.onDestroyed()
            cameraLooper.quitSafely()
            super.onDestroy()
        }

        @Suppress("DEPRECATION")
        fun takePicture(pictureCallback: Camera.PictureCallback) {
            Log.d(TAG, "RootFragment takePicture")
            cameraHandler.obtainMessage(CameraHandler.TAKE_PICTURE, pictureCallback).sendToTarget()
        }

        fun startPreview() {
            Log.d(TAG, "RootFragment startPreview")
            cameraHandler.obtainMessage(CameraHandler.START_PREVIEW).sendToTarget()
        }
    }

    @Suppress("DEPRECATION")
    private class CameraHandler(private val makeupCam: MakeupCam, looper: Looper) :
        Handler(looper) {
        companion object {
            private const val TAG = "CameraHandler"

            const val START_CAMERA = 1
            const val STOP_CAMERA = 2
            const val TAKE_PICTURE = 3
            const val START_PREVIEW = 4

            private fun getCameraRotation(displayRotation: Int, cameraId: Int): Int {
                var rotation = 0
                try {
                    val info = getCameraInfo(cameraId)
                    val orientation = displayRotation * 90
                    rotation = if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                        (info.orientation - orientation + 360) % 360
                    } else {
                        (info.orientation + orientation) % 360
                    }
                } catch (t: Throwable) {
                    Log.e(TAG, "[getCameraRotation]", t)
                }
                return rotation
            }

            private fun getCameraInfo(cameraId: Int): Camera.CameraInfo {
                val cameraInfo = Camera.CameraInfo()
                Camera.getCameraInfo(cameraId, cameraInfo)
                return cameraInfo
            }

            private fun getCameraId(@Suppress("SameParameterValue") facing: Int): Int {
                val info = Camera.CameraInfo()
                val count: Int = Camera.getNumberOfCameras()
                for (i in 0 until count) {
                    Camera.getCameraInfo(i, info)
                    if (info.facing == facing) {
                        return i
                    }
                }
                return 0
            }
        }

        override fun handleMessage(msg: Message) {
            when (msg.what) {
                START_CAMERA -> {
                    startCamera()
                    startPreview()
                }

                STOP_CAMERA -> {
                    stopCamera()
                }
                TAKE_PICTURE -> takePicture(msg.obj as Camera.PictureCallback)
            }
        }

        private var camera: Camera? = null
        private var surfaceTexture: SurfaceTexture? = null
        private var cameraId = 0

        private fun startCamera() {
            android.util.Log.d(TAG, "[startCamera]")
            var camera: Camera? = null
            try {
                val cameraId = getCameraId(Camera.CameraInfo.CAMERA_FACING_FRONT)
                camera = Camera.open(cameraId)
                if (camera != null) {
                    if (!tryToSetPreviewSize(
                            camera,
                            1280,
                            960
                        )
                    ) { // Need app to have an arbitration approach to select performance matched preview size.
                        if (!tryToSetPreviewSize(camera, 960, 720)) {
                            tryToSetPreviewSize(camera, 640, 480)
                        }
                    }
                    val previewSize = camera.parameters.previewSize
                    camera.setPreviewCallback(CameraPreviewCallback(makeupCam, previewSize))
                    surfaceTexture = SurfaceTexture(10)
                    camera.setPreviewTexture(surfaceTexture)
                    val cameraInfo = Camera.CameraInfo()
                    Camera.getCameraInfo(cameraId, cameraInfo)
                    makeupCam.onCameraOpened(
                        cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT,
                        cameraInfo.orientation,
                        previewSize.width,
                        previewSize.height
                    )
                    tryToSetAutoFocus(camera)
                }
                this.cameraId = cameraId
            } catch (t: Throwable) {
                android.util.Log.e(TAG, "[startCamera] with error.", t)
                camera?.release()
                camera = null
            }
            this.camera = camera
        }

        @Suppress("SameParameterValue")
        private fun tryToSetPreviewSize(camera: Camera, width: Int, height: Int): Boolean {
            val cameraParameters = camera.parameters
            val previewSizes = cameraParameters.supportedPreviewSizes
            for (size in previewSizes) {
                if (width == size.width && height == size.height) {
                    cameraParameters.setPreviewSize(
                        width,
                        height
                    ) // Need app to have an arbitration approach to select performance matched preview size.
                    camera.parameters = cameraParameters
                    android.util.Log.d(TAG, "Camera preview size, width=$width, height=$height")
                    return true
                }
            }
            val previewSize = cameraParameters.previewSize
            android.util.Log.d(
                TAG,
                "Camera preview size, width=" + previewSize.width + ", height=" + previewSize.height
            )
            return false
        }

        private fun tryToSetAutoFocus(camera: Camera) {
            val cameraParameters = camera.parameters
            val cameraFocusModes = cameraParameters.supportedFocusModes
            when {
                cameraFocusModes.contains(Camera.Parameters.FOCUS_MODE_AUTO) -> {
                    cameraParameters.focusMode = Camera.Parameters.FOCUS_MODE_AUTO
                    android.util.Log.d(
                        "[tryToSetAutoFocus]",
                        "set focus mode: Camera.Parameters.FOCUS_MODE_AUTO"
                    )
                }

                cameraFocusModes.contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE) -> {
                    cameraParameters.focusMode = Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE
                    android.util.Log.d(
                        "[tryToSetAutoFocus]",
                        "set focus mode: Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE"
                    )
                }

                else -> {
                    android.util.Log.d("[tryToSetAutoFocus]", "not supported.")
                }
            }
            camera.parameters = cameraParameters
        }

        private fun stopCamera() {
            android.util.Log.d(TAG, "[stopCamera]")
            val camera = this.camera
            if (camera != null) {
                camera.stopPreview()
                surfaceTexture = null
                try {
                    camera.setPreviewTexture(null)
                } catch (e: IOException) {
                    android.util.Log.e(TAG, "setPreviewTexture", e)
                }
                camera.setPreviewCallback(null)
                camera.release()
            }
            this.camera = null
        }

        private val autoFocusCallback = Camera.AutoFocusCallback { success: Boolean, _: Camera ->
            android.util.Log.d(
                TAG,
                "[Camera.AutoFocusCallback] success=$success"
            )
        }

        private fun startPreview() {
            android.util.Log.d(TAG, "[startPreview]")
            val camera = this.camera
            if (camera != null) {
                try {
                    camera.startPreview()
                    android.util.Log.d(TAG, "[startPreview] start preview done")
                    camera.autoFocus(autoFocusCallback)
                    android.util.Log.d(TAG, "[startPreview] auto focus done")
                } catch (t: Throwable) {
                    android.util.Log.e(TAG, "[startPreview]", t)
                }
            }
        }

        private fun takePicture(callback: Camera.PictureCallback) {
            Log.d(TAG, "[takePicture]")
            val camera = this.camera
            if (camera != null) {
                try {
                    val parameters = camera.parameters
                    parameters.setRotation(
                        getCameraRotation(
                            Surface.ROTATION_0,
                            cameraId
                        )
                    ) // To take picture with the portrait orientation.
                    camera.parameters = parameters
                    camera.takePicture(null, null, null) { data, callbackCamera ->
                        callback.onPictureTaken(data, callbackCamera)
                    }
                } catch (t: Throwable) {
                    Log.e(TAG, "[takePicture]", t)
                }
            }
        }
    }

    @Suppress("DEPRECATION")
    private class CameraPreviewCallback(
        private val makeupCam: MakeupCam,
        cameraPreviewSize: Camera.Size
    ) :
        Camera.PreviewCallback {
        private val previewWidth: Int = cameraPreviewSize.width
        private val previewHeight: Int = cameraPreviewSize.height

        private var isFirstFrame = true

        override fun onPreviewFrame(data: ByteArray?, camera: Camera) {
            if (data == null) {
                return
            }

            val cameraFrame = CameraFrame(data, previewWidth, previewHeight, isFirstFrame)
            makeupCam.sendCameraBuffer(cameraFrame)
            isFirstFrame = false
        }
    }

    fun isCameraPermissionGranted(): Boolean {
        return ContextCompat.checkSelfPermission(
            this.context,
            android.Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun checkStatus(): Boolean {
        if (loadStatus != STATUS_READY) {
            val message = "MakeupCamView status is not ready. status=${loadStatus}"
            Log.e(TAG, message)
            Toast.makeText(context.applicationContext, message, Toast.LENGTH_LONG).show()
            return false;
        }
        return true;
    }

    fun invokeMethodChannelSafely(method: String, data: Any) {
        if (activity == null) {
            return
        }
        runOnMainThread {
            Log.d(TAG, "invoke method $method, data: $data")
            methodChannel?.invokeMethod(method, data)
        }
    }
}