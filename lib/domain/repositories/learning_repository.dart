import '../entities/learning_item.dart';

abstract class LearningRepository {
  Future<List<LearningItem>> getAlphabets();
  Future<List<LearningItem>> getNumbers();
  Future<List<LearningItem>> getColors();
  Future<List<LearningItem>> getAnimals();
}
