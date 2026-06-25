import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class AppSettings {
  final bool magicalSoundsEnabled;

  AppSettings({
    this.magicalSoundsEnabled = true,
  });

  AppSettings copyWith({
    bool? magicalSoundsEnabled,
  }) {
    return AppSettings(
      magicalSoundsEnabled: magicalSoundsEnabled ?? this.magicalSoundsEnabled,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const String _soundsKey = 'magical_sounds_enabled';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final soundsEnabled = prefs.getBool(_soundsKey) ?? true;
    
    return AppSettings(
      magicalSoundsEnabled: soundsEnabled,
    );
  }

  Future<void> toggleMagicalSounds() async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = !currentState.magicalSoundsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundsKey, newState);
    
    state = AsyncData(currentState.copyWith(magicalSoundsEnabled: newState));
  }
}
