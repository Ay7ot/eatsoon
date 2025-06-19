import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus { pending, accepted, declined, expired }

class FamilyInvitationModel {
  final String id;
  final String familyId;
  final String familyName;
  final String inviterUserId;
  final String inviterName;
  final String inviteeEmail;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  const FamilyInvitationModel({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.inviterUserId,
    required this.inviterName,
    required this.inviteeEmail,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  factory FamilyInvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyInvitationModel(
      id: doc.id,
      familyId: data['familyId'] ?? '',
      familyName: data['familyName'] ?? '',
      inviterUserId: data['inviterUserId'] ?? '',
      inviterName: data['inviterName'] ?? '',
      inviteeEmail: data['inviteeEmail'] ?? '',
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt:
          (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'familyId': familyId,
      'familyName': familyName,
      'inviterUserId': inviterUserId,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  static InvitationStatus _parseStatus(String? statusString) {
    switch (statusString) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      case 'expired':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.pending;
    }
  }

  FamilyInvitationModel copyWith({
    String? id,
    String? familyId,
    String? familyName,
    String? inviterUserId,
    String? inviterName,
    String? inviteeEmail,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
  }) {
    return FamilyInvitationModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      inviterName: inviterName ?? this.inviterName,
      inviteeEmail: inviteeEmail ?? this.inviteeEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  // Helper getters
  bool get isPending => status == InvitationStatus.pending;
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt) || status == InvitationStatus.expired;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isDeclined => status == InvitationStatus.declined;

  String get statusDisplayName {
    switch (status) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'FamilyInvitationModel(id: $id, familyName: $familyName, inviteeEmail: $inviteeEmail, status: $status)';
  }
}
 