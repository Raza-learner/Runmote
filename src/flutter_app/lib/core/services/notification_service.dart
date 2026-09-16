import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../router/app_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onTap,
      );
      const channel = AndroidNotificationChannel(
        'agent_completion',
        'Agent completion',
        description: 'Notifies when an agent finishes a response',
        importance: Importance.high,
      );
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      // Request POST_NOTIFICATIONS on Android 13+; no-op on older versions.
      try {
        final status = await Permission.notification.status;
        if (status.isDenied) {
          await Permission.notification.request();
        }
      } catch (_) {}
      _initialized = true;
    } catch (e) {
      debugPrint('[notif] init failed: $e');
    }
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      // Payload is sessionId or JSON {sessionId, cwd}
      String sessionId = payload;
      String cwd = '';
      if (payload.startsWith('{')) {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        sessionId = map['sessionId'] as String? ?? payload;
        cwd = map['cwd'] as String? ?? '';
      }
      final loc = cwd.isNotEmpty
          ? '/chat/$sessionId?cwd=${Uri.encodeComponent(cwd)}'
          : '/chat/$sessionId';
      goRouter.go(loc);
    } catch (e) {
      debugPrint('[notif] tap handling failed: $e');
    }
  }

  Future<void> showAgentDone({
    required String sessionId,
    required String title,
    String? body,
    String cwd = '',
  }) async {
    await init();
    try {
      final payload = cwd.isNotEmpty
          ? jsonEncode({'sessionId': sessionId, 'cwd': cwd})
          : sessionId;
      await _plugin.show(
        sessionId.hashCode,
        title,
        body ?? 'Tap to open',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'agent_completion',
            'Agent completion',
            channelDescription: 'Notifies when an agent finishes a response',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('[notif] show failed: $e');
    }
  }
}
