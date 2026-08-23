import 'package:flutter_riverpod/flutter_riverpod.dart';

final demoModeProvider = StateProvider<bool>((ref) => false);

const demoSessionIds = ['demo-1', 'demo-2'];
