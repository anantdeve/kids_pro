import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../core/config/env.dart';

class LearningTtsState {
  final bool isSpeaking;
  final String currentWord;
  final bool isMuted;

  LearningTtsState({
    this.isSpeaking = false,
    this.currentWord = '',
    this.isMuted = false,
  });

  LearningTtsState copyWith({
    bool? isSpeaking,
    String? currentWord,
    bool? isMuted,
  }) {
    return LearningTtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentWord: currentWord ?? this.currentWord,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class LearningTtsNotifier extends Notifier<LearningTtsState> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  final Map<String, String> _audioCache = {};

  @override
  LearningTtsState build() {
    _initTts();
    return LearningTtsState();
  }

  Future<void> _initTts() async {
    // Setup for fallback Flutter TTS
    // Forcing Google TTS engine on Android. OEM engines (like Samsung TTS) often have terrible pronunciation.
    if (Platform.isAndroid) {
      await flutterTts.setEngine("com.google.android.tts");
    }
    
    await flutterTts.setLanguage("en-IN"); // Indian English
    await flutterTts.setSpeechRate(0.4); // Slower rate (0.4) is crucial for making the voice more articulate and clearly audible
    await flutterTts.setVolume(1.0); // Maximum volume
    await flutterTts.setPitch(1.0); // Natural pitch
    await flutterTts.awaitSpeakCompletion(true);
    
    // iOS specific setup to ensure the voice uses the main speaker at high quality and doesn't get muffled by other audio
    if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
      await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
      );
    }

    flutterTts.setStartHandler(() {
      state = state.copyWith(isSpeaking: true);
    });

    flutterTts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false, currentWord: '');
    });

    flutterTts.setCancelHandler(() {
      state = state.copyWith(isSpeaking: false, currentWord: '');
    });

    flutterTts.setErrorHandler((msg) {
      state = state.copyWith(isSpeaking: false, currentWord: '');
    });

    flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      state = state.copyWith(
        currentWord: word.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), ''),
      );
    });

    // Setup for AudioPlayer (ElevenLabs)
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (s == PlayerState.playing) {
        state = state.copyWith(isSpeaking: true);
      } else if (s == PlayerState.completed || s == PlayerState.stopped) {
        state = state.copyWith(isSpeaking: false, currentWord: '');
      }
    });
  }

  Future<void> playInstruction(String text) async {
    await stop(); 
    await Future.delayed(const Duration(milliseconds: 300));
    if (text.isNotEmpty) {
      await _speak(text);
    }
  }

  Future<void> playFeedback(String text) async {
    await stop();
    if (text.isNotEmpty) {
      await _speak(text);
    }
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
    if (state.isMuted) {
      stop();
    }
  }

  Future<void> _speak(String text) async {
    if (state.isMuted) return;

    // Use ElevenLabs if API key is provided
    if (Env.elevenLabsApiKey.isNotEmpty) {
      try {
        await _speakWithElevenLabs(text);
        return;
      } catch (e) {
        print("ElevenLabs Error: $e");
        // Fallback to flutter_tts if ElevenLabs fails
      }
    }
    
    // Fallback to flutter_tts
    await flutterTts.speak(text);
  }

  Future<void> _speakWithElevenLabs(String text) async {
    // Check if we have the file cached in memory map
    if (_audioCache.containsKey(text)) {
      final filePath = _audioCache[text]!;
      await audioPlayer.play(DeviceFileSource(filePath));
      return;
    }

    // Fetch from API
    state = state.copyWith(isSpeaking: true); // Show speaking indicator while fetching
    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/${Env.elevenLabsVoiceId}');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': Env.elevenLabsApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {
          "stability": 0.5,
          "similarity_boost": 0.5
        }
      }),
    );

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final safeFilename = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${dir.path}/$safeFilename.mp3');
      await file.writeAsBytes(response.bodyBytes);
      
      _audioCache[text] = file.path;
      await audioPlayer.play(DeviceFileSource(file.path));
    } else {
      state = state.copyWith(isSpeaking: false);
      throw Exception('Failed to fetch audio: ${response.body}');
    }
  }

  Future<void> stop() async {
    if (state.isSpeaking) {
      await flutterTts.stop();
      await audioPlayer.stop();
      state = state.copyWith(isSpeaking: false, currentWord: '');
    }
  }
}

final learningTtsServiceProvider = NotifierProvider<LearningTtsNotifier, LearningTtsState>(() {
  return LearningTtsNotifier();
});
