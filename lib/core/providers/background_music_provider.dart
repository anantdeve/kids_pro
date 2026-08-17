import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

final bgmRouteObserver = RouteObserverProxy();

final backgroundMusicProvider = Provider<BackgroundMusicController>((ref) {
  final controller = BackgroundMusicController(ref);
  bgmRouteObserver.addListener(controller._onRouteChanged);
  ref.onDispose(() {
    bgmRouteObserver.removeListener(controller._onRouteChanged);
    controller.dispose();
  });
  return controller;
});

class RouteObserverProxy extends NavigatorObserver {
  final List<Function(String?)> _listeners = [];

  void addListener(Function(String?) listener) => _listeners.add(listener);
  void removeListener(Function(String?) listener) => _listeners.remove(listener);

  void _notify(String? routeName) {
    for (final listener in _listeners) {
      listener(routeName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notify(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _notify(newRoute?.settings.name);
  }
}

class BackgroundMusicController {
  final Ref _ref;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Using the provided local asset for background music
  final String _bgmPath = 'audio/Sounds/background_music.mp3';
  
  bool _isMainScreen = false;

  BackgroundMusicController(this._ref) {
    _init();
  }

  Future<void> _init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Listen to changes in settings
    _ref.listen<AsyncValue<AppSettings>>(settingsProvider, (previous, next) {
      _updatePlaybackState();
    });
  }

  void _onRouteChanged(String? routeName) {
    if (routeName == null) return;
    // Play music on main screen and the main feature hub screens
    final allowedRoutes = ['/home', '/learning-hub', '/quiz-selection', '/fun-games', '/magic-paint'];
    _isMainScreen = allowedRoutes.contains(routeName);
    _updatePlaybackState();
  }

  Future<void> _updatePlaybackState() async {
    final settingsState = _ref.read(settingsProvider);
    final isEnabled = settingsState.value?.backgroundMusicEnabled ?? true;
    
    if (isEnabled && _isMainScreen) {
      _play();
    } else {
      _pause();
    }
  }

  Future<void> _play() async {
    if (_audioPlayer.state != PlayerState.playing) {
      await _audioPlayer.play(AssetSource(_bgmPath));
    }
  }

  Future<void> _pause() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
