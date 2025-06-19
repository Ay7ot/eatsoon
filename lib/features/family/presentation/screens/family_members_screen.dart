import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/family/data/services/family_service.dart';
import 'package:eat_soon/features/family/data/models/family_model.dart';
import 'package:eat_soon/features/family/data/models/family_member_model.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:eat_soon/features/home/models/activity_model.dart';

class FamilyMembersScreen extends StatefulWidget {
  final String familyId;

  const FamilyMembersScreen({
    super.key,
    required this.familyId,
  });

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final FamilyService _familyService = FamilyService();
  final ActivityService _activityService = ActivityService();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Family'),
      body: StreamBuilder<FamilyModel?>(
        stream: _familyService.getFamilyStream(widget.familyId),
        builder: (context, familySnapshot) {
          if (familySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          if (familySnapshot.hasError || !familySnapshot.hasData) {
            return _buildErrorState();
          }

          final family = familySnapshot.data!;

          return StreamBuilder<List<FamilyMemberModel>>(
            stream: _familyService.getFamilyMembersStream(widget.familyId),
            builder: (context, membersSnapshot) {
              if (membersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                );
              }

              final members = membersSnapshot.data ?? [];
              final currentUser = context.read<AuthProvider>().user;
              final currentMember = members.firstWhere(
                (member) => member.userId == currentUser?.uid,
                orElse: () => FamilyMemberModel(
                  userId: '',
                  familyId: '',
                  displayName: '',
                  email: '',
                  role: FamilyMemberRole.member,
                  status: FamilyMemberStatus.active,
                  joinedAt: DateTime.now(),
                ),
              );

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Family Header
                    _buildFamilyHeader(family, members),

                    // Family Members Section
                    _buildFamilyMembersSection(members, currentMember),

                    // Recent Family Activity
                    _buildRecentActivitySection(),

                    const SizedBox(height: 96), // Bottom padding for navigation
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          const Text(
            'Error loading family data',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyHeader(FamilyModel family, List<FamilyMemberModel> members) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Family Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.family_restroom,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Family Name
          Text(
            family.name,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF111827),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // Managing since
          Text(
            'Managing pantry together since ${_formatDate(family.createdAt)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Row
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  '${members.length}',
                  'Members',
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '${family.statistics.totalItems}',
                  'Items\nAdded',
                  const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '${family.statistics.wasteReduced}%',
                  'Waste\nReduced',
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: color,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF6B7280),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyMembersSection(List<FamilyMemberModel> members, FamilyMemberModel currentMember) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Family Members',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF111827),
                  height: 1.3,
                ),
              ),
              if (currentMember.isAdmin)
                TextButton(
                  onPressed: () => _showInviteMemberDialog(),
                  child: const Text(
                    'Add Member',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF10B981),
                      height: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Members List
          ...members.map((member) => _buildMemberItem(member, currentMember)).toList(),
        ],
      ),
    );
  }

  Widget _buildMemberItem(FamilyMemberModel member, FamilyMemberModel currentMember) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: member.profileImage != null && member.profileImage!.isNotEmpty
                  ? Image.network(
                      member.profileImage!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(member.displayName);
                      },
                    )
                  : _buildDefaultAvatar(member.displayName),
            ),
          ),
          const SizedBox(width: 12),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.displayName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                    ),
                    if (member.userId == currentMember.userId) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '(You)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added ${member.itemsAddedThisMonth} items this month',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Status and Role
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Online Status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: member.isOnline ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    member.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: member.isOnline ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: member.isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  member.roleDisplayName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          // Menu Button
          if (currentMember.isAdmin && member.userId != currentMember.userId)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
              onSelected: (value) => _handleMemberAction(value, member),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'promote',
                  child: Text('Make Admin'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove Member'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Family Activity',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF111827),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<List<ActivityModel>>(
            stream: _activityService.getActivitiesStream(limit: 3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF10B981),
                    strokeWidth: 2,
                  ),
                );
              }

              final activities = snapshot.data ?? [];

              if (activities.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No recent activity',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: activities
                    .map((activity) => _buildActivityItem(activity))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                  ? Image.network(
                      activity.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildActivityIcon(activity);
                      },
                    )
                  : _buildActivityIcon(activity),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                if (activity.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Text(
            activity.timeAgo,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityIcon(ActivityModel activity) {
    final color = Color(activity.colorValue);
    return Container(
      width: 40,
      height: 40,
      color: color.withOpacity(0.1),
      child: Center(
        child: SvgPicture.asset(
          activity.iconPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }

  void _showInviteMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Family Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the email address of the person you want to invite to your family.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _sendInvitation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvitation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    try {
      await _familyService.inviteMember(
        familyId: widget.familyId,
        email: email,
      );

      if (mounted) {
        Navigator.pop(context);
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleMemberAction(String action, FamilyMemberModel member) {
    switch (action) {
      case 'promote':
        _promoteMember(member);
        break;
      case 'remove':
        _removeMember(member);
        break;
    }
  }

  Future<void> _promoteMember(FamilyMemberModel member) async {
    try {
      await _familyService.updateMemberRole(
        familyId: widget.familyId,
        userId: member.userId,
        newRole: FamilyMemberRole.admin,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.displayName} is now an admin'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error promoting member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(FamilyMemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.displayName} from the family?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _familyService.removeMember(
          familyId: widget.familyId,
          userId: member.userId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.displayName} has been removed'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing member: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
} 