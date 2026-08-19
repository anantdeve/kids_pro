import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _globalUiSoundPlayer = AudioPlayer();

extension NavigationUtils on BuildContext {
  void popWithSound([Object? result]) {
    try {
      _globalUiSoundPlayer.play(AssetSource('audio/Sounds/backbutton.mp3'));
    } catch (e) {
      debugPrint('Error playing back button sound: $e');
    }
    
    try {
      pop(result);
    } catch (e) {
      Navigator.pop(this, result);
    }
  }
}
