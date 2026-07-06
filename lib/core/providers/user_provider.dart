import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel>(() {
  return UserNotifier();
});

class UserNotifier extends AsyncNotifier<UserModel> {
  static const String _storageKey = 'user_data';

  @override
  Future<UserModel> build() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataJson = prefs.getString(_storageKey);

    if (userDataJson != null) {
      return UserModel.fromJson(userDataJson);
    }

    // Default user data
    return UserModel(
      name: 'Nothing',
      featurePoints: {
        'Learning': 0,
        'Music': 0,
        'Puzzle': 0,
        'Quiz': 0,
        'Games': 0,
      },
    );
  }

  Future<void> updateName(String name) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(name: name);
    await _saveUser(updatedUser);
  }

  Future<void> updateAvatar(String? path) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(avatarPath: path);
    await _saveUser(updatedUser);
  }

  Future<void> addPoints(String feature, int points) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedPoints = Map<String, int>.from(currentUser.featurePoints);
    updatedPoints[feature] = (updatedPoints[feature] ?? 0) + points;

    final updatedUser = currentUser.copyWith(featurePoints: updatedPoints);
    await _saveUser(updatedUser);
  }

  Future<void> addArtwork(String path) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedArtworks = List<String>.from(currentUser.savedArtworks)..add(path);
    final updatedUser = currentUser.copyWith(savedArtworks: updatedArtworks);
    await _saveUser(updatedUser);
  }

  Future<void> _saveUser(UserModel user) async {
    state = AsyncData(user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, user.toJson());
  }

  Future<void> clearAvatar() async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(avatarPath: null);
    await _saveUser(updatedUser);
  }

  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = AsyncData(UserModel(
      name: 'Little Explorer',
      featurePoints: {
        'Learning': 0,
        'Music': 0,
        'Puzzle': 0,
        'Quiz': 0,
        'Games': 0,
      },
    ));
  }
}
