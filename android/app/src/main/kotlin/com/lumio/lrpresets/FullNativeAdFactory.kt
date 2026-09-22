package com.lumio.lrpresets

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView

import com.google.android.libraries.ads.mobile.sdk.common.VideoController
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class FullNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.native_full_ad, null) as NativeAdView

        // Headline
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.text = nativeAd.headline

        // Rating
        adView.starRatingView = adView.findViewById(R.id.ad_stars)
        if (nativeAd.starRating == null) {
            adView.starRatingView?.visibility = View.GONE
        } else {
            (adView.starRatingView as? RatingBar)?.rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        // Body
        adView.bodyView = adView.findViewById(R.id.ad_body)
        if (nativeAd.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as? TextView)?.text = nativeAd.body
        }

        // Call to action
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        (adView.callToActionView as? Button)?.text = nativeAd.callToAction

        // Icon
        adView.iconView = adView.findViewById(R.id.ad_app_icon)
        if (nativeAd.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as? ImageView)?.setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        // Media
        val media = adView.findViewById<MediaView>(R.id.ad_media)
        media?.let { m ->
            m.imageScaleType = ImageView.ScaleType.CENTER_CROP

            val mediaContent = nativeAd.mediaContent
            val videoAspectRatio = mediaContent?.aspectRatio ?: 0f

            m.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
                applyCenterCrop(m, videoAspectRatio)
            }

            m.setOnHierarchyChangeListener(object : ViewGroup.OnHierarchyChangeListener {
                override fun onChildViewAdded(parent: View?, child: View?) {
                    applyCenterCrop(m, videoAspectRatio)
                }
                override fun onChildViewRemoved(parent: View?, child: View?) {}
            })
        }

        // Advertiser
        adView.advertiserView = adView.findViewById(R.id.ad_advertiser)
        if (nativeAd.advertiser == null) {
            adView.advertiserView?.visibility = View.GONE
        } else {
            (adView.advertiserView as? TextView)?.text = nativeAd.advertiser
            adView.advertiserView?.visibility = View.VISIBLE
        }

        // Customizing CTA Button Programmatically
        val ctaButton = adView.callToActionView as? Button
        if (ctaButton != null) {
            val buttonBg = GradientDrawable()
            buttonBg.setColor(Color.parseColor("#2E5BFF"))
            buttonBg.cornerRadius = 10f // Adjusted for full-width feel
            ctaButton.background = buttonBg
            ctaButton.setTextColor(Color.WHITE)
        }

        adView.registerNativeAd(nativeAd, media)

        // Ensure video is unmuted
        val videoController = nativeAd.mediaContent?.videoController
        if (videoController != null) {
            videoController.mute(false)
            videoController.videoLifecycleCallbacks = object : VideoController.VideoLifecycleCallbacks {
                override fun onVideoPlay() {
                    videoController.mute(false)
                }
            }
        }
        return adView
    }

    private fun applyCenterCrop(mediaView: MediaView, videoAspectRatio: Float) {
        if (videoAspectRatio <= 0f) return
        val width = mediaView.width
        val height = mediaView.height
        if (width <= 0 || height <= 0) return

        val containerAspectRatio = width.toFloat() / height.toFloat()
        val scale = if (videoAspectRatio > containerAspectRatio) {
            videoAspectRatio / containerAspectRatio
        } else {
            containerAspectRatio / videoAspectRatio
        }

        fun scaleView(view: View) {
            if (view is android.view.TextureView) {
                view.scaleX = scale
                view.scaleY = scale
            } else if (view is ImageView) {
                view.scaleType = ImageView.ScaleType.CENTER_CROP
            } else if (view is ViewGroup) {
                for (i in 0 until view.childCount) {
                    scaleView(view.getChildAt(i))
                }
            }
        }
        scaleView(mediaView)
    }
}
