import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/notifications/data/models/alert_model.dart';
import 'package:eat_soon/features/notifications/data/services/alert_service.dart';
import 'package:eat_soon/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AlertService _alertService = AlertService();
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  String _selectedFilter = 'All';

  Future<void> _clearAll() async {
    // Hide from future view in Firestore
    await _alertService.hideAllAlerts();
    // Clear from device notification shade
    await _fln.cancelAll();
    // The stream will automatically update the UI
  }

  String _timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: StreamBuilder<List<AlertModel>>(
        stream: _alertService.getAllAlertsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allNotifications = snapshot.data ?? [];
          final filtered = _getFilteredNotifications(allNotifications);

          return Column(
            children: [
              _buildSubHeader(allNotifications.isNotEmpty),
              Expanded(
                child: allNotifications.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildStatsCards(allNotifications),
                            const SizedBox(height: 24),
                            _buildSmartAlertsCard(),
                            const SizedBox(height: 24),
                            _buildFilterTabs(allNotifications),
                            const SizedBox(height: 24),
                            if (filtered.isEmpty && _selectedFilter != 'All')
                              _buildEmptyFilterState()
                            else
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (_, i) =>
                                    _buildNotificationTile(filtered[i]),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemCount: filtered.length,
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AlertModel> _getFilteredNotifications(List<AlertModel> notifications) {
    switch (_selectedFilter) {
      case 'Today':
        return notifications.where((n) => n.payload == 'expiring_today').toList();
      case 'Soon':
        return notifications
            .where((n) => n.payload == 'expiring_in_two_days')
            .toList();
      case 'All':
      default:
        return notifications;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00E5E7EB), AppTheme.secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.5, 1.0],
          ),
          border: Border(
            bottom: BorderSide(color: AppTheme.borderColor, width: 0.8),
          ),
        ),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          automaticallyImplyLeading: false,
          title: Text(
            'Eatsoon',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
              fontSize: 26,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            GestureDetector(
              onTap: () {
                final shellState = AppShell.shellKey.currentState;
                if (shellState != null) {
                  shellState.navigateToTab(4); // Profile tab
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10.0),
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: AppTheme.whiteColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/icons/settings_icon.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.secondaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader(bool hasNotifications) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF4B5563),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                Text(
                  'Review your smart expiry alerts',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (hasNotifications)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<AlertModel> notifications) {
    final int todayCount =
        notifications.where((n) => n.payload == 'expiring_today').length;
    final int soonCount =
        notifications.where((n) => n.payload == 'expiring_in_two_days').length;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Today', todayCount.toString(), const Color(0xFFEF4444))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard(
                'Soon', soonCount.toString(), const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('All', notifications.length.toString(),
                const Color(0xFF2563EB))),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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

  Widget _buildSmartAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline,
              color: AppTheme.primaryColor, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Expiry Alerts',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Never miss an expiration date with intelligent notifications.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(List<AlertModel> notifications) {
    final filters = ['All', 'Today', 'Soon'];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          int count = 0;
          if (filter == 'All') {
            count = notifications.length;
          } else if (filter == 'Today') {
            count =
                notifications.where((n) => n.payload == 'expiring_today').length;
          } else if (filter == 'Soon') {
            count = notifications
                .where((n) => n.payload == 'expiring_in_two_days')
                .length;
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                '$filter ($count)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'We\'ll let you know when items are expiring.',
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

  Widget _buildEmptyFilterState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'All Clear!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'You have no notifications in this category.',
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

  Widget _buildNotificationTile(AlertModel n) {
    final date = n.timestamp.toDate();
    final bool isUrgent = n.payload == 'expiring_today';
    final bool isSoon = n.payload == 'expiring_in_two_days';
    final Color iconBgColor = isUrgent
        ? const Color(0xFFFEE2E2)
        : isSoon
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFDBEAFE);
    final IconData icon = isUrgent
        ? Icons.error_outline
        : isSoon
            ? Icons.access_time
            : Icons.notifications_none;
    final Color iconColor = isUrgent
        ? const Color(0xFFDC2626)
        : isSoon
            ? const Color(0xFFD97706)
            : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2.4,
              offset: const Offset(0, 1.2),
            ),
          ],
          border: Border(
            left: BorderSide(
                color: n.read ? Colors.transparent : iconColor, width: 4),
          )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (isUrgent || isSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isUrgent ? 'Today' : 'Soon',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: iconColor,
                          ),
                        ),
                      ),
                  ],
                ),
                if (n.body.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      n.body,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  _timeAgo(date),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}