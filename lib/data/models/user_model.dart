import 'dart:convert';

class UserModel {
  final String name;
  final String? avatarPath;
  final Map<String, int> featurePoints;
  final List<String> savedArtworks;

  UserModel({
    required this.name,
    this.avatarPath,
    required this.featurePoints,
    this.savedArtworks = const [],
  });

  int get totalPoints => featurePoints.values.fold(0, (sum, points) => sum + points);

  UserModel copyWith({
    String? name,
    String? avatarPath,
    Map<String, int>? featurePoints,
    List<String>? savedArtworks,
  }) {
    return UserModel(
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      featurePoints: featurePoints ?? this.featurePoints,
      savedArtworks: savedArtworks ?? this.savedArtworks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarPath': avatarPath,
      'featurePoints': featurePoints,
      'savedArtworks': savedArtworks,
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
      savedArtworks: map['savedArtworks'] != null 
          ? List<String>.from(map['savedArtworks']) 
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
