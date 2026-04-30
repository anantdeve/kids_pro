import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/learning_repository_impl.dart';
import '../../domain/repositories/learning_repository.dart';
import '../../domain/usecases/get_learning_items_usecase.dart';

// Data Source Provider
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

// Repository Provider
final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return LearningRepositoryImpl(dataSource);
});

// UseCase Provider
final getLearningItemsUseCaseProvider = Provider<GetLearningItemsUseCase>((ref) {
  final repository = ref.watch(learningRepositoryProvider);
  return GetLearningItemsUseCase(repository);
});
