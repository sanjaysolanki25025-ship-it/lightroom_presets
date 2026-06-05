package com.lumio.lrpresets

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Handle the splash screen transition.
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)
        splashScreen.setKeepOnScreenCondition { false }
    }
    private val rowFactoryId = "row_native_ad"
    private val mediumFactoryId = "medium_native_ad"
    private val fullFactoryId = "full_screen_native_ad"
    private val CHANNEL = "com.nebalcore.lightroom/navigation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        io.flutter.plugin.common.MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openInLightroom") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    openLightroom(filePath)
                    result.success(true)
                } else {
                    result.error("INVALID_PATH", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
        // Small / Row Native Ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            rowFactoryId,
            RowNativeAdFactory(this)
        )

        // Medium Native Ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            mediumFactoryId,
            MediumNativeAdFactory(this)
        )

        // Full Native Ad
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            fullFactoryId,
            FullNativeAdFactory(this)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, rowFactoryId)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, mediumFactoryId)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, fullFactoryId)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun openLightroom(filePath: String) {
        try {
            val file = File(filePath)
            val uri: Uri = FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                file
            )

            val intent = Intent(Intent.ACTION_SEND)
            intent.type = "image/*"
            intent.setPackage("com.adobe.lrmobile")
            intent.putExtra(Intent.EXTRA_STREAM, uri)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

            startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
