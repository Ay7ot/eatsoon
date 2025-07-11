import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_soon/features/auth/data/services/auth_service.dart';
import 'package:eat_soon/features/auth/data/models/user_model.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:eat_soon/features/notifications/services/notification_service.dart';

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
  String? get currentFamilyId => _user?.currentFamilyId;
  List<String> get familyIds => _user?.familyIds ?? const [];

  AuthProvider() {
    // Listen to auth state changes, which will also handle the initial state.
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    debugPrint(
      'Auth state changed: user = ${user?.uid}, email = ${user?.email}',
    );
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      _user = UserModel(
        uid: user.uid,
        name: user.displayName ?? userData?['name'] ?? 'User',
        email: user.email ?? '',
        photoURL: user.photoURL ?? userData?['photoURL'],
        bio: userData?['bio'],
        familyIds: List<String>.from(userData?['familyIds'] ?? const []),
        currentFamilyId: userData?['currentFamilyId'] ?? userData?['familyId'],
        createdAt: (userData?['createdAt'] as Timestamp?)?.toDate(),
        lastLoginAt: (userData?['lastLoginAt'] as Timestamp?)?.toDate(),
      );
      _status = AuthStatus.authenticated;
      debugPrint('Status set to authenticated');

      // Cleanup old activities when user signs in
      _cleanupOldActivities();

      // Schedule expiration notifications on app start after authentication
      NotificationService().scheduleInventoryNotifications();
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
  Future<bool> updateProfile({required String name, String? bio}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.updateUserProfile(name: name, bio: bio);

      // Update local user model
      if (_user != null) {
        _user = _user!.copyWith(name: name, bio: bio);
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
      // After reload, trigger auth state update again
      final currentUser = FirebaseAuth.instance.currentUser;
      await _onAuthStateChanged(currentUser);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // FAMILY CONTEXT MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Switch the active family for this user. Ensures Firestore is updated and
  /// local state is refreshed.
  Future<void> switchFamily(String newFamilyId) async {
    if (_user == null || _user!.currentFamilyId == newFamilyId) return;

    try {
      _setLoading(true);
      final uid = _user!.uid;

      // Use set with merge to ensure the doc is created if it's missing.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'currentFamilyId': newFamilyId,
      }, SetOptions(merge: true));

      // Optimistically update the local state to avoid the race condition.
      _user = _user!.copyWith(currentFamilyId: newFamilyId);
    } catch (e) {
      _setError('Failed to switch family: $e');
    } finally {
      // Notify listeners regardless of success or failure to update the UI.
      _setLoading(false);
    }
  }
}
