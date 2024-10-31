package com.perfectlibwrapper

import android.content.Context
import android.util.Log
import android.graphics.Color
import com.perfectcorp.perfectlib.PerfectEffect
import com.perfectcorp.perfectlib.ProductInfo
import com.perfectcorp.perfectlib.SkuHandler
import com.perfectcorp.perfectlib.SkuInfo
import com.perfectcorp.perfectlib.VtoObject
import com.perfectcorp.perfectlib.VtoPalette
import com.perfectcorp.perfectlib.VtoPattern
import com.perfectcorp.perfectlib.VtoWearingStyle
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PerfectSkuHandler internal constructor(val applicationContext: Context?, val methodChannel: MethodChannel?): MethodChannel.MethodCallHandler {
    private val TAG = "PerfectSkuHandler"

    fun invokeMethod(methodName: String, arguments: Any?) {
        methodChannel?.invokeMethod(methodName, arguments)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkNeedUpdate" -> checkNeedUpdate(result)
            "syncServer" -> syncServer(result)
            "getList" -> getList(call, result)
            "getSkus" -> getSkus(call, result)
            "getWearingStyles" -> getWearingStyles(call, result)
            "getPalettes" -> getPalettes(call, result)
            "getPatterns" -> getPatterns(call, result)
            "clear" -> clear(result)
            "dispose" -> dispose(result)
        }
    }

    fun checkNeedUpdate(result: MethodChannel.Result) {
        Log.d(TAG, "action checkNeedUpdate")
        SkuHandler.getInstance().checkNeedToUpdate(object : SkuHandler.CheckNeedToUpdateCallback {
            override fun onSuccess(needToUpdate: Boolean) {
                Log.d(TAG, "checkNeedUpdate onSuccess")
                result.success(needToUpdate)
            }

            override fun onFailure(throwable: Throwable?) {
                Log.d(TAG, "onFailure")
                invokeMethod("error", throwable)
                result.error("false","checkNeedUpdate failed.", throwable.toString())
            }
        })
    }

    fun syncServer(result: MethodChannel.Result) {
        Log.d(TAG, "action checkNeedUpdate")
        SkuHandler.getInstance().syncServer(object : SkuHandler.SyncServerCallback {
            override fun onSuccess() {
                Log.d(TAG, "syncServer onSuccess")
                result.success(true)
            }

            override fun progress(progress: Double) {
                Log.d(TAG, "progress $progress")
                invokeMethod("progress", progress.toString())
            }

            override fun onFailure(throwable: Throwable?) {
                Log.d(TAG, "onFailure")
                invokeMethod("error", throwable)
                result.error("false", "syncServer failed.", throwable.toString())
            }
        })
    }

    fun getList(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getList")
        val effect = call.argument<String>("effect");
        SkuHandler.getInstance().getListByEffect(effectNameToEffect(effect!!), object : SkuHandler.GetListCallback {
            override fun onSuccess(productInfos: List<ProductInfo>) {
                Log.d(TAG, "getList onSuccess")
                if (productInfos.isNotEmpty()) {
                    result.success(productToMap(productInfos))
                } else {
                    result.success(null)
                }
            }

            override fun onFailure(throwable: Throwable) {
                invokeMethod("error", throwable)
                result.error("false", "getList failed.", throwable.toString())
            }
        })
    }

    fun getSkus(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getSkus")
        val guid = call.argument<String>("productGuid");
        SkuHandler.getInstance().getProductInfosWithGuids(listOf(guid)) { productInfos: List<ProductInfo> ->
            val productInfo = productInfos.find { it.guid == guid }
            if (productInfo == null) {
                Log.e(TAG, "[getSkus] can't find product info '$guid'")
                result.success(null)
            }
            result.success(skuToMap(productInfo!!, productInfo.skus))
        }
    }

    fun getWearingStyles(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getWearingStyles")
        val skuGuid = call.argument<String>("skuGuid");
        SkuHandler.getInstance().getSkuInfosWithGuids(listOf(skuGuid), object : SkuHandler.GetSkuInfosWithGuidsCallback {
            override fun onComplete(skus: List<SkuInfo>) {
                Log.d(TAG, "getSkuInfosWithGuids onSuccess")
                if (skus.isNullOrEmpty()) {
                    result.success(null)
                }
                val sku = skus[0]
                sku.vtoDetail?.getWearingStyles(object: VtoObject.Callback<VtoWearingStyle> {
                    override fun onSuccess(wearingStyles: List<VtoWearingStyle>) {
                        if (wearingStyles.isNotEmpty()) {
                            result.success(wearingStyleToMap(wearingStyles))
                        } else {
                            result.success(null)
                        }
                    }

                    override fun onFailure(throwable: Throwable) {
                        result.success(null)
                    }
                })
            }
        })
    }

    fun getPalettes(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getPalettes")
        val skuGuid = call.argument<String>("skuGuid");
        val patternGuid = call.argument<String>("patternGuid");
        SkuHandler.getInstance().getSkuInfosWithGuids(listOf(skuGuid), object : SkuHandler.GetSkuInfosWithGuidsCallback {
            override fun onComplete(skus: List<SkuInfo>) {
                Log.d(TAG, "getSkuInfosWithGuids onSuccess")
                if (skus.isNullOrEmpty()) {
                    result.success(null)
                }
                val skuInfo = skus[0]
                if (!patternGuid.isNullOrEmpty()) {
                    skuInfo.vtoDetail.getPatterns(object : VtoObject.Callback<VtoPattern> {
                        override fun onSuccess(data: List<VtoPattern>) {
                            val vtoPattern = data.find { it.guid == patternGuid }
                            if (vtoPattern == null) {
                                Log.e(TAG, "[getPalettes] can't find pattern '$patternGuid' in SKU '$skuGuid'")
                                result.success(null)
                                return
                            }
                            vtoPattern.getPalettes(object : VtoObject.Callback<VtoPalette> {
                                override fun onSuccess(data: List<VtoPalette>) {
                                    if (data.isNotEmpty()) {
                                        result.success(paletteToMap(data))
                                    } else {
                                        result.success(null)
                                    }
                                }
    
                                override fun onFailure(throwable: Throwable) {
                                    result.success(null)
                                }
                            })
                        }
    
                        override fun onFailure(throwable: Throwable) {
                            result.success(null)
                        }
                    })
                } else {
                    skuInfo.vtoDetail.getPalettes(object : VtoObject.Callback<VtoPalette> {
                        override fun onSuccess(data: List<VtoPalette>) {
                            result.success(paletteToMap(data))
                        }
    
                        override fun onFailure(throwable: Throwable) {
                            result.success(null)
                        }
                    })
                }
            }
        })
    }

    fun getPatterns(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "action getPatterns")
        val skuGuid = call.argument<String>("skuGuid");
        val paletteGuid = call.argument<String>("paletteGuid");
        SkuHandler.getInstance().getSkuInfosWithGuids(listOf(skuGuid), object : SkuHandler.GetSkuInfosWithGuidsCallback {
            override fun onComplete(skus: List<SkuInfo>) {
                Log.d(TAG, "getSkuInfosWithGuids onSuccess")
                if (skus.isNullOrEmpty()) {
                    result.success(null)
                }
                val skuInfo = skus[0]
                if (!paletteGuid.isNullOrEmpty()) {
                    skuInfo.vtoDetail.getPalettes(object : VtoObject.Callback<VtoPalette> {
                        override fun onSuccess(data: List<VtoPalette>) {
                            val vtoPalette = data.find { it.guid == paletteGuid }
                            if (vtoPalette == null) {
                                Log.e(TAG, "[getPatterns] can't find palette '$paletteGuid' in SKU '$skuGuid'")
                                result.success(null)
                                return
                            }
                            vtoPalette.getPatterns(object : VtoObject.Callback<VtoPattern> {
                                override fun onSuccess(data: List<VtoPattern>) {
                                    if (data.isNotEmpty()) {
                                        result.success(patternToMap(data))
                                    } else {
                                        result.success(null)
                                    }
                                }
    
                                override fun onFailure(throwable: Throwable) {
                                    Log.e(TAG, "[getPatterns] can't find pattern for '$paletteGuid' in SKU '$skuGuid'")
                                    result.success(null)
                                }
                            })
                        }
    
                        override fun onFailure(throwable: Throwable) {
                            result.success(null)
                        }
                    })
                } else {
                    skuInfo.vtoDetail.getPatterns(object : VtoObject.Callback<VtoPattern> {
                        override fun onSuccess(data: List<VtoPattern>) {
                            if (data.isNotEmpty()) {
                                result.success(patternToMap(data))
                            } else {
                                result.success(null)
                            }
                        }
    
                        override fun onFailure(throwable: Throwable) {
                            result.success(null)
                        }
                    })
                }
            }
        })
    }

    fun clear(result: MethodChannel.Result) {
        Log.d(TAG, "action clear")
        SkuHandler.getInstance().clearAll(object: SkuHandler.ClearCallback {
            override fun onCleared() {
                result.success(null)
            }
        })
    }

    fun dispose(result: MethodChannel.Result) {
        Log.d(TAG, "action dispose")
        result.success(null)
    }

    fun productToMap(infoList: List<ProductInfo>): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        for(info in infoList) {
            val map = hashMapOf<String, String>()
            map.put("guid", info.guid)
            map.put("name", info.name)
            map.put("thumbnail", info.thumbnailUrl)
            list.add(map)
        }
        return list
    }

    fun skuToMap(productInfo: ProductInfo, skus: List<SkuInfo>): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        for(sku in skus) {
            val map = hashMapOf<String, String>()
            if (productInfo.perfectEffect == PerfectEffect.EARRINGS) {
                map.put("guid", sku.guid)
                map.put("name", sku.name)
                map.put("thumbnail", productInfo.thumbnailUrl)
            } else {
                map.put("guid", sku.guid)
                map.put("name", sku.name)
                map.put("thumbnail", sku.thumbnailUrl)
            }
            list.add(map)
        }
        return list
    }

    fun wearingStyleToMap(wearingStyles: List<VtoWearingStyle>): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        for((index, style) in wearingStyles.withIndex()) {
            val map = hashMapOf<String, String>()
            map.put("guid", style.guid)
            map.put("name", String.format("WS%02d", index + 1))
            map.put("thumbnail", style.thumbnailUrl)
            list.add(map)
        }
        return list
    }

    fun paletteToMap(palettes: List<VtoPalette>): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        for(palette in palettes) {
            val map = hashMapOf<String, Any>()
            val colorString: List<String> = palette.colors.map { color ->
                "#%02X%02X%02X".format(Color.red(color), Color.green(color), Color.blue(color))
            }

            // Log.d("yuki33", "colorString: $colorString")

            map.put("guid", palette.guid)
            map.put("colors", colorString)
            list.add(map)
        }
        return list
    }

    fun patternToMap(patterns: List<VtoPattern>): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        for(pattern in patterns) {
            val map = hashMapOf<String, String>()
            map.put("guid", pattern.guid)
            map.put("name", pattern.name)
            map.put("thumbnail", pattern.thumbnailUrl)
            list.add(map)
        }
        return list
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