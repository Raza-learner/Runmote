import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

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
}
