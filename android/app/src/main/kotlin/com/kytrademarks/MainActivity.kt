package com.kytrademarks

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val channelName = "com.kytrademarks/file_saver"
    private val savePdfRequestCode = 43021
    private var pendingPdfPath: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfFile" -> {
                        val filePath = call.argument<String>("filePath")
                        val fileName = call.argument<String>("fileName") ?: "attachments.pdf"
                        if (filePath.isNullOrEmpty()) {
                            result.error("invalid_file", "Missing PDF file path.", null)
                            return@setMethodCallHandler
                        }

                        savePdfFile(filePath, fileName, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun savePdfFile(filePath: String, fileName: String, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("save_in_progress", "Another save operation is already running.", null)
            return
        }

        val sourceFile = File(filePath)
        if (!sourceFile.exists() || sourceFile.length() == 0L) {
            result.error("empty_file", "The generated PDF file is empty.", null)
            return
        }

        pendingPdfPath = filePath
        pendingResult = result

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/pdf"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }

        startActivityForResult(intent, savePdfRequestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != savePdfRequestCode) return

        val result = pendingResult
        val filePath = pendingPdfPath
        pendingResult = null
        pendingPdfPath = null

        if (result == null) return

        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }

        val destinationUri: Uri? = data?.data
        if (destinationUri == null || filePath == null) {
            result.error("invalid_destination", "No destination selected.", null)
            return
        }

        try {
            val sourceFile = File(filePath)
            contentResolver.openOutputStream(destinationUri, "w")?.use { output ->
                sourceFile.inputStream().use { input ->
                    input.copyTo(output)
                    output.flush()
                }
            } ?: run {
                result.error("save_failed", "Could not open selected destination.", null)
                return
            }

            result.success(destinationUri.toString())
        } catch (exception: Exception) {
            result.error("save_failed", exception.message, null)
        }
    }
}
