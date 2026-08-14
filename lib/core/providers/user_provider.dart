import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../data/models/user_model.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel>(() {
  return UserNotifier();
});

class UserNotifier extends AsyncNotifier<UserModel> {
  static const String _storageKey = 'user_data';
  static const String _migrationKey = 'firestore_migration_completed';

  @override
  Future<UserModel> build() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataJson = prefs.getString(_storageKey);
    final bool migrationCompleted = prefs.getBool(_migrationKey) ?? false;
    
    UserModel? localUser;
    if (userDataJson != null) {
      try {
        localUser = UserModel.fromJson(userDataJson);
      } catch (e) {
        print('Error parsing local user data: $e');
      }
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          // Firestore document exists, use it as source of truth
          final data = doc.data()!;
          final firestoreUser = UserModel.fromMap(data);
          
          // Update local cache
          await prefs.setString(_storageKey, firestoreUser.toJson());
          return firestoreUser;
        } else {
          // Document does not exist. Migrate or create default.
          if (localUser != null && !migrationCompleted) {
            // Valid local data exists and hasn't been migrated, upload it
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set(localUser.toMap());
            await prefs.setBool(_migrationKey, true);
            return localUser;
          } else {
            // No local data, create default
            final defaultUser = _createDefaultUser();
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set(defaultUser.toMap());
            await prefs.setString(_storageKey, defaultUser.toJson());
            return defaultUser;
          }
        }
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('SEVERE ERROR: Firestore permission denied. Check your security rules.');
        } else if (e.code == 'unavailable') {
          // Network offline, handled silently
        } else {
          print('Firestore error fetching user: $e');
        }
        // Fallback to local
        return localUser ?? _createDefaultUser();
      } catch (e) {
        print('Unexpected error fetching user: $e');
        return localUser ?? _createDefaultUser();
      }
    }

    // Not logged in
    return localUser ?? _createDefaultUser();
  }

  UserModel _createDefaultUser() {
    return UserModel(
      name: 'Little Explorer',
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
    final currentUserState = state.value;
    if (currentUserState == null) return;

    final updatedPoints = Map<String, int>.from(currentUserState.featurePoints);
    updatedPoints[feature] = (updatedPoints[feature] ?? 0) + points;

    final updatedUser = currentUserState.copyWith(featurePoints: updatedPoints);
    
    // 1. Immediate local update
    state = AsyncData(updatedUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, updatedUser.toJson());

    // 2. Atomic Firestore update
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(authUser.uid).set({
          'featurePoints': {
            feature: FieldValue.increment(points)
          }
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error syncing points to Firestore: $e');
      }
    }
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

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(authUser.uid).set(user.toMap(), SetOptions(merge: true));
      } catch (e) {
         print('Error syncing user to Firestore: $e');
      }
    }
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
    await prefs.remove(_migrationKey);
    
    final defaultUser = _createDefaultUser();
    
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(authUser.uid).set(defaultUser.toMap());
      } catch (e) {
         print('Error resetting user on Firestore: $e');
      }
    }
    
    state = AsyncData(defaultUser);
  }
}
