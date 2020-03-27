package com.nover.flutternativeadmob

import android.content.Context
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.formats.UnifiedNativeAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NativeAdmobController(
        val id: String,
        private val channel: MethodChannel,
        private val context: Context
) : MethodChannel.MethodCallHandler {

    enum class CallMethod {
        setAdUnitID, reloadAd
    }

    enum class LoadState {
        loading, loadError, loadCompleted,impression, leftApplication
    }

    var nativeAdChanged: ((UnifiedNativeAd?) -> Unit)? = null
    var nativeAd: UnifiedNativeAd? = null
        set(value) {
            field = value
            invokeLoadCompleted()
        }

    private var adLoader: AdLoader? = null
    private var adUnitID: String? = null
    private var testDevices: List<String>? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (CallMethod.valueOf(call.method)) {
            CallMethod.setAdUnitID -> {
                call.argument<String>("adUnitID")?.let {
                    val isChanged = adUnitID != it
                    adUnitID = it

                    if (adLoader == null || isChanged) {
                        val builder = AdLoader.Builder(context, it)
                        adLoader = builder.forUnifiedNativeAd { nativeAd ->
                            this.nativeAd = nativeAd
                        }.withAdListener(object : AdListener() {
                            override fun onAdFailedToLoad(errorCode: Int) {
                                println("onAdFailedToLoad errorCode = $errorCode")
                                channel.invokeMethod(LoadState.loadError.toString(), null)
                            }

                            override fun onAdLeftApplication() {
                                println("leftApplication")
                                channel.invokeMethod(LoadState.leftApplication.toString(), null)
                            }
                            override fun onAdImpression() {
                                println("onAdImpression")
                                channel.invokeMethod(LoadState.impression.toString(), null)
                            }
                        }).build()
                    }
                    call.argument<List<String>>("testDevices")?.let { it ->
                        testDevices = it
                    }
                    if (nativeAd == null || isChanged) loadAd(testDevices) else invokeLoadCompleted()
                } ?: result.success(null)
            }

            CallMethod.reloadAd -> {
                call.argument<Boolean>("forceRefresh")?.let {
                    if (it || nativeAd == null) loadAd(testDevices) else invokeLoadCompleted()
                }
            }
        }
    }

    private fun loadAd(testDevice: List<String>?) {
        channel.invokeMethod(LoadState.loading.toString(), null)

        var adRequest = AdRequest.Builder()
        testDevice?.let {
            for (item in it) {
                adRequest.addTestDevice(item)
            }
        }
        adLoader?.loadAd(adRequest.build())
    }

    private fun invokeLoadCompleted() {
        nativeAdChanged?.let { it(nativeAd) }
        channel.invokeMethod(LoadState.loadCompleted.toString(), null)
    }
}

object NativeAdmobControllerManager {
    private val controllers: ArrayList<NativeAdmobController> = arrayListOf()

    fun createController(id: String, binaryMessenger: BinaryMessenger, context: Context) {
        if (getController(id) == null) {
            val methodChannel = MethodChannel(binaryMessenger, id)
            val controller = NativeAdmobController(id, methodChannel, context)
            controllers.add(controller)
        }
    }

    fun getController(id: String): NativeAdmobController? {
        return controllers.firstOrNull { it.id == id }
    }

    fun removeController(id: String) {
        val index = controllers.indexOfFirst { it.id == id }
        if (index >= 0) controllers.removeAt(index)
    }
}