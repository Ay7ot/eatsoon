import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/core/theme/figma_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dummy data for testing - will be replaced with real data later
  static final List<FoodItem> dummyRecentItems = [
    FoodItem(
      id: '1',
      name: 'Yogurt Bowl',
      description: 'Greek yogurt with berries',
      imageUrl:
          'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400',
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      status: FoodItemStatus.expiringSoon,
    ),
    FoodItem(
      id: '2',
      name: 'Avocado Toast',
      description: 'Fresh avocado on sourdough',
      imageUrl:
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
      status: FoodItemStatus.fresh,
    ),
    FoodItem(
      id: '5',
      name: 'Banana Smoothie',
      description: 'Fresh banana protein smoothie',
      imageUrl:
          'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400',
      expirationDate: DateTime.now().add(const Duration(days: 7)),
      status: FoodItemStatus.fresh,
    ),
  ];

  static final List<FoodItem> dummyExpiringSoon = [
    FoodItem(
      id: '3',
      name: 'Milk',
      description: '1L Carton',
      imageUrl: '',
      expirationDate: DateTime.now(),
      status: FoodItemStatus.expiringToday,
    ),
    FoodItem(
      id: '4',
      name: 'Chicken Breast',
      description: '500g Package',
      imageUrl: '',
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      status: FoodItemStatus.expiringSoon,
    ),
    FoodItem(
      id: '6',
      name: 'Bread Loaf',
      description: 'Whole wheat bread',
      imageUrl: '',
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      status: FoodItemStatus.expiringSoon,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header Section
                Text(
                  'Reduce Food Waste',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937), // Figma dark gray
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan products to track expiration dates and save money.',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6B7280), // Figma medium gray
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Start Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(
                      0x3378B242,
                    ), // Figma green with 20% opacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/quick_start_icon.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Start',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFF1F2937,
                                ), // Figma dark gray
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap the scan button to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(
                                  0xFF6B7280,
                                ), // Figma medium gray
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recently Added Section
                Text(
                  'Recently Added',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937), // Figma dark gray
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),

                // Recently Added Items Grid
                dummyRecentItems.isEmpty
                    ? _buildEmptyState('No items added yet')
                    : SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dummyRecentItems.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = dummyRecentItems[index];
                          return _buildRecentlyAddedCard(item);
                        },
                      ),
                    ),

                const SizedBox(height: 32),

                // Expiring Soon Section
                Text(
                  'Expiring Soon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937), // Figma dark gray
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),

                // Expiring Soon List
                dummyExpiringSoon.isEmpty
                    ? _buildEmptyState('No items expiring soon')
                    : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children:
                            dummyExpiringSoon
                                .asMap()
                                .entries
                                .map(
                                  (entry) => _buildExpiringSoonItem(
                                    entry.value,
                                    entry.key + 1,
                                    entry.key < dummyExpiringSoon.length - 1,
                                  ),
                                )
                                .toList(),
                      ),
                    ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedCard(FoodItem item) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child:
                  item.imageUrl.isNotEmpty
                      ? Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.expirationText,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.statusColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonItem(FoodItem item, int number, bool showDivider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              // Expiration text
              Text(
                item.expirationText,
                style: TextStyle(
                  fontSize: 14,
                  color: item.statusColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            height: 1,
            color: Colors.grey[100],
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
