import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';

class ListenAndChooseState {
  final String correctWord;
  final List<Map<String, String>> options;
  final bool isSuccess;
  final bool isFailure;
  final Map<String, bool> attemptedOptions;

  const ListenAndChooseState({
    required this.correctWord,
    required this.options,
    this.isSuccess = false,
    this.isFailure = false,
    this.attemptedOptions = const {},
  });

  ListenAndChooseState copyWith({
    String? correctWord,
    List<Map<String, String>>? options,
    bool? isSuccess,
    bool? isFailure,
    Map<String, bool>? attemptedOptions,
  }) {
    return ListenAndChooseState(
      correctWord: correctWord ?? this.correctWord,
      options: options ?? this.options,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      attemptedOptions: attemptedOptions ?? this.attemptedOptions,
    );
  }
}

class ListenAndChooseNotifier extends Notifier<ListenAndChooseState> {
  static const List<Map<String, String>> _wordsAndPictures = [
    {'word': 'APPLE', 'picture': '🍎'},
    {'word': 'BANANA', 'picture': '🍌'},
    {'word': 'CAT', 'picture': '🐱'},
    {'word': 'DOG', 'picture': '🐶'},
    {'word': 'ELEPHANT', 'picture': '🐘'},
    {'word': 'FROG', 'picture': '🐸'},
    {'word': 'GRAPES', 'picture': '🍇'},
    {'word': 'HOUSE', 'picture': '🏠'},
    {'word': 'SUN', 'picture': '☀️'},
    {'word': 'CAR', 'picture': '🚗'},
    {'word': 'BIRD', 'picture': '🐦'},
    {'word': 'TREE', 'picture': '🌳'},
    {'word': 'FISH', 'picture': '🐟'},
  ];

  @override
  ListenAndChooseState build() {
    return const ListenAndChooseState(
      correctWord: '',
      options: [],
    );
  }

  void generateLevel() {
    final random = Random();
    
    // Pick correct word object
    final correctItem = _wordsAndPictures[random.nextInt(_wordsAndPictures.length)];
    final correctWord = correctItem['word']!;

    // Pick 3 wrong words
    final otherItems = _wordsAndPictures.where((item) => item['word'] != correctWord).toList();
    otherItems.shuffle(random);
    final incorrectOptions = otherItems.take(3).toList();

    final options = [...incorrectOptions, correctItem];
    options.shuffle(random);

    state = state.copyWith(
      correctWord: correctWord,
      options: options,
      isSuccess: false,
      isFailure: false,
      attemptedOptions: {},
    );

    _playAudio();
  }

  void _playAudio() {
    if (state.correctWord.isNotEmpty) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction('${state.correctWord.toLowerCase()}.');
    }
  }
  
  void playAudioAgain() {
     _playAudio();
  }

  void onOptionSelected(String selectedWord) {
    if (state.isSuccess || state.isFailure) return;

    final newAttemptedOptions = Map<String, bool>.from(state.attemptedOptions);

    if (selectedWord == state.correctWord) {
      newAttemptedOptions[selectedWord] = true;
      state = state.copyWith(
        isSuccess: true,
        attemptedOptions: newAttemptedOptions,
      );
      ref.read(userProvider.notifier).addPoints('Learning', 20);
    } else {
      newAttemptedOptions[selectedWord] = false;
      state = state.copyWith(
        isFailure: true,
        attemptedOptions: newAttemptedOptions,
      );
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Try again');
    }
  }

  void resetFailure() {
    state = state.copyWith(isFailure: false);
  }
}

final listenAndChooseProvider = NotifierProvider<ListenAndChooseNotifier, ListenAndChooseState>(() {
  return ListenAndChooseNotifier();
});
