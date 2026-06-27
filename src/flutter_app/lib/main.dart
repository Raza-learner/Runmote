import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('[ACP-ERROR] FlutterError: ${details.exception}');
    debugPrint('[ACP-ERROR] Stack: ${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[ACP-ERROR] PlatformDispatcher: $error');
    debugPrint('[ACP-ERROR] Stack: $stack');
    return true;
  };

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
