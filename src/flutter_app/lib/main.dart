import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('[RUNMOTE-ERROR] FlutterError: ${details.exception}');
    debugPrint('[RUNMOTE-ERROR] Stack: ${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[RUNMOTE-ERROR] PlatformDispatcher: $error');
    debugPrint('[RUNMOTE-ERROR] Stack: $stack');
    return true;
  };

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );

  // Load .env after the first frame so it doesn't block startup. The
  // relay URL fallback (production) is used until this completes.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('[RUNMOTE] dotenv load failed: $e');
    }
  });
}
