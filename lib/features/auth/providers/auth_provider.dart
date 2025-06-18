import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eat_soon/features/auth/data/services/auth_service.dart';
import 'package:eat_soon/features/auth/data/models/user_model.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ActivityService _activityService = ActivityService();

  AuthStatus _status = AuthStatus.loading;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    // Check current auth state immediately
    _initializeAuthState();
    // Listen to auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _initializeAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _onAuthStateChanged(currentUser);
  }

  void _onAuthStateChanged(User? user) {
    debugPrint(
      'Auth state changed: user = ${user?.uid}, email = ${user?.email}',
    );
    if (user != null) {
      _user = UserModel.fromFirebaseUser(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        photoURL: user.photoURL,
      );
      _status = AuthStatus.authenticated;
      debugPrint('Status set to authenticated');

      // Cleanup old activities when user signs in
      _cleanupOldActivities();
    } else {
      _user = null;
      _status = AuthStatus.unauthenticated;
      debugPrint('Status set to unauthenticated');
    }
    notifyListeners();
    debugPrint('Listeners notified, current status: $_status');
  }

  void _cleanupOldActivities() {
    // Run cleanup in background without blocking UI
    Future.delayed(const Duration(seconds: 2), () {
      _activityService.cleanupOldActivities();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      if (userCredential != null) {
        // Send email verification
        await _authService.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      final userCredential = await _authService.signInWithGoogle();
      return userCredential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({required String name}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.updateUserProfile(name: name);

      // Update local user model
      if (_user != null) {
        _user = _user!.copyWith(name: name);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reload user
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
    } catch (e) {
      _setError(e.toString());
    }
  }
}
