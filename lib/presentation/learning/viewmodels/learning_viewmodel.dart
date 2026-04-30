import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../domain/entities/learning_item.dart';
import '../../../../domain/usecases/get_learning_items_usecase.dart';
import '../../../../core/providers.dart';

final learningItemsProvider = FutureProvider.autoDispose.family<List<LearningItem>, LearningCategory>((ref, category) async {
  final useCase = ref.watch(getLearningItemsUseCaseProvider);
  return await useCase.execute(category);
});

final audioPlayerProvider = Provider.autoDispose<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
