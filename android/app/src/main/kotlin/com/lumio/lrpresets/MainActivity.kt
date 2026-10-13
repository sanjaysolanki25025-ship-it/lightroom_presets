package com.lumio.lrpresets

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import android.content.ClipData
import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
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
            when (call.method) {
                "openInLightroom" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val opened = openLightroom(filePath)
                        if (opened) {
                            result.success(true)
                        } else {
                            result.error("FAILED_TO_OPEN", "Could not open file in Lightroom", null)
                        }
                    } else {
                        result.error("INVALID_PATH", "File path is null", null)
                    }
                }
                "saveToDownloads" -> {
                    val filePath = call.argument<String>("filePath")
                    val fileName = call.argument<String>("fileName")
                    if (filePath != null && fileName != null) {
                        val saved = saveToDownloads(filePath, fileName)
                        if (saved) {
                            result.success(true)
                        } else {
                            result.error("SAVE_FAILED", "Failed to save file to Downloads", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "filePath or fileName is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
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

    private fun openLightroom(filePath: String): Boolean {
        return try {
            val file = File(filePath)
            if (!file.exists()) {
                return false
            }
            val uri: Uri = FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                file
            )

            grantUriPermission("com.adobe.lrmobile", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)

            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "image/*"
                setPackage("com.adobe.lrmobile")
                putExtra(Intent.EXTRA_STREAM, uri)
                clipData = ClipData.newRawUri("preset", uri)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun saveToDownloads(filePath: String, fileName: String): Boolean {
        val sourceFile = File(filePath)
        if (!sourceFile.exists()) {
            return false
        }

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val mimeType = if (fileName.endsWith(".dng", ignoreCase = true)) {
                    "image/x-adobe-dng"
                } else {
                    "image/*"
                }

                val contentValues = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                    put(MediaStore.Downloads.MIME_TYPE, mimeType)
                    put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }

                val resolver = applicationContext.contentResolver
                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                    ?: return false

                resolver.openOutputStream(uri)?.use { outputStream ->
                    sourceFile.inputStream().use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }

                contentValues.clear()
                contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
                resolver.update(uri, contentValues, null, null)
                true
            } else {
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                if (!downloadsDir.exists()) {
                    downloadsDir.mkdirs()
                }
                val destinationFile = File(downloadsDir, fileName)
                sourceFile.copyTo(destinationFile, overwrite = true)
                val mimeType = if (fileName.endsWith(".dng", ignoreCase = true)) {
                    "image/x-adobe-dng"
                } else {
                    "image/*"
                }
                MediaScannerConnection.scanFile(
                    applicationContext,
                    arrayOf(destinationFile.absolutePath),
                    arrayOf(mimeType),
                    null
                )
                true
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
