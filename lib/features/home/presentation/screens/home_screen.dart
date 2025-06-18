import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/home/services/activity_service.dart';
import 'package:eat_soon/features/home/models/activity_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InventoryService _inventoryService = InventoryService();
  final ActivityService _activityService = ActivityService();
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
      appBar: const CustomAppBar(title: 'Eatsoon'),
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
                  _buildRecentActivity(),
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
          const Text(
            'Error loading data',
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

  Widget _buildStatisticsCards(Map<String, int> statistics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Expiring\nSoon',
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
            title: 'Total Items',
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
        const Text(
          'Quick Actions',
          style: TextStyle(
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
                        const Text(
                          'Scan Product',
                          style: TextStyle(
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
                        const Text(
                          'Recipe Suggestions',
                          style: TextStyle(
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
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
              return _buildActivityLoadingState();
            }

            if (snapshot.hasError) {
              return _buildActivityErrorState();
            }

            final activities = snapshot.data ?? [];

            if (activities.isEmpty) {
              return _buildNoActivityState();
            }

            return Column(
              children:
                  activities
                      .map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildActivityItemFromModel(activity),
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF10B981),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildActivityErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.error_outline, size: 32, color: Color(0xFFEF4444)),
          SizedBox(height: 8),
          Text(
            'Error loading activity',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivityState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/inventory_icon.svg',
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(
              Color(0xFF9CA3AF),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No recent activity',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start by adding items to your pantry',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItemFromModel(ActivityModel activity) {
    final Color activityColor = Color(activity.colorValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.6),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.6),
              child: _buildActivityImage(
                activity.imageUrl,
                activity.iconPath,
                activityColor,
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
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
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
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildActivityImage(
    String? imageUrl,
    String iconPath,
    Color activityColor,
  ) {
    // Priority 1: Show actual item image if available
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 56,
            height: 56,
            color: const Color(0xFFF8FAFC),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // If image fails to load, fall back to icon
          return _buildActivityIcon(iconPath, activityColor);
        },
      );
    }

    // Priority 2: Show activity type icon
    return _buildActivityIcon(iconPath, activityColor);
  }

  Widget _buildActivityIcon(String iconPath, Color activityColor) {
    return Container(
      width: 56,
      height: 56,
      color: activityColor.withOpacity(0.1),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(activityColor, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildFamilyMembers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            TextButton(
              onPressed: () {},
              child: const Text(
                'Add',
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
        Row(
          children: [
            _buildFamilyMember(
              'You',
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
            ),
            const SizedBox(width: 16),
            _buildFamilyMember(
              'Sarah',
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
            ),
            const SizedBox(width: 16),
            _buildFamilyMember(
              'Mike',
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyMember(String name, String imageUrl) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF8FAFC),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF8FAFC),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF6B7280),
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
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
}
