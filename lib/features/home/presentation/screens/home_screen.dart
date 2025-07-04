import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:eat_soon/features/home/models/activity_model.dart';
import 'package:eat_soon/features/family/presentation/screens/family_members_screen.dart';
import 'package:eat_soon/features/family/data/services/family_service.dart';
import 'package:eat_soon/features/family/data/models/family_member_model.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/features/family/presentation/widgets/family_switcher.dart';
import 'package:eat_soon/shared/widgets/recent_activity.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InventoryService _inventoryService = InventoryService();
  final ActivityService _activityService = ActivityService();
  final FamilyService _familyService = FamilyService();
  late final Stream<List<FoodItem>> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = _inventoryService.getFoodItemsStream();
  }

  DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  Map<String, int> _calculateStatistics(List<FoodItem> items) {
    final today = _dateOnly(DateTime.now());
    int expiring = 0;
    int total = items.length;

    for (final item in items) {
      final expirationDay = _dateOnly(item.expirationDate);
      final daysUntilExpiration = expirationDay.difference(today).inDays;

      if (daysUntilExpiration > 0 && daysUntilExpiration <= 3) {
        expiring++;
      }
    }

    return {'expiring': expiring, 'total': total};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsooon'),
      body: SafeArea(
        child: StreamBuilder<List<FoodItem>>(
          stream: _itemsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final items = snapshot.data ?? [];
            final statistics = _calculateStatistics(items);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Statistics Cards
                  _buildStatisticsCards(statistics),
                  const SizedBox(height: 32),
                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  // Recent Activity
                  RecentActivity(
                    title: 'home_recent_activity'.tr,
                    stream: _activityService.getActivitiesStream(limit: 3),
                    showUserAvatars: true,
                    onViewAll: () {
                      // TODO: Navigate to full activity screen
                    },
                  ),
                  const SizedBox(height: 32),
                  // Family Members
                  _buildFamilyMembers(),
                  const SizedBox(height: 96), // Bottom padding for navigation
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF10B981)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            'home_error_loading_data'.tr,
            style: const TextStyle(
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
            child: Text('home_retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, int> statistics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'home_expiring_soon'.tr,
            value: '${statistics['expiring'] ?? 0}',
            valueColor: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFFFFFFF),
            iconBackgroundColor: const Color(0xFFFEE2E2),
            icon: SvgPicture.asset(
              'assets/icons/warning_icon.svg',
              width: 28.8,
              height: 28.8,
            ),
          ),
        ),
        const SizedBox(width: 19.2),
        Expanded(
          child: _buildStatCard(
            title: 'home_total_items'.tr,
            value: '${statistics['total'] ?? 0}',
            valueColor: const Color(0xFF10B981),
            backgroundColor: const Color(0xFFFFFFFF),
            iconBackgroundColor: const Color(0xFFD1FAE5),
            icon: SvgPicture.asset(
              'assets/icons/inventory_icon.svg',
              width: 28.8,
              height: 28.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required Color backgroundColor,
    required Color iconBackgroundColor,
    required Widget icon,
  }) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.2,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: icon,
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: valueColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: title.contains('Expiring') ? 0.3 : 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: valueColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home_quick_actions'.tr,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF111827),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            // Scan Product Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(14.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2.4,
                    offset: const Offset(0, 1.2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.4),
                  onTap: () {
                    // Find the AppShell and switch to scan tab (index 2)
                    final appShell =
                        context.findAncestorStateOfType<AppShellState>();
                    if (appShell != null) {
                      appShell.onItemTapped(2); // Switch to scan tab
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/camera_icon.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'home_scan_product'.tr,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Recipe Suggestions Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(14.4),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2.4,
                    offset: const Offset(0, 1.2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.4),
                  onTap: () {
                    // Find the AppShell and switch to recipes tab (index 3)
                    final appShell =
                        context.findAncestorStateOfType<AppShellState>();
                    if (appShell != null) {
                      appShell.onItemTapped(3); // Switch to recipes tab
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/book_icon.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'home_recipe_suggestions'.tr,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF374151),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyMembers() {
    final familyId = context.watch<AuthProvider>().currentFamilyId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FamilySwitcher(),
        const SizedBox(height: 16),
        if (familyId == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.groups_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'home_no_family_connected'.tr,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'home_family_subtitle'.tr,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FamilyMembersScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'home_get_started'.tr,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: StreamBuilder<List<FamilyMemberModel>>(
              stream: _familyService.getFamilyMembersStream(familyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'home_error_loading_members'.tr,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final members = snapshot.data ?? [];

                if (members.isEmpty) {
                  return Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Text(
                      'home_no_family_members'.tr,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Family stats row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.groups,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'home_family_members_count'.trArgs([
                                    members.length.toString(),
                                  ]),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  'home_sharing_pantry'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'home_active'.tr,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Members grid
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          members.take(6).map((member) {
                            return _buildEnhancedFamilyMember(member);
                          }).toList(),
                    ),

                    if (members.length > 6) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const FamilyMembersScreen(),
                              ),
                            );
                          },
                          child: Text(
                            '+${members.length - 6} more members',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildFamilyActivitySection(familyId),
                    ],
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedFamilyMember(FamilyMemberModel member) {
    return Container(
      width: 80,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color:
                        member.role == FamilyMemberRole.admin
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (member.role == FamilyMemberRole.admin
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981))
                          .withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child:
                      member.profileImage != null &&
                              member.profileImage!.isNotEmpty
                          ? Image.network(
                            member.profileImage!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 52,
                                height: 52,
                                color: const Color(0xFFF8FAFC),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 52,
                                height: 52,
                                color: const Color(0xFFF8FAFC),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF6B7280),
                                  size: 24,
                                ),
                              );
                            },
                          )
                          : Container(
                            width: 52,
                            height: 52,
                            color: const Color(0xFFF8FAFC),
                            child: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF6B7280),
                              size: 24,
                            ),
                          ),
                ),
              ),
              // Role indicator
              if (member.role == FamilyMemberRole.admin)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            member.displayName.split(' ').first,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Color(0xFF111827),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (member.role == FamilyMemberRole.admin
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.role == FamilyMemberRole.admin ? 'Admin' : 'Member',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 9,
                color:
                    member.role == FamilyMemberRole.admin
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyActivitySection(String familyId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Family Activity',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getFamilyActivitiesStream(
            familyId,
            limit: 3,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF10B981),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Text('Error loading activity');
            }

            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return const Text(
                'No recent family activity',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              );
            }

            return Column(
              children:
                  activities
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFamilyActivityItem(a),
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFamilyActivityItem(ActivityModel activity) {
    final Color activityColor = Color(activity.colorValue);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: activityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: SvgPicture.asset(
              activity.iconPath,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(activityColor, BlendMode.srcIn),
            ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.userName ?? '',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Text(
          activity.timeAgo,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
