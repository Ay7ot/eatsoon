import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyModel {
  final String id;
  final String name;
  final String adminUserId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final FamilySettings settings;
  final FamilyStatistics statistics;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.adminUserId,
    required this.createdAt,
    this.updatedAt,
    required this.settings,
    required this.statistics,
  });

  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyModel(
      id: doc.id,
      name: data['name'] ?? '',
      adminUserId: data['adminUserId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      settings: FamilySettings.fromMap(data['settings'] ?? {}),
      statistics: FamilyStatistics.fromMap(data['statistics'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'adminUserId': adminUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null
              ? Timestamp.fromDate(updatedAt!)
              : FieldValue.serverTimestamp(),
      'settings': settings.toMap(),
      'statistics': statistics.toMap(),
    };
  }

  FamilyModel copyWith({
    String? id,
    String? name,
    String? adminUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    FamilySettings? settings,
    FamilyStatistics? statistics,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      adminUserId: adminUserId ?? this.adminUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      statistics: statistics ?? this.statistics,
    );
  }
}

class FamilySettings {
  final bool allowMemberInvites;
  final bool requireApprovalForDeletion;

  const FamilySettings({
    this.allowMemberInvites = true,
    this.requireApprovalForDeletion = false,
  });

  factory FamilySettings.fromMap(Map<String, dynamic> map) {
    return FamilySettings(
      allowMemberInvites: map['allowMemberInvites'] ?? true,
      requireApprovalForDeletion: map['requireApprovalForDeletion'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowMemberInvites': allowMemberInvites,
      'requireApprovalForDeletion': requireApprovalForDeletion,
    };
  }
}

class FamilyStatistics {
  final int totalItems;
  final int wasteReduced;
  final int memberCount;

  const FamilyStatistics({
    this.totalItems = 0,
    this.wasteReduced = 0,
    this.memberCount = 1,
  });

  factory FamilyStatistics.fromMap(Map<String, dynamic> map) {
    return FamilyStatistics(
      totalItems: map['totalItems'] ?? 0,
      wasteReduced: map['wasteReduced'] ?? 0,
      memberCount: map['memberCount'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalItems': totalItems,
      'wasteReduced': wasteReduced,
      'memberCount': memberCount,
    };
  }

  FamilyStatistics copyWith({
    int? totalItems,
    int? wasteReduced,
    int? memberCount,
  }) {
    return FamilyStatistics(
      totalItems: totalItems ?? this.totalItems,
      wasteReduced: wasteReduced ?? this.wasteReduced,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}
