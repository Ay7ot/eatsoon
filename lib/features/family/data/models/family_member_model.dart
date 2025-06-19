import 'package:cloud_firestore/cloud_firestore.dart';

enum FamilyMemberRole { admin, member }

enum FamilyMemberStatus { active, pending, inactive }

class FamilyMemberModel {
  final String userId;
  final String familyId;
  final String displayName;
  final String email;
  final String? profileImage;
  final FamilyMemberRole role;
  final FamilyMemberStatus status;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final int itemsAddedThisMonth;

  const FamilyMemberModel({
    required this.userId,
    required this.familyId,
    required this.displayName,
    required this.email,
    this.profileImage,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastActiveAt,
    this.itemsAddedThisMonth = 0,
  });

  factory FamilyMemberModel.fromFirestore(Map<String, dynamic> data, String userId, String familyId) {
    return FamilyMemberModel(
      userId: userId,
      familyId: familyId,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profileImage'],
      role: _parseRole(data['role']),
      status: _parseStatus(data['status']),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      itemsAddedThisMonth: data['itemsAddedThisMonth'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'profileImage': profileImage,
      'role': role.name,
      'status': status.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'itemsAddedThisMonth': itemsAddedThisMonth,
    };
  }

  static FamilyMemberRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'admin':
        return FamilyMemberRole.admin;
      case 'member':
        return FamilyMemberRole.member;
      default:
        return FamilyMemberRole.member;
    }
  }

  static FamilyMemberStatus _parseStatus(String? statusString) {
    switch (statusString) {
      case 'active':
        return FamilyMemberStatus.active;
      case 'pending':
        return FamilyMemberStatus.pending;
      case 'inactive':
        return FamilyMemberStatus.inactive;
      default:
        return FamilyMemberStatus.pending;
    }
  }

  FamilyMemberModel copyWith({
    String? userId,
    String? familyId,
    String? displayName,
    String? email,
    String? profileImage,
    FamilyMemberRole? role,
    FamilyMemberStatus? status,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    int? itemsAddedThisMonth,
  }) {
    return FamilyMemberModel(
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      itemsAddedThisMonth: itemsAddedThisMonth ?? this.itemsAddedThisMonth,
    );
  }

  // Helper getters
  bool get isAdmin => role == FamilyMemberRole.admin;
  bool get isActive => status == FamilyMemberStatus.active;
  bool get isPending => status == FamilyMemberStatus.pending;
  bool get isOnline => lastActiveAt != null && 
      DateTime.now().difference(lastActiveAt!).inMinutes < 5;

  String get roleDisplayName {
    switch (role) {
      case FamilyMemberRole.admin:
        return 'Admin';
      case FamilyMemberRole.member:
        return 'Member';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case FamilyMemberStatus.active:
        return 'Active';
      case FamilyMemberStatus.pending:
        return 'Pending';
      case FamilyMemberStatus.inactive:
        return 'Inactive';
    }
  }

  @override
  String toString() {
    return 'FamilyMemberModel(userId: $userId, displayName: $displayName, role: $role, status: $status)';
  }
} 