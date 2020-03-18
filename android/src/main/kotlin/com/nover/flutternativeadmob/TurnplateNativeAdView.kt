package com.nover.flutternativeadmob

import android.content.Context
import android.graphics.Color
import android.graphics.PorterDuff
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import com.google.android.gms.ads.formats.MediaView
import com.google.android.gms.ads.formats.UnifiedNativeAd
import com.google.android.gms.ads.formats.UnifiedNativeAdView

class TurnplateNativeAdView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

  var options = NativeAdmobOptions()
    set(value) {
      field = value
      updateOptions()
    }

  private val adView: UnifiedNativeAdView

  private val adHeadline: TextView

  private val adBody: TextView
  private val adAttribution: TextView
  private val callToAction: Button

  init {
    val inflater = LayoutInflater.from(context)
    inflater.inflate(R.layout.native_admob_juscall_turnplate, this, true)

    setBackgroundColor(Color.TRANSPARENT)

    adView = findViewById(R.id.ad_view_turn)

    adHeadline = adView.findViewById(R.id.ad_headline_turn)

    adBody = adView.findViewById(R.id.ad_body_turn)

    adAttribution = adView.findViewById(R.id.ad_attribution_turn)

    callToAction = adView.findViewById(R.id.ad_call_to_action_turn)

    initialize()
  }

  private fun initialize() {

    // Register the view used for each individual asset.
    adView.headlineView = adHeadline
    adView.bodyView = adBody
    adView.callToActionView = callToAction
    adView.iconView = adView.findViewById(R.id.ad_icon_turn)

  }

  fun setNativeAd(nativeAd: UnifiedNativeAd?) {
    if (nativeAd == null) return

    // Some assets are guaranteed to be in every UnifiedNativeAd.
    adHeadline.text = nativeAd.headline
    adBody.text = nativeAd.body
    (adView.callToActionView as Button).text = nativeAd.callToAction

    // These assets aren't guaranteed to be in every UnifiedNativeAd, so it's important to
    // check before trying to display them.
    val icon = nativeAd.icon

    if (icon == null) {
      adView.iconView.visibility = View.INVISIBLE
    } else {
      (adView.iconView as ImageView).setImageDrawable(icon.drawable)
      adView.iconView.visibility = View.VISIBLE
    }
    // Assign native ad object to the native view.
    adView.setNativeAd(nativeAd)
  }

  private fun updateOptions() {
//    options.adLabelTextStyle.backgroundColor?.let {
//      adAttribution.background = it.toRoundedColor(3f)
//    }
//    adAttribution.textSize = options.adLabelTextStyle.fontSize
//    adAttribution.setTextColor(options.adLabelTextStyle.color)
//
//    adHeadline.setTextColor(options.headlineTextStyle.color)
//    adHeadline.textSize = options.headlineTextStyle.fontSize
//
//
//    adBody.setTextColor(options.bodyTextStyle.color)
//    adBody.textSize = options.bodyTextStyle.fontSize
//    callToAction.setTextColor(options.callToActionStyle.color)
//    callToAction.textSize = options.callToActionStyle.fontSize
//    options.callToActionStyle.backgroundColor?.let {
//      callToAction.setBackgroundColor(it)
//    }
  }
}