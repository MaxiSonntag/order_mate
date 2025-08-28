// lib/file_ingress.dart
import 'dart:async';
import 'package:flutter/services.dart';

class FileIngress {
  // ---- Public API -----------------------------------------------------------

  static void init({bool fetchInitial = true}) {
    if (_initialized) return;
    _initialized = true;

    _ch.setMethodCallHandler((call) async {
      if (call.method == 'onFileOpened') {
        final paths = (call.arguments as List).map((e) => e.toString()).toList();
        _add(paths);
      }
    });

    if (fetchInitial) {
      _getInitialFilesWithRetry(); // fire & forget
    }
  }

  /// Subscribe whenever you want; you’ll get buffered events first, then live.
  static Stream<List<String>> stream() {
    late StreamController<List<String>> ctrl;
    StreamSubscription<List<String>>? liveSub;

    ctrl = StreamController<List<String>>(
      onListen: () async {
        // 1) Replay buffer
        if (_buffer.isNotEmpty) {
          for (final evt in _buffer) {
            await Future<void>.delayed(Duration.zero);
            if (!ctrl.isClosed) ctrl.add(List<String>.from(evt));
          }
        }
        // 2) Forward live events
        liveSub = _live.stream.listen((evt) {
          if (!ctrl.isClosed) ctrl.add(evt);
        });
      },
      onCancel: () async {
        await liveSub?.cancel();
      },
    );

    return ctrl.stream;
  }

  static Future<List<String>> next() => stream().first;

  // ---- Internals ------------------------------------------------------------

  static const _ch = MethodChannel('com.msonntag.ordermate/files');
  static bool _initialized = false;

  static final List<List<String>> _buffer = <List<String>>[];
  static final StreamController<List<String>> _live =
  StreamController<List<String>>.broadcast();

  static void _add(List<String> paths) {
    if (paths.isEmpty) return;
    _buffer.add(List<String>.from(paths));
    _live.add(paths);
  }

  static Future<void> _getInitialFilesWithRetry({
    int maxAttempts = 6,
    List<int> delaysMs = const [100, 200, 400, 800, 1600, 3200],
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final res = await _ch.invokeMethod<List<dynamic>>('getInitialFiles');
        final initial = (res ?? const []).map((e) => e.toString()).toList();
        if (initial.isNotEmpty) _add(initial);
        return;
      } on MissingPluginException {
        await Future.delayed(Duration(milliseconds: delaysMs[i]));
      }
    }
  }
}