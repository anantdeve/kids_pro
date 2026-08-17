import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class AppSettings {
  final bool magicalSoundsEnabled;
  final bool backgroundMusicEnabled;

  AppSettings({
    this.magicalSoundsEnabled = true,
    this.backgroundMusicEnabled = true,
  });

  AppSettings copyWith({
    bool? magicalSoundsEnabled,
    bool? backgroundMusicEnabled,
  }) {
    return AppSettings(
      magicalSoundsEnabled: magicalSoundsEnabled ?? this.magicalSoundsEnabled,
      backgroundMusicEnabled: backgroundMusicEnabled ?? this.backgroundMusicEnabled,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const String _soundsKey = 'magical_sounds_enabled';
  static const String _bgmKey = 'background_music_enabled';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final soundsEnabled = prefs.getBool(_soundsKey) ?? true;
    final bgmEnabled = prefs.getBool(_bgmKey) ?? true;
    
    return AppSettings(
      magicalSoundsEnabled: soundsEnabled,
      backgroundMusicEnabled: bgmEnabled,
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

  Future<void> toggleBackgroundMusic() async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = !currentState.backgroundMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bgmKey, newState);
    
    state = AsyncData(currentState.copyWith(backgroundMusicEnabled: newState));
  }
}
