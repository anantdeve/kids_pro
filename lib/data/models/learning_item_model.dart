import '../../domain/entities/learning_item.dart';

class LearningItemModel extends LearningItem {
  const LearningItemModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.audioUrl,
    super.subtitle,
  });

  factory LearningItemModel.fromJson(Map<String, dynamic> json) {
    return LearningItemModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'subtitle': subtitle,
    };
  }
}
