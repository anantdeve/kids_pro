import 'dart:convert';

class UserModel {
  final String name;
  final String? avatarPath;
  final Map<String, int> featurePoints;

  UserModel({
    required this.name,
    this.avatarPath,
    required this.featurePoints,
  });

  int get totalPoints => featurePoints.values.fold(0, (sum, points) => sum + points);

  UserModel copyWith({
    String? name,
    String? avatarPath,
    Map<String, int>? featurePoints,
  }) {
    return UserModel(
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      featurePoints: featurePoints ?? this.featurePoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarPath': avatarPath,
      'featurePoints': featurePoints,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? 'Little Explorer',
      avatarPath: map['avatarPath'],
      featurePoints: Map<String, int>.from(map['featurePoints'] ?? {
        'Learning': 0,
        'Music': 0,
        'Puzzle': 0,
        'Quiz': 0,
        'Games': 0,
      }),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
