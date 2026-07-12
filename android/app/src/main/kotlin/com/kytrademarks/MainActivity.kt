package com.kytrademarks

import android.app.Activity
import android.Manifest
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val channelName = "com.kytrademarks/file_saver"
    private val savePdfRequestCode = 43021
    private val saveImagePermissionRequestCode = 43022
    private var pendingPdfPath: String? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingImagePath: String? = null
    private var pendingImageName: String? = null
    private var pendingImageResult: MethodChannel.Result? = null

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
                    "saveImageFile" -> {
                        val filePath = call.argument<String>("filePath")
                        val fileName = call.argument<String>("fileName") ?: "attachment.jpg"
                        if (filePath.isNullOrEmpty()) {
                            result.error("invalid_file", "Missing image file path.", null)
                            return@setMethodCallHandler
                        }

                        saveImageFile(filePath, fileName, result)
                    }
                    "saveFile" -> {
                        val filePath = call.argument<String>("filePath")
                        val fileName = call.argument<String>("fileName") ?: "attachment.bin"
                        if (filePath.isNullOrEmpty()) {
                            result.error("invalid_file", "Missing attachment file path.", null)
                            return@setMethodCallHandler
                        }

                        saveImageFile(filePath, fileName, result)
                    }
                    "openFile" -> {
                        val uri = call.argument<String>("uri")
                        val fileName = call.argument<String>("fileName") ?: "attachment.bin"
                        if (uri.isNullOrEmpty()) {
                            result.error("invalid_uri", "Missing saved file URI.", null)
                            return@setMethodCallHandler
                        }

                        openSavedFile(uri, fileName, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveImageFile(filePath: String, fileName: String, result: MethodChannel.Result) {
        val sourceFile = File(filePath)
        if (!sourceFile.exists() || sourceFile.length() == 0L) {
            result.error("empty_file", "The downloaded image file is empty.", null)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
        ) {
            pendingImagePath = filePath
            pendingImageName = fileName
            pendingImageResult = result
            requestPermissions(
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                saveImagePermissionRequestCode
            )
            return
        }

        writeImageToDownloads(sourceFile, fileName, result)
    }

    private fun writeImageToDownloads(
        sourceFile: File,
        fileName: String,
        result: MethodChannel.Result
    ) {
        try {
            val extension = fileName.substringAfterLast('.', "jpg").lowercase()
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
                ?: "application/octet-stream"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        "${Environment.DIRECTORY_DOWNLOADS}/KY Trademarks"
                    )
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
                val uri = contentResolver.insert(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    values
                ) ?: throw IllegalStateException("Could not create image in Downloads.")

                contentResolver.openOutputStream(uri, "w")?.use { output ->
                    sourceFile.inputStream().use { input -> input.copyTo(output) }
                } ?: throw IllegalStateException("Could not open image destination.")

                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
                result.success(uri.toString())
                return
            }

            @Suppress("DEPRECATION")
            val downloadsDirectory = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                "KY Trademarks"
            ).apply { mkdirs() }
            val destination = File(downloadsDirectory, fileName)
            sourceFile.copyTo(destination, overwrite = true)
            MediaScannerConnection.scanFile(
                this,
                arrayOf(destination.absolutePath),
                arrayOf(mimeType),
                null
            )
            result.success(destination.absolutePath)
        } catch (exception: Exception) {
            result.error("save_failed", exception.message, null)
        }
    }

    private fun openSavedFile(
        uriValue: String,
        fileName: String,
        result: MethodChannel.Result
    ) {
        try {
            val extension = fileName.substringAfterLast('.', "").lowercase()
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
                ?: "application/octet-stream"
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(Uri.parse(uriValue), mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(Intent.createChooser(intent, "فتح الملف"))
            result.success(true)
        } catch (exception: Exception) {
            result.error("open_failed", exception.message, null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != saveImagePermissionRequestCode) return

        val result = pendingImageResult
        val filePath = pendingImagePath
        val fileName = pendingImageName
        pendingImageResult = null
        pendingImagePath = null
        pendingImageName = null

        if (result == null || filePath == null || fileName == null) return
        if (grantResults.firstOrNull() != PackageManager.PERMISSION_GRANTED) {
            result.error("permission_denied", "Storage permission was denied.", null)
            return
        }

        writeImageToDownloads(File(filePath), fileName, result)
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
