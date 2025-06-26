import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;

  /// IDs of all families the user belongs to.
  final List<String> familyIds;

  /// ID of the family that is currently active in the UI context.
  final String? currentFamilyId;

  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    List<String>? familyIds,
    this.currentFamilyId,
    this.createdAt,
    this.lastLoginAt,
  }) : familyIds = familyIds ?? const [];

  // Factory constructor to create UserModel from Firebase User
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String name,
    required String email,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoURL: photoURL,
      familyIds: const [],
      currentFamilyId: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      familyIds: List<String>.from(data['familyIds'] ?? const []),
      currentFamilyId: data['currentFamilyId'] ?? data['familyId'],
      createdAt: data['createdAt']?.toDate(),
      lastLoginAt: data['lastLoginAt']?.toDate(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'familyIds': familyIds,
      'currentFamilyId': currentFamilyId,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'lastLoginAt':
          lastLoginAt != null
              ? Timestamp.fromDate(lastLoginAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    List<String>? familyIds,
    String? currentFamilyId,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      familyIds: familyIds ?? this.familyIds,
      currentFamilyId: currentFamilyId ?? this.currentFamilyId,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, photoURL: $photoURL, familyIds: $familyIds, currentFamilyId: $currentFamilyId)';
  }

  // ---------------------------------------------------------------------------
  // BACKWARD-COMPATIBILITY -----------------------------------------------------
  // ---------------------------------------------------------------------------

  /// Deprecated getter exposing the single `familyId` field that existed in the
  /// previous data model.  It now simply proxies `currentFamilyId` so legacy
  /// code can continue to compile while we migrate.
  @Deprecated('Use currentFamilyId instead')
  String? get familyId => currentFamilyId;
}
