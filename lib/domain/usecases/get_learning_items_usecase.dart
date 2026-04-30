import '../entities/learning_item.dart';
import '../repositories/learning_repository.dart';

enum LearningCategory { alphabet, number, color, animal }

class GetLearningItemsUseCase {
  final LearningRepository repository;

  GetLearningItemsUseCase(this.repository);

  Future<List<LearningItem>> execute(LearningCategory category) async {
    switch (category) {
      case LearningCategory.alphabet:
        return repository.getAlphabets();
      case LearningCategory.number:
        return repository.getNumbers();
      case LearningCategory.color:
        return repository.getColors();
      case LearningCategory.animal:
        return repository.getAnimals();
    }
  }
}
