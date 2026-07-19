package com.tallyjie.tallyjie

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val backupChannel = "com.tallyjie.tallyjie/backup"
    private val createBackupDocumentRequest = 7301
    private var pendingSaveResult: MethodChannel.Result? = null
    private var pendingZipBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, backupChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveZip" -> {
                    if (pendingSaveResult != null) {
                        result.error("busy", "已有导出任务正在进行", null)
                        return@setMethodCallHandler
                    }
                    val fileName = call.argument<String>("fileName") ?: "TallyJie_backup.zip"
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("invalid_args", "缺少备份数据", null)
                        return@setMethodCallHandler
                    }
                    pendingSaveResult = result
                    pendingZipBytes = bytes
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "application/zip"
                        putExtra(Intent.EXTRA_TITLE, fileName)
                    }
                    startActivityForResult(intent, createBackupDocumentRequest)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != createBackupDocumentRequest) return

        val result = pendingSaveResult
        val bytes = pendingZipBytes
        pendingSaveResult = null
        pendingZipBytes = null

        if (result == null) return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        val uri: Uri = data.data!!
        try {
            contentResolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
                output.flush()
            } ?: throw IllegalStateException("无法打开导出位置")
            result.success(uri.toString())
        } catch (error: Exception) {
            result.error("save_failed", error.message, null)
        }
    }
}
