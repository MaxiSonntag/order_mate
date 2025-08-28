package de.msonntag.ordermate

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.UUID
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val channelName = "com.msonntag.ordermate/files"
    private lateinit var channel: MethodChannel
    private val pending = mutableListOf<String>()

    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Do not do heavy work here
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        channel = MethodChannel(engine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialFiles" -> {
                    val out = pending.toList()
                    pending.clear()
                    result.success(out)
                }
                else -> result.notImplemented()
            }
        }

        // Handle intent that launched the app (cold start)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        Log.d("MainActivity", "handleIntent: action=${intent.action} data=${intent.data} clip=${intent.clipData?.itemCount}")

        when (intent.action) {
            Intent.ACTION_VIEW -> {
                val uris = mutableListOf<Uri>()
                intent.data?.let { uris.add(it) }
                extractClipDataUris(intent)?.let { uris.addAll(it) }
                uris.forEach { processUriAsync(it, intent.flags) }
            }
            Intent.ACTION_SEND -> {
                extractClipDataUris(intent)?.forEach { processUriAsync(it, intent.flags) }
                intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.let { processUriAsync(it, intent.flags) }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                extractClipDataUris(intent)?.forEach { processUriAsync(it, intent.flags) }
                intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.forEach { processUriAsync(it, intent.flags) }
            }
        }
    }

    private fun extractClipDataUris(intent: Intent): List<Uri>? {
        val cd = intent.clipData ?: return null
        val list = ArrayList<Uri>(cd.itemCount)
        for (i in 0 until cd.itemCount) {
            cd.getItemAt(i)?.uri?.let { list.add(it) }
        }
        return list
    }

    private fun processUriAsync(uri: Uri, flags: Int) {
        ioExecutor.execute {
            val local = copyToInbox(uri, flags)
            if (local != null) {
                mainHandler.post { emit(listOf(local)) }
            }
        }
    }

    private fun emit(paths: List<String>) {
        if (this::channel.isInitialized) {
            channel.invokeMethod("onFileOpened", paths)
            Log.d("MainActivity", "Emitted to Dart: $paths")
        } else {
            pending.addAll(paths)
            Log.d("MainActivity", "Queued: $paths")
        }
    }

    /** Copy the incoming Uri into app-internal storage (filesDir/inbox). */
    private fun copyToInbox(uri: Uri, flags: Int): String? {
        return try {
            if ((flags and Intent.FLAG_GRANT_READ_URI_PERMISSION) != 0) {
                try {
                    contentResolver.takePersistableUriPermission(
                        uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                } catch (_: SecurityException) {
                    // Not persistable, ignore
                }
            }

            val displayName = queryDisplayName(uri) ?: (uri.lastPathSegment ?: "file")
            val inboxDir = File(filesDir, "inbox").apply { mkdirs() }
            val dest = File(inboxDir, "${UUID.randomUUID()}_$displayName")

            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(dest).use { output -> input.copyTo(output) }
            } ?: return null

            dest.absolutePath
        } catch (e: Exception) {
            Log.e("MainActivity", "copyToInbox failed for $uri", e)
            null
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        return try {
            contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
        } catch (_: Exception) {
            null
        }
    }
}