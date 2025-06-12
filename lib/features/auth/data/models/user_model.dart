import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
  });

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
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, photoURL: $photoURL)';
  }
}
