package com.pflibwrapper

import android.app.AlertDialog
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.view.View
import android.view.ViewGroup
import android.view.SurfaceView
import android.view.Surface
import android.view.WindowManager
import android.view.SurfaceHolder
import com.perfectcorp.perfectlib.SkinCare
import com.perfectcorp.perfectlib.SkinCareQualityCheck
import com.perfectcorp.perfectlib.CameraFrame
import com.perfectcorp.common.utility.Log
import com.pflibwrapper.PerfectLibHandler
import com.pflibwrapper.SkinCareCamView
import android.os.Build;
import android.os.Looper
import android.os.Handler
import android.os.Message
import android.os.HandlerThread
import android.os.Bundle
import android.util.Base64
import android.hardware.Camera
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.Color
import java.util.Objects
import java.io.IOException
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.floor
import androidx.annotation.MainThread
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.setPadding
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.exifinterface.media.ExifInterface

class SkinCareCamView(private val context: Context) : PlatformView {
    private val TAG = "SkinCareCamView"

    val STATUS_UNKNOWN = 0
    val STATUS_LOADING = 1
    val STATUS_READY = 2

    var loadStatus = STATUS_LOADING

    private var surfaceView: SurfaceView? = SurfaceView(context)
    val relativeLayout: RelativeLayout

    private lateinit var skinCare: SkinCare
    private var activity: Activity? = null
    private var methodChannel: MethodChannel? = null
    private var isSurfaceViewCreated: Boolean = false
    private var isPaused = false

    companion object {
        const val PERMISSION_CAMERA_REQUEST = 12345
    }

    init {
        relativeLayout = RelativeLayout(context);
        initSurfaceView()
    }

    override fun dispose() {
        setMethodChannel(null)
        removeRootFragment()
    }

    fun initSkinCareAndCreateFragment(activity: Activity?) {
        Log.d(TAG, "initSkinCareAndCreateFragment")
        this.activity = activity
        if (activity == null) {
            Log.e(TAG, "initSkinCareAndCreateFragment, activity is null, early return.")
            return
        }

        isPaused = false

        if (isCameraPermissionGranted()) {
            // startCamera
        } else {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(android.Manifest.permission.CAMERA),
                PERMISSION_CAMERA_REQUEST
            )
            return
        }

        Log.d(TAG, "SkinCare.create")
        SkinCare.create(object : SkinCare.CreateCallback {
            override fun onSuccess(skinCare: SkinCare) {
                Log.d(TAG, "SkinCare.create onSuccess")
                this@SkinCareCamView.skinCare = skinCare
                skinCare.setSkinAnalysisCallback(skinAnalysisCallback)
                surfaceView?.visibility = View.VISIBLE
                commitRootFragment(activity as FragmentActivity)
                loadStatus = STATUS_READY
            }

            override fun onFailure(throwable: Throwable) {
                Log.e(TAG, "SkinCare.create onFailure")
                val message = "SkinCare create failed. throwable=$throwable"
                showAlertDialog(message)
                loadStatus = STATUS_UNKNOWN
            }
        })
    }

    private val skinAnalysisCallback = object: SkinCare.SkinAnalysisCallback {
        override fun onAnalyze(checkedResult: SkinCareQualityCheck) {
            if (isPaused) return
            val onCheckResult: HashMap<String, String> = hashMapOf()
            onCheckResult["faceLighting"] = convertQualityCheckString("lightingQuality", checkedResult.lightingQuality.toString())
            onCheckResult["faceArea"] = convertQualityCheckString("faceAreaQuality", checkedResult.faceAreaQuality.toString())
            onCheckResult["faceFront"] = convertQualityCheckString("faceFrontalQuality", checkedResult.faceFrontalQuality.toString())
            invokeMethodChannelSafely("onCheckResult", onCheckResult)
        }
    }

    private fun convertQualityCheckString(type: String, status: String): String {
        return if (type.equals("lightingQuality")) {
            when (status) {
                "UNKNOWN" -> "Unknown"
                "NORMAL" -> "Normal"
                "GOOD" -> "Good"
                "OVER_EXPOSED" -> "OverExposed"
                "UNDER_EXPOSED" -> "UnderExposed"
                "BACKLIGHTING" -> "Backlighting"
                "UNEVEN" -> "Uneven"
                else -> "Unknown"
            }
        } else if (type.equals("faceAreaQuality")) {
            when (status) {
                "UNKNOWN" -> "Unknown"
                "TOO_SMALL" -> "TooSmall"
                "OUT_OF_BOUNDARY" -> "OutOfBoundary"
                "GOOD" -> "Good"
                else -> "Unknown"
            }
        } else if (type.equals("faceFrontalQuality")) {
            when (status) {
                "UNKNOWN" -> "Unknown"
                "BAD" -> "Bad"
                "GOOD" -> "Good"
                else -> "Unknown"
            }
        } else {
            "Unknown"
        }
    }

    fun setMethodChannel(methodChannel: MethodChannel?) {
        this.methodChannel = methodChannel
    }

    private fun initSurfaceView() {
        Log.d(TAG, "initSurfaceView")

        surfaceView?.holder?.addCallback(object: SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                Log.d(TAG, "surfaceCreated, holder = " + holder)
                isSurfaceViewCreated = true
            }
            override fun surfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
                Log.d(TAG, "surfaceChanged, holder = " + holder)
                isSurfaceViewCreated = true
            }
            override fun surfaceDestroyed(holder: SurfaceHolder) {
                Log.d(TAG, "surfaceDestroyed, holder = " + holder)
                isSurfaceViewCreated = false
            }
        })
        surfaceView?.visibility = View.INVISIBLE
        val lp = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        relativeLayout.addView(surfaceView, lp)
    }

    override fun getView(): View? {
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
        Log.d(TAG, "removeAllViews, surfaceView: $surfaceView")
        relativeLayout.removeView(surfaceView)
    }

    class RootFragment : Fragment() {
        companion object {
            const val TAG = "SkinCareCamViewRootFragment"
        }

        lateinit var rootLayout: SkinCareCamView

        override fun onDestroyView() {
            Log.d(TAG, "RootFragment onDestroyView")
            rootLayout.removeAllViews()
            super.onDestroyView()
        }

        private lateinit var cameraLooper: Looper
        private lateinit var cameraHandler: CameraHandler

        override fun onActivityCreated(savedInstanceState: Bundle?) {
            Log.d(TAG, "RootFragment onActivityCreated")
            super.onActivityCreated(savedInstanceState)

            cameraLooper = createLooper()
            cameraHandler = CameraHandler(rootLayout, cameraLooper)
            rootLayout.skinCare.onCreated()
        }

        private fun createLooper(): Looper {
            val thread = HandlerThread("CameraHandlerThread")
            thread.start()
            return thread.looper
        }

        override fun onStart() {
            Log.d(TAG, "RootFragment onStart")
            super.onStart()
            rootLayout.skinCare.onStarted()
        }

        override fun onResume() {
            Log.d(TAG, "RootFragment onResume")
            super.onResume()
            rootLayout.skinCare.onResumed()

            if (rootLayout.isSurfaceViewCreated) {
                cameraHandler.obtainMessage(CameraHandler.START_CAMERA).sendToTarget()
            } else { // The SurfaceView is not ready. Deley a few millisecond.
                rootLayout.relativeLayout.postDelayed({
                    cameraHandler.obtainMessage(CameraHandler.START_CAMERA).sendToTarget()
                }, 100)
            }
        }

        override fun onPause() {
            Log.d(TAG, "RootFragment onPause")
            cameraHandler.sendEmptyMessage(CameraHandler.STOP_CAMERA)
            rootLayout.skinCare.onPaused()
            super.onPause()
        }

        override fun onStop() {
            Log.d(TAG, "RootFragment onStop")
            rootLayout.skinCare.onStopped()
            super.onStop()
        }

        override fun onDestroy() {
            Log.d(TAG, "RootFragment onDestroy")
            rootLayout.skinCare.onDestroyed()
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
    private class CameraHandler(private val root: SkinCareCamView, looper: Looper) : Handler(looper) {
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
        }

        @Volatile
        private var camera: Camera? = null
        override fun handleMessage(msg: Message) {
            Log.d(TAG, "handleMessage")
            when (msg.what) {
                START_CAMERA -> {
                    startCamera()
                    startPreview()
                }
                STOP_CAMERA -> stopCamera()
                TAKE_PICTURE -> takePicture(msg.obj as Camera.PictureCallback)
                START_PREVIEW -> startPreview()
            }
        }

        private var cameraId = 0
        private fun startCamera() {
            Log.d(TAG, "[startCamera]")
            val cameraId = Camera.CameraInfo.CAMERA_FACING_FRONT
            var camera: Camera? = null
            try {
                camera = Camera.open(cameraId)
                if (camera != null) {
                    tryToSetPreviewAndPictureSize(camera, 1280, 720)
                    val previewSize = camera.parameters.previewSize
                    camera.setPreviewCallback(CameraPreviewCallback(root, previewSize))
                    val cameraInfo = Camera.CameraInfo()
                    Camera.getCameraInfo(cameraId, cameraInfo)
                    camera.setPreviewDisplay(root.surfaceView?.holder)
                    setupDisplayOrientation(camera, cameraInfo, root.surfaceView!!.context)
                    root.skinCare.onCameraOpened(
                        cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT,
                        cameraInfo.orientation,
                        previewSize.width,
                        previewSize.height
                    )
                    tryToSetAutoFocus(camera)
                }
                this.cameraId = cameraId
            } catch (t: Throwable) {
                Log.e(TAG, "[startCamera] with error.", t)
                camera?.release()
                camera = null
            }
            this.camera = camera
        }

        private fun tryToSetPreviewAndPictureSize(camera: Camera, width: Int, height: Int) {
            val cameraParameters = camera.parameters
            val previewSizes = cameraParameters.supportedPreviewSizes
            var previewSize = cameraParameters.previewSize
            for (size in previewSizes) {
                if (width == size.width && height == size.height) {
                    cameraParameters.setPreviewSize(
                        width,
                        height
                    ) // Need app to have an arbitration approach to select performance matched preview size.
                    previewSize = cameraParameters.previewSize
                    break
                }
            }
            Log.d(TAG, "Camera preview size, width=${previewSize.width}, height=${previewSize.height}")
            val pictureSizes = cameraParameters.supportedPictureSizes
            var pictureSize = cameraParameters.pictureSize
            for (size in pictureSizes) {
                if (abs(size.width.toDouble() / size.height - previewSize.width.toDouble() / previewSize.height) < 0.01) { // Choose same aspect ratio.
                    cameraParameters.setPictureSize(size.width, size.height)
                    pictureSize = cameraParameters.pictureSize
                    break
                }
            }
            Log.d(TAG, "Camera picture size, width=${pictureSize.width}, height=${pictureSize.height}")
            camera.parameters = cameraParameters
        }

        private fun setupDisplayOrientation(camera: Camera, cameraInfo: Camera.CameraInfo, context: Context) {
            val windowManager = Objects.requireNonNull(
                context.getSystemService(Context.WINDOW_SERVICE),
                "Can't get WINDOW_SERVICE."
            ) as WindowManager
            val rotation = windowManager.defaultDisplay.rotation
            var degrees = 0
            when (rotation) {
                Surface.ROTATION_0 -> degrees = 0
                Surface.ROTATION_90 -> degrees = 90
                Surface.ROTATION_180 -> degrees = 180
                Surface.ROTATION_270 -> degrees = 270
            }
            var result: Int
            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                result = (cameraInfo.orientation + degrees) % 360
                result = (360 - result) % 360 // compensate the mirror
            } else {  // back-facing
                result = (cameraInfo.orientation - degrees + 360) % 360
            }
            camera.setDisplayOrientation(result)
        }

        private fun tryToSetAutoFocus(camera: Camera) {
            val cameraParameters = camera.parameters
            val cameraFocusModes = cameraParameters.supportedFocusModes
            when {
                cameraFocusModes.contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE) -> {
                    cameraParameters.focusMode = Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE
                    Log.d("[tryToSetAutoFocus]", "set focus mode: Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE")
                }
                cameraFocusModes.contains(Camera.Parameters.FOCUS_MODE_AUTO) -> {
                    cameraParameters.focusMode = Camera.Parameters.FOCUS_MODE_AUTO
                    Log.d("[tryToSetAutoFocus]", "set focus mode: Camera.Parameters.FOCUS_MODE_AUTO")
                }
                else -> {
                    Log.d("[tryToSetAutoFocus]", "not supported.")
                }
            }
            camera.parameters = cameraParameters
        }

        private val autoFocusCallback = Camera.AutoFocusCallback { success: Boolean, _ ->
            Log.d(TAG, "[Camera.AutoFocusCallback] success=$success")
        }

        private fun stopCamera() {
            Log.d(TAG, "[stopCamera]")
            val camera = this.camera
            if (camera != null) {
                camera.stopPreview()
                try {
                    camera.setPreviewDisplay(null)
                } catch (e: IOException) {
                    Log.e(TAG, "setPreviewTexture", e)
                }
                camera.setPreviewCallback(null)
                camera.release()
            }
            this.camera = null
        }

        private fun startPreview() {
            Log.d(TAG, "[startPreview]")
            val camera = this.camera
            if (camera != null) {
                try {
                    camera.startPreview()
                    Log.d(TAG, "[startPreview] start preview done")
                    camera.autoFocus(autoFocusCallback)
                    Log.d(TAG, "[startPreview] auto focus done")
                } catch (t: Throwable) {
                    Log.e(TAG, "[startPreview]", t)
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
        private val root: SkinCareCamView,
        cameraPreviewSize: Camera.Size
    ) : Camera.PreviewCallback {

        @MainThread
        private fun updateCameraContainerToFitAspectRatio(root: SkinCareCamView, previewWidth: Int, previewHeight: Int) {
             val fullWidth = root.relativeLayout.width
             val fullHeight = root.relativeLayout.height
             val needHeight =
                 if (previewWidth > previewHeight) {
                     previewWidth * fullWidth / previewHeight
                 } else {
                     previewHeight * fullWidth / previewWidth
                 }
             val paddingVertical = fullHeight - needHeight
             root.relativeLayout.setPadding(0, paddingVertical / 2, 0, paddingVertical / 2)
             runOnMainThread {
                  root.relativeLayout.measure(
                      View.MeasureSpec.makeMeasureSpec(root.relativeLayout.width, View.MeasureSpec.EXACTLY),
                      View.MeasureSpec.makeMeasureSpec(root.relativeLayout.height, View.MeasureSpec.EXACTLY)
                  )
             }
        }

        private var isFirstFrame = true
        private val previewWidth: Int
        private val previewHeight: Int

        init {
            previewWidth = cameraPreviewSize.width
            previewHeight = cameraPreviewSize.height
            if (previewWidth > 0 && previewHeight > 0) {
                runOnMainThread { updateCameraContainerToFitAspectRatio(root, previewWidth, previewHeight) }
            } else {
                Log.e("CameraPreviewCallback", "init preview width or height is 0")
            }
        }

        override fun onPreviewFrame(data: ByteArray?, camera: Camera) {
            if (data == null || root.isPaused) {
                return
            }
            root.skinCare.sendCameraBuffer(CameraFrame(data, previewWidth, previewHeight, isFirstFrame))
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
            val message = "SkinCareCamView status is not ready. status=${loadStatus}"
            Log.e(TAG, message)
            showAlertDialog(message)
            return false;
        }
        return true;
    }

    fun pause() {
        Log.d(TAG, "pause")
        isPaused = true
    }

    fun stop() {
        Log.d(TAG, "stop")
        isPaused = true
    }

    fun resume() {
        Log.d(TAG, "resume")
        isPaused = false
        skinCare.onResumed()
        if (isSurfaceViewCreated) {
            val root = getRootFragment()
            root?.startPreview()
        }
    }

    fun setImage(base64Png: String, callback: SkinCare.SetImageCallback) {
        if (checkStatus()) {
            Thread {
                val bitmap = convertBase64ToBitmap(base64Png)
                skinCare.setImage(bitmap, callback)
            }.start()
        }
    }

    private fun convertBase64ToBitmap(base64Png: String): Bitmap {
        val imageAsBytes = Base64.decode(base64Png, Base64.NO_PADDING or Base64.NO_WRAP);
        return BitmapFactory.decodeByteArray(imageAsBytes, 0, imageAsBytes.size);
    }

    fun takePicture() {
        if (isPaused) return
        if (checkStatus()) {
            val root = getRootFragment()
            root?.takePicture(CaptureCallback(this))
        }
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

    fun getAvailableFeatures(): List<String>? {
        return skinCare.availableFeatures
    }

    @Suppress("DEPRECATION")
    internal class CaptureCallback(private val root: SkinCareCamView) : Camera.PictureCallback {
        companion object {
            private const val MAXIMUM_BOUND = 1600f
        }

        /**
         * Scale down the image size to reduce the memory usage and do horizontal mirror for front camera.
         */
        private fun decodeImage(data: ByteArray): Bitmap {
            val options = BitmapFactory.Options()
            options.inPreferredConfig = Bitmap.Config.ARGB_8888

            // Decode the image size.
            options.inJustDecodeBounds = true
            BitmapFactory.decodeByteArray(data, 0, data.size, options)
            options.inJustDecodeBounds = false

            // Decode a smaller image by in sample size.
            var scale = MAXIMUM_BOUND / max(options.outWidth, options.outHeight)
            options.inSampleSize = floor((1 / scale).toDouble()).toInt()
            val bitmap = BitmapFactory.decodeByteArray(data, 0, data.size, options)
            val matrix = Matrix()
            // Rotate the image based on the EXIF.
            val rotate =
                try {
                    when (ExifInterface(ByteArrayInputStream(data)).getAttributeInt(ExifInterface.TAG_ORIENTATION, 0)) {
                        ExifInterface.ORIENTATION_ROTATE_270 -> 270
                        ExifInterface.ORIENTATION_ROTATE_180 -> 180
                        ExifInterface.ORIENTATION_ROTATE_90 -> 90
                        else -> 0
                    }
                } catch (_: Throwable) {
                    0
                }
            matrix.postRotate(rotate.toFloat())

            // Resize the image to the desired size and do horizontal flip.
            scale = MAXIMUM_BOUND / max(bitmap.width, bitmap.height)
            scale = if (scale > 1f) 1f else scale
            matrix.postScale(-scale, scale)
            return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        }

        override fun onPictureTaken(data: ByteArray, camera: Camera) {
            Log.d("CaptureCallback", "onPictureTaken")
            val picture: Bitmap = decodeImage(data)
            Thread {
                val bos = ByteArrayOutputStream()
                picture.compress(Bitmap.CompressFormat.PNG, 100, bos)
                val byteArray = bos.toByteArray()
                val base64Png = Base64.encodeToString(byteArray, Base64.NO_PADDING or Base64.NO_WRAP)
                root.invokeMethodChannelSafely("image", base64Png)
            }.start()
        }
    }

    fun getReports(callback: SkinCare.GetReportsCallback) {
        if (checkStatus()) {
            skinCare.getReports(skinCare.availableFeatures, callback)
        }
    }

    fun getOverallScore(callback: SkinCare.GetOverallScoreCallback) {
        if (checkStatus()) {
            skinCare.getOverallScore(callback)
        }
    }

    fun getAnalyzedImage(features: List<String>, callback: SkinCare.GetAnalyzedImageCallback) {
        if (checkStatus()) {
            skinCare.getAnalyzedImage(features, callback)
        }
    }

    fun getSkinTypes(callback: SkinCare.GetSkinTypesCallback) {
        if (checkStatus()) {
            skinCare.getSkinTypes(callback)
        }
    }

    fun getSkinTypeAnalyzedImage(callback: SkinCare.GetSkinTypeAnalyzedImageCallback) {
        if (checkStatus()) {
            skinCare.getSkinTypeAnalyzedImage(callback)
        }
    }

    fun showAlertDialog(message: String) {
        runOnMainThread { 
            if (activity != null) {
                AlertDialog.Builder(activity)
                .setTitle("")
                .setMessage(message)
                .setPositiveButton("OK", null)
                .show()
            }
        }
    }
}