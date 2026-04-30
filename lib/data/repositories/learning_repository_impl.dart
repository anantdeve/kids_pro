import '../../domain/entities/learning_item.dart';
import '../../domain/repositories/learning_repository.dart';
import '../datasources/local_data_source.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LocalDataSource localDataSource;

  LearningRepositoryImpl(this.localDataSource);

  @override
  Future<List<LearningItem>> getAlphabets() async {
    return await localDataSource.getAlphabets();
  }

  @override
  Future<List<LearningItem>> getNumbers() async {
    return await localDataSource.getNumbers();
  }

  @override
  Future<List<LearningItem>> getColors() async {
    return await localDataSource.getColors();
  }

  @override
  Future<List<LearningItem>> getAnimals() async {
    return await localDataSource.getAnimals();
  }
}
