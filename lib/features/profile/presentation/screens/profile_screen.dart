import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:eat_soon/features/home/models/activity_model.dart';

import 'package:eat_soon/features/family/presentation/screens/family_members_screen.dart';
import 'package:eat_soon/features/family/presentation/widgets/family_switcher.dart';
import 'package:eat_soon/shared/widgets/recent_activity.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Eatsooon'),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildProfileHeader(user),
                const SizedBox(height: 32),
                _buildQuickActionsSection(context),
                const SizedBox(height: 32),
                RecentActivity(
                  title: 'profile_recent_activity'.tr,
                  stream: ActivityService().getActivitiesStream(limit: 5),
                  showDateGroups: true,
                  onViewAll: () {
                    // TODO: Navigate to full activity screen
                  },
                ),
                const SizedBox(height: 32),
                _buildAccountSection(context, authProvider),
                const SizedBox(height: 96), // Bottom padding for navigation
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    final ActivityService activityService = ActivityService();

    return Container(
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
          // Profile Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child:
                user?.photoURL != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        user!.photoURL!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.white,
                          );
                        },
                      ),
                    )
                    : const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user?.name ?? 'John Doe',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF111827),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? 'john.doe@email.com',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.2,
            ),
          ),

          // Family Switcher (shows current family & allows switching)
          const SizedBox(height: 12),
          const FamilySwitcher(),
          const SizedBox(height: 24),

          // Stats Row with Real Activity Data
          StreamBuilder<List<ActivityModel>>(
            stream: activityService.getActivitiesStream(limit: 100),
            builder: (context, snapshot) {
              final activities = snapshot.data ?? [];

              // Calculate real statistics
              final itemsAdded =
                  activities
                      .where((a) => a.type == ActivityType.itemAdded)
                      .length;
              final recipesViewed =
                  activities
                      .where((a) => a.type == ActivityType.recipeViewed)
                      .length;
              final daysActive =
                  activities.isNotEmpty
                      ? DateTime.now()
                              .difference(activities.last.timestamp)
                              .inDays +
                          1
                      : 0;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      '$itemsAdded',
                      'profile_items_added'.tr,
                      AppTheme.secondaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      '$recipesViewed',
                      'profile_recipes_viewed'.tr,
                      AppTheme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      '$daysActive',
                      'profile_days_active'.tr,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              );
            },
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
            fontSize: 26,
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

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'profile_quick_actions'.tr,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF111827),
                height: 1.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'profile_actions_available'.tr,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Primary Action - Edit Profile (Full Width)
        _buildPrimaryActionButton(
          context,
          'profile_edit_profile'.tr,
          'profile_edit_profile_subtitle'.tr,
          Icons.person_outline_rounded,
          AppTheme.primaryColor,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Primary Action - Family (Full Width, styled like Edit Profile)
        _buildPrimaryActionButton(
          context,
          'profile_family'.tr,
          'profile_family_subtitle'.tr,
          Icons.groups_outlined,
          const Color(0xFF10B981),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FamilyMembersScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrimaryActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: color,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: color.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_account'.tr,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF111827),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
              _buildAccountItem(
                Icons.language_rounded,
                'language'.tr,
                'change_language'.tr,
                const Color(0xFF3B82F6),
                () => _showLanguageDialog(context),
              ),
              _buildAccountItem(
                Icons.logout_rounded,
                'profile_sign_out'.tr,
                'profile_sign_out_subtitle'.tr,
                const Color(0xFFEF4444),
                () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Warning Icon
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Title
                                Text(
                                  'profile_sign_out_confirm_title'.tr,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: Color(0xFF111827),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Content
                                Text(
                                  'profile_sign_out_confirm_message'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'profile_cancel'.tr,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFEF4444,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'profile_sign_out'.tr,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  );

                  if (shouldLogout == true) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    await authProvider.signOut();
                  }
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border:
              isLast
                  ? null
                  : const Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) async {
    final Locale? selectedLocale = await showModalBottomSheet<Locale>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final current = Get.locale ?? const Locale('en', 'US');
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  'language'.tr,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RadioListTile<Locale>(
                value: const Locale('en', 'US'),
                groupValue: current,
                onChanged: (val) => Navigator.pop(context, val),
                title: Text('english'.tr),
              ),
              RadioListTile<Locale>(
                value: const Locale('es', 'ES'),
                groupValue: current,
                onChanged: (val) => Navigator.pop(context, val),
                title: Text('spanish'.tr),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selectedLocale != null && selectedLocale != Get.locale) {
      Get.updateLocale(selectedLocale);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'locale',
        '${selectedLocale.languageCode}_${selectedLocale.countryCode ?? ''}',
      );
    }
  }
}
