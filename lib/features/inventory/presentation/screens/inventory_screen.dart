import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/core/theme/figma_colors.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String selectedFilter = 'All Items';
  bool isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dummy data for inventory
  static final List<FoodItem> dummyInventory = [
    // Uncomment to see the inventory with items
    FoodItem(
      id: '1',
      name: 'Milk',
      description: '1L Carton',
      imageUrl: '',
      expirationDate: DateTime.now(),
      status: FoodItemStatus.expiringToday,
    ),
    FoodItem(
      id: '2',
      name: 'Spinach',
      description: '250g Bag',
      imageUrl: '',
      expirationDate: DateTime.now(),
      status: FoodItemStatus.expiringToday,
    ),
    FoodItem(
      id: '3',
      name: 'Chicken Breast',
      description: '500g Package',
      imageUrl: '',
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      status: FoodItemStatus.expiringSoon,
    ),
    FoodItem(
      id: '4',
      name: 'Yogurt Bowl',
      description: '500g Container',
      imageUrl: '',
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      status: FoodItemStatus.expiringSoon,
    ),
    FoodItem(
      id: '5',
      name: 'Avocado Toast',
      description: '2 pieces',
      imageUrl: '',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
      status: FoodItemStatus.fresh,
    ),
  ];

  List<FoodItem> get filteredInventory {
    List<FoodItem> filtered = List.from(dummyInventory);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    item.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Apply category filter
    switch (selectedFilter) {
      case 'Expiring Soon':
        filtered =
            filtered
                .where(
                  (item) =>
                      item.daysUntilExpiration <= 2 &&
                      item.daysUntilExpiration >= 0,
                )
                .toList();
        break;
      case 'Dairy':
        filtered =
            filtered
                .where(
                  (item) =>
                      item.name.toLowerCase().contains('milk') ||
                      item.name.toLowerCase().contains('yogurt') ||
                      item.name.toLowerCase().contains('cheese'),
                )
                .toList();
        break;
      case 'Produce':
        filtered =
            filtered
                .where(
                  (item) =>
                      item.name.toLowerCase().contains('spinach') ||
                      item.name.toLowerCase().contains('avocado') ||
                      item.name.toLowerCase().contains('banana') ||
                      item.name.toLowerCase().contains('apple'),
                )
                .toList();
        break;
      case 'Meat':
        filtered =
            filtered
                .where(
                  (item) =>
                      item.name.toLowerCase().contains('chicken') ||
                      item.name.toLowerCase().contains('beef') ||
                      item.name.toLowerCase().contains('pork'),
                )
                .toList();
        break;
      case 'All Items':
      default:
        // No additional filtering needed
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredInventory;
    final expiringToday =
        filtered.where((item) => item.daysUntilExpiration <= 0).toList();
    final expiringThisWeek =
        filtered
            .where(
              (item) =>
                  item.daysUntilExpiration > 0 && item.daysUntilExpiration <= 7,
            )
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.white.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Title and Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Inventory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: FigmaColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Row(
                      children: [
                        // Search Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearchVisible = !isSearchVisible;
                              if (isSearchVisible) {
                                _searchController.clear();
                                searchQuery = '';
                              }
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  isSearchVisible
                                      ? FigmaColors.freshGreen.withOpacity(0.1)
                                      : FigmaColors.backgroundLight,
                              shape: BoxShape.circle,
                              border:
                                  isSearchVisible
                                      ? Border.all(
                                        color: FigmaColors.freshGreen,
                                        width: 1,
                                      )
                                      : null,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/search_icon.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search Bar (conditionally visible)
                if (isSearchVisible) ...[
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: FigmaColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FigmaColors.freshGreen.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search inventory...',
                        hintStyle: TextStyle(
                          color: FigmaColors.textTertiary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: FigmaColors.freshGreen,
                          size: 20,
                        ),
                        suffixIcon:
                            searchQuery.isNotEmpty
                                ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchController.clear();
                                      searchQuery = '';
                                    });
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: FigmaColors.textTertiary,
                                    size: 20,
                                  ),
                                )
                                : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: FigmaColors.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                        'All Items',
                        selectedFilter == 'All Items',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Expiring Soon',
                        selectedFilter == 'Expiring Soon',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('Dairy', selectedFilter == 'Dairy'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Produce', selectedFilter == 'Produce'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Meat', selectedFilter == 'Meat'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                dummyInventory.isEmpty
                    ? _buildEmptyState()
                    : filtered.isEmpty
                    ? _buildNoResultsState()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Expiring Today Section
                          if (expiringToday.isNotEmpty) ...[
                            _buildSectionHeader(
                              'Expiring Today',
                              expiringToday.length,
                            ),
                            const SizedBox(height: 16),
                            ..._buildInventoryItems(
                              expiringToday,
                              startIndex: 1,
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Expiring This Week Section
                          if (expiringThisWeek.isNotEmpty) ...[
                            _buildSectionHeader(
                              'Expiring This Week',
                              expiringThisWeek.length,
                            ),
                            const SizedBox(height: 16),
                            ..._buildInventoryItems(
                              expiringThisWeek,
                              startIndex: expiringToday.length + 1,
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Show message if no items in current sections but filter has results
                          if (expiringToday.isEmpty &&
                              expiringThisWeek.isEmpty &&
                              filtered.isNotEmpty) ...[
                            _buildNoItemsInSectionState(),
                          ],
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FigmaColors.freshGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? FigmaColors.freshGreen : FigmaColors.freshGreen,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : FigmaColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          '$itemCount items',
          style: TextStyle(
            fontSize: 14,
            color: FigmaColors.freshGreen,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInventoryItems(
    List<FoodItem> items, {
    required int startIndex,
  }) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final itemNumber = startIndex + index;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildInventoryItem(item, itemNumber),
      );
    }).toList();
  }

  Widget _buildInventoryItem(FoodItem item, int number) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          // Number Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: FigmaColors.freshGreen,
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

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: FigmaColors.textTertiary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          // Expiration Text
          Text(
            item.expirationText,
            style: TextStyle(
              fontSize: 14,
              color: item.statusColor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(width: 16),

          // Menu Button
          Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: FigmaColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your inventory is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: FigmaColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start scanning products to track their\nexpiration dates and reduce food waste',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: FigmaColors.textTertiary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to scanner
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scanner coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FigmaColors.freshGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Scan Your First Item',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: FigmaColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.isNotEmpty
                  ? 'No items found for "$searchQuery"'
                  : 'No items in ${selectedFilter.toLowerCase()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FigmaColors.textPrimary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Try selecting a different category or add more items',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: FigmaColors.textTertiary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (searchQuery.isNotEmpty || selectedFilter != 'All Items')
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    searchQuery = '';
                    selectedFilter = 'All Items';
                    isSearchVisible = false;
                  });
                },
                child: Text(
                  searchQuery.isNotEmpty ? 'Clear search' : 'Show all items',
                  style: TextStyle(
                    color: FigmaColors.freshGreen,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoItemsInSectionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Items found but not expiring soon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FigmaColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your filtered items are fresh and not expiring in the next week',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: FigmaColors.textTertiary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
