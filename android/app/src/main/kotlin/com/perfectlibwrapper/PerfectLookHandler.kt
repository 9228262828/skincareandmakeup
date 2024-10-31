package com.perfectlibwrapper

import android.content.Context
import android.util.Log
import com.perfectcorp.perfectlib.LookHandler
import com.perfectcorp.perfectlib.LookInfo
import com.perfectcorp.perfectlib.LookType
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PerfectLookHandler internal constructor(val applicationContext: Context?): MethodChannel.MethodCallHandler {
    private val TAG = "PerfectLookHandler"

    companion object {
        const val LOOK_GUIDS = "lookGuids"
        const val GUID = "guid"
        const val NAME = "name"
        const val THUMBNAIL = "thumbnail"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
            call.method == "checkNeedUpdate" -> {
                checkNeedUpdate(result)
            }
            call.method == "syncServer" -> {
                syncServer(result)
            }
            call.method == "getList" -> {
                getList(result)
            }
            call.method == "downloadLook" -> {
                downloadLook(call, result)
            }
            call.method == "clear" -> {
                clear(result)
            }
        }
    }

    fun checkNeedUpdate(result: MethodChannel.Result) {
        Log.d(TAG, "checkNeedUpdate")
        LookHandler.getInstance().checkNeedToUpdate(LookType.MAKEUP, object : LookHandler.CheckNeedToUpdateCallback {
            override fun onSuccess(needToUpdate: Boolean) {
                Log.d(TAG, "checkNeedUpdate onSuccess")
                result.success(needToUpdate)
            }

            override fun onFailure(throwable: Throwable?) {
                Log.d(TAG, "onFailure")
                result.error("false","checkNeedUpdate failed.", throwable.toString())
            }

        })
    }

    fun syncServer(result: MethodChannel.Result) {
        Log.d(TAG, "checkNeedUpdate")
        LookHandler.getInstance().syncServer(LookType.MAKEUP, object : LookHandler.SyncServerCallback {
            override fun onSuccess() {
                Log.d(TAG, "checkNeedUpdate onSuccess")
                result.success(true)
            }

            override fun onFailure(throwable: Throwable?) {
                Log.d(TAG, "onFailure")
                result.error("false","syncServer failed.", throwable.toString())
            }

        })
    }

    fun getList(result: MethodChannel.Result) {
        Log.d(TAG, "getList")
        LookHandler.getInstance().getList(LookType.MAKEUP, object : LookHandler.GetListCallback {
            override fun onSuccess(lookInfos: List<LookInfo>) {
                Log.d(TAG, "getList onSuccess")
                var lookGuids = lookInfos.map { it.guid.toString() }
                Log.d(TAG, "lookGuids: $lookGuids")
                var names = lookInfos.map { it.name.toString() }
                Log.d(TAG, "names: $names")
                var thumbnailUrls = lookInfos.map { it.thumbnailUrl.toString() }
                Log.d(TAG, "thumbnailUrls: $thumbnailUrls")
                var list: MutableList<Map<String, String>> = mutableListOf()
                lookInfos.forEachIndexed { index, element ->
                    val tmp = listOf(lookGuids[index], names[index], thumbnailUrls[index])
                    val map = mapOf(GUID to tmp.first(), NAME to tmp.get(1), THUMBNAIL to tmp.get(2))
                    Log.d(TAG, "map: $map")
                    list.add(map)
                }
                Log.d(TAG, "getList: $list")
                result.success(list)
            }

            override fun onFailure(throwable: Throwable?) {
                Log.d(TAG, "onFailure")
                result.error("false","getList failed.", throwable.toString())
            }

        })
    }

    fun downloadLook(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "downloadLook")
        var arg = call.arguments
        Log.d(TAG, "arg: $arg")
        var guid = call.argument<String>(LOOK_GUIDS)
        val guidList = listOf(guid)
        Log.d(TAG, "guid $guid")
        LookHandler.getInstance().downloadLooks(guidList , object : LookHandler.DownloadLooksCallback {
            override fun progress(downloadedCount: Int, totalCount: Int) {
                Log.d(TAG, "downloadLook profress")
                val progress = downloadedCount.toDouble() / totalCount
                Log.d(TAG, "[progress] : $progress")
            }

            override fun onComplete(lookInfos: Map<String, LookInfo>?, errors: Map<String, Throwable>?) {
                Log.d(TAG, "downloadLook onComplete")
                if (lookInfos != null) {
                    Log.d(TAG, "lookInfos $lookInfos")
                    val lookInfo = lookInfos.get(guid)
                    val map = mapOf(GUID to lookInfo?.guid.toString(), NAME to lookInfo?.name.toString(), THUMBNAIL to lookInfo?.thumbnailUrl.toString())
                    result.success(map)
                }
            }
        })
    }

    fun clear(result: MethodChannel.Result) {
        Log.d(TAG, "clear")
        LookHandler.getInstance().clearAll(LookType.MAKEUP, LookHandler.ClearCallback {  })
        result.success(null)
    }
}