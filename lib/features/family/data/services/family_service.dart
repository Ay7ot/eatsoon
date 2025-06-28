import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_soon/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:eat_soon/features/family/data/models/family_model.dart';
import 'package:eat_soon/features/family/data/models/family_member_model.dart';
import 'package:eat_soon/features/family/data/models/family_invitation_model.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final FirebaseFirestore _firestore = FirestoreService.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new family
  Future<String> createFamily(String familyName) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final user = _auth.currentUser!;
      final now = DateTime.now();

      // Create family document
      final familyData = FamilyModel(
        id: '', // Will be set by Firestore
        name: familyName.trim(),
        adminUserId: _currentUserId!,
        createdAt: now,
        settings: const FamilySettings(),
        statistics: const FamilyStatistics(memberCount: 1),
      );

      final familyDoc = await _firestore
          .collection('families')
          .add(familyData.toFirestore());
      final familyId = familyDoc.id;

      // Add creator as admin member
      await _addMemberToFamily(
        familyId: familyId,
        userId: _currentUserId!,
        displayName: user.displayName ?? 'User',
        email: user.email ?? '',
        profileImage: user.photoURL,
        role: FamilyMemberRole.admin,
        status: FamilyMemberStatus.active,
      );

      // Update user's family association
      await _updateUserFamilyAssociation(
        _currentUserId!,
        familyId,
        setAsCurrent: true,
      );

      debugPrint('Family created successfully with ID: $familyId');
      return familyId;
    } catch (e) {
      debugPrint('Error creating family: $e');
      throw 'Failed to create family: $e';
    }
  }

  // Get family by ID
  Future<FamilyModel?> getFamily(String familyId) async {
    try {
      final doc = await _firestore.collection('families').doc(familyId).get();
      if (doc.exists) {
        return FamilyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting family: $e');
      throw 'Failed to get family: $e';
    }
  }

  // Get family stream
  Stream<FamilyModel?> getFamilyStream(String familyId) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .snapshots()
        .map((doc) => doc.exists ? FamilyModel.fromFirestore(doc) : null);
  }

  // Get family members
  Future<List<FamilyMemberModel>> getFamilyMembers(String familyId) async {
    try {
      final doc =
          await _firestore.collection('familyMembers').doc(familyId).get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final members = data['members'] as Map<String, dynamic>? ?? {};

      return members.entries
          .map(
            (entry) => FamilyMemberModel.fromFirestore(
              entry.value as Map<String, dynamic>,
              entry.key,
              familyId,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting family members: $e');
      throw 'Failed to get family members: $e';
    }
  }

  // Get family members stream
  Stream<List<FamilyMemberModel>> getFamilyMembersStream(String familyId) {
    if (familyId.isEmpty) return const Stream.empty();
    return _firestore.collection('familyMembers').doc(familyId).snapshots().map(
      (doc) {
        if (!doc.exists) return <FamilyMemberModel>[];

        final data = doc.data() as Map<String, dynamic>;
        final members = data['members'] as Map<String, dynamic>? ?? {};

        return members.entries
            .map(
              (entry) => FamilyMemberModel.fromFirestore(
                entry.value as Map<String, dynamic>,
                entry.key,
                familyId,
              ),
            )
            .toList();
      },
    );
  }

  // Invite member to family
  Future<String> inviteMember({
    required String familyId,
    required String email,
  }) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      // Check if user is admin of the family
      final members = await getFamilyMembers(familyId);
      final currentUserMember = members.firstWhere(
        (member) => member.userId == _currentUserId,
        orElse: () => throw 'You are not a member of this family.',
      );

      if (!currentUserMember.isAdmin) {
        throw 'Only admins can invite new members.';
      }

      // Check if email is already a member
      final existingMember = members.where(
        (member) => member.email.toLowerCase() == email.toLowerCase(),
      );
      if (existingMember.isNotEmpty) {
        throw 'This email is already a member of the family.';
      }

      // Get family info
      final family = await getFamily(familyId);
      if (family == null) {
        throw 'Family not found.';
      }

      final user = _auth.currentUser!;
      final now = DateTime.now();

      // Create invitation
      final invitation = FamilyInvitationModel(
        id: '', // Will be set by Firestore
        familyId: familyId,
        familyName: family.name,
        inviterUserId: _currentUserId!,
        inviterName: user.displayName ?? 'User',
        inviteeEmail: email.toLowerCase().trim(),
        status: InvitationStatus.pending,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );

      final invitationDoc = await _firestore
          .collection('familyInvitations')
          .add(invitation.toFirestore());

      debugPrint('Invitation sent successfully with ID: ${invitationDoc.id}');
      return invitationDoc.id;
    } catch (e) {
      debugPrint('Error inviting member: $e');
      throw 'Failed to invite member: $e';
    }
  }

  // Accept family invitation
  Future<void> acceptInvitation(String invitationId) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      final user = _auth.currentUser!;

      // Get invitation details
      final invitationDoc =
          await _firestore
              .collection('familyInvitations')
              .doc(invitationId)
              .get();

      if (!invitationDoc.exists) {
        throw 'Invitation not found or has expired.';
      }

      final invitation = FamilyInvitationModel.fromFirestore(invitationDoc);

      // Verify invitation is for current user
      if (invitation.inviteeEmail.toLowerCase() != user.email?.toLowerCase()) {
        throw 'This invitation is not for your email address.';
      }

      if (invitation.status != InvitationStatus.pending) {
        throw 'This invitation has already been ${invitation.status.name}.';
      }

      // Check if invitation has expired
      if (invitation.expiresAt.isBefore(DateTime.now())) {
        throw 'This invitation has expired.';
      }

      // Add user to family members
      await _addMemberToFamily(
        familyId: invitation.familyId,
        userId: _currentUserId!,
        displayName: user.displayName ?? 'User',
        email: user.email ?? '',
        profileImage: user.photoURL,
        role: FamilyMemberRole.member,
        status: FamilyMemberStatus.active,
      );

      // Update invitation status
      await _firestore
          .collection('familyInvitations')
          .doc(invitationId)
          .update({
            'status': InvitationStatus.accepted.name,
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      // Update user's family association
      await _updateUserFamilyAssociation(
        _currentUserId!,
        invitation.familyId,
        setAsCurrent: true,
      );

      // Note: memberCount is adjusted server-side when admin manages members.

      debugPrint('Invitation accepted successfully');
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      throw 'Failed to accept invitation: $e';
    }
  }

  // Remove a member from a family
  Future<void> removeMember({
    required String familyId,
    required String userId,
  }) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      // 1. Check if current user is an admin
      final members = await getFamilyMembers(familyId);
      final currentUserMember = members.firstWhere(
        (member) => member.userId == _currentUserId,
        orElse: () => throw 'You are not a member of this family.',
      );

      if (!currentUserMember.isAdmin) {
        throw 'Only admins can remove members.';
      }
      if (currentUserMember.userId == userId) {
        throw 'Admins cannot remove themselves.';
      }

      final batch = _firestore.batch();

      // 2. Remove member from the familyMembers document
      final familyMembersRef = _firestore
          .collection('familyMembers')
          .doc(familyId);
      batch.update(familyMembersRef, {'members.$userId': FieldValue.delete()});

      // 3. Decrement member count in the family document
      final familyRef = _firestore.collection('families').doc(familyId);
      batch.update(familyRef, {
        'statistics.memberCount': FieldValue.increment(-1),
      });

      // 4. Update the removed user's document
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'familyIds': FieldValue.arrayRemove([familyId]),
        'currentFamilyId': null, // Reset their current family
      });

      await batch.commit();
      debugPrint('Member $userId removed successfully from family $familyId.');
    } catch (e) {
      debugPrint('Error removing member: $e');
      throw 'Failed to remove member: $e';
    }
  }

  // Update member role
  Future<void> updateMemberRole({
    required String familyId,
    required String userId,
    required FamilyMemberRole newRole,
  }) async {
    try {
      if (_currentUserId == null) {
        throw 'No user is currently signed in.';
      }

      // Check if current user is admin
      final members = await getFamilyMembers(familyId);
      final currentUserMember = members.firstWhere(
        (member) => member.userId == _currentUserId,
        orElse: () => throw 'You are not a member of this family.',
      );

      if (!currentUserMember.isAdmin) {
        throw 'Only admins can change member roles.';
      }

      // Update member role
      await _firestore.collection('familyMembers').doc(familyId).update({
        'members.$userId.role': newRole.name,
      });

      debugPrint('Member role updated successfully');
    } catch (e) {
      debugPrint('Error updating member role: $e');
      throw 'Failed to update member role: $e';
    }
  }

  // Helper methods
  Future<void> _addMemberToFamily({
    required String familyId,
    required String userId,
    required String displayName,
    required String email,
    String? profileImage,
    required FamilyMemberRole role,
    required FamilyMemberStatus status,
  }) async {
    final member = FamilyMemberModel(
      userId: userId,
      familyId: familyId,
      displayName: displayName,
      email: email,
      profileImage: profileImage,
      role: role,
      status: status,
      joinedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    await _firestore.collection('familyMembers').doc(familyId).set({
      'members': {userId: member.toFirestore()},
    }, SetOptions(merge: true));
  }

  Future<void> _updateUserFamilyAssociation(
    String userId,
    String familyId, {
    bool setAsCurrent = false,
  }) async {
    final userDoc = _firestore.collection('users').doc(userId);

    if (setAsCurrent) {
      await userDoc.update({
        'currentFamilyId': familyId,
        'familyIds': FieldValue.arrayUnion([familyId]),
      });
    } else {
      await userDoc.update({
        'familyIds': FieldValue.arrayUnion([familyId]),
      });
    }
  }

  Future<void> _updateFamilyMemberCount(String familyId) async {
    final members = await getFamilyMembers(familyId);
    await _firestore.collection('families').doc(familyId).update({
      'statistics.memberCount': members.length,
    });
  }

  Stream<List<FamilyInvitationModel>> getPendingInvitationsStream(
    String familyId,
  ) {
    return _firestore
        .collection('familyInvitations')
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FamilyInvitationModel.fromFirestore(doc))
              .toList();
        });
  }
}
