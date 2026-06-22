import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_service.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final preferencesServiceProvider = FutureProvider<PreferencesService>(
  (ref) async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return PreferencesService(prefs);
  },
);
