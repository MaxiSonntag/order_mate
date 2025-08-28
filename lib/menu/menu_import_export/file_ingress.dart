// lib/file_ingress.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FileIngress {
  static const MethodChannel _ch = MethodChannel('com.msonntag.ordermate/files');
  static final StreamController<List<String>> _stream = StreamController<List<String>>.broadcast();
  static bool _handlerInstalled = false;

  /// Call this once at startup, before runApp().
  static void init() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;

    _ch.setMethodCallHandler((call) async {
      if (call.method == 'onFileOpened') {
        final paths = (call.arguments as List).map((e) => e.toString()).toList();
        _stream.add(paths);
      }
    });
  }

  /// Exponential backoff retry for native readiness.
  /// Tries getInitialFiles until success or retries exhausted.
  static Future<List<String>> getInitialFilesWithRetry({
    int maxAttempts = 6, // ~3.1s total with the default schedule
    List<int> delaysMs = const [100, 200, 400, 800, 1600, 3200],
  }) async {
    assert(delaysMs.length >= maxAttempts, 'delaysMs must have >= maxAttempts entries');

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // IMPORTANT: only call after setMethodCallHandler has been installed
        final res = await _ch.invokeMethod<List<dynamic>>('getInitialFiles');
        return (res ?? const []).cast<String>();
      } on MissingPluginException {
        // Native channel not ready yet — wait and try again
        await Future.delayed(Duration(milliseconds: delaysMs[attempt]));
      }
    }
    return const [];
  }

  static Stream<List<String>> stream() => _stream.stream;

  /// Optional: call this on app resume to catch anything queued while Flutter was suspended.
  static Future<void> refreshOnResumed() async {
    final more = await getInitialFilesWithRetry(maxAttempts: 3, delaysMs: const [100, 200, 400]);
    if (more.isNotEmpty) _stream.add(more);
  }
}