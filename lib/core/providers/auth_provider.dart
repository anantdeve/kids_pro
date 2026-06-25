import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _authRepository;

  @override
  FutureOr<void> build() {
    _authRepository = ref.read(authRepositoryProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> signUp(String email, String password, {String? displayName}) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password, displayName: displayName);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      if (userCredential != null) {
        state = const AsyncData(null);
        return true;
      } else {
        // User cancelled login
        state = const AsyncData(null);
        return false;
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _authRepository.signOut();
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
