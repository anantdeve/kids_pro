import '../models/learning_item_model.dart';

class LocalDataSource {
  // Simulating local data source (could be read from JSON assets)
  Future<List<LearningItemModel>> getAlphabets() async {
    // Delay to simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const LearningItemModel(id: 'a', title: 'A', subtitle: 'Apple', imageUrl: 'assets/images/apple.png', audioUrl: 'assets/sounds/a_for_apple.mp3'),
      const LearningItemModel(id: 'b', title: 'B', subtitle: 'Ball', imageUrl: 'assets/images/ball.png', audioUrl: 'assets/sounds/b_for_ball.mp3'),
      const LearningItemModel(id: 'c', title: 'C', subtitle: 'Cat', imageUrl: 'assets/images/cat.png', audioUrl: 'assets/sounds/c_for_cat.mp3'),
    ];
  }

  Future<List<LearningItemModel>> getNumbers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const LearningItemModel(id: '1', title: '1', subtitle: 'One', imageUrl: 'assets/images/1.png', audioUrl: 'assets/sounds/one.mp3'),
      const LearningItemModel(id: '2', title: '2', subtitle: 'Two', imageUrl: 'assets/images/2.png', audioUrl: 'assets/sounds/two.mp3'),
    ];
  }

  Future<List<LearningItemModel>> getColors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const LearningItemModel(id: 'red', title: 'Red', imageUrl: 'assets/images/red.png', audioUrl: 'assets/sounds/red.mp3'),
      const LearningItemModel(id: 'blue', title: 'Blue', imageUrl: 'assets/images/blue.png', audioUrl: 'assets/sounds/blue.mp3'),
    ];
  }

  Future<List<LearningItemModel>> getAnimals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const LearningItemModel(id: 'dog', title: 'Dog', imageUrl: 'assets/images/dog.png', audioUrl: 'assets/sounds/dog.mp3'),
      const LearningItemModel(id: 'cat', title: 'Cat', imageUrl: 'assets/images/cat.png', audioUrl: 'assets/sounds/cat.mp3'),
    ];
  }
}
