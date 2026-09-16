import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sessionId currently opened in ChatScreen, or null if the user is on
/// the Sessions list / elsewhere. Used to suppress "agent finished"
/// notifications when the user is already looking at that chat.
final currentChatSessionProvider = StateProvider<String?>((ref) => null);
