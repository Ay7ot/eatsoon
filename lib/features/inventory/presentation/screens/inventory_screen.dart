import 'package:flutter/material.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/core/theme/figma_colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String selectedFilter = 'All Items';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool showSortOptions = false;
  String sortBy = 'expiration'; // 'expiration', 'name', 'category'
  Set<String> selectedCategories = {};

  DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Dummy data matching the Figma design
  final List<InventoryItem> dummyItems = [
    InventoryItem(
      name: 'Organic Milk',
      category: 'Dairy • 1 liter',
      expirationText: 'Expires in 1 day',
      statusColor: const Color(0xFFEF4444),
      statusBadge: 'Urgent',
      badgeColor: const Color(0xFFFEE2E2),
      badgeTextColor: const Color(0xFF991B1B),
      borderColor: const Color(0xFFEF4444),
      emoji: '🥛',
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      categoryType: 'Dairy',
    ),
    InventoryItem(
      name: 'Fresh Bananas',
      category: 'Fruits • 6 pieces',
      expirationText: 'Expires today',
      statusColor: const Color(0xFFF59E0B),
      statusBadge: 'Today',
      badgeColor: const Color(0xFFFEF3C7),
      badgeTextColor: const Color(0xFF92400E),
      borderColor: const Color(0xFFF59E0B),
      emoji: '🍌',
      expirationDate: DateTime.now(),
      categoryType: 'Fruits',
    ),
    InventoryItem(
      name: 'Whole Grain Bread',
      category: 'Bakery • 1 loaf',
      expirationText: 'Expires in 5 days',
      statusColor: const Color(0xFF10B981),
      statusBadge: 'Fresh',
      badgeColor: const Color(0xFFD1FAE5),
      badgeTextColor: const Color(0xFF065F46),
      borderColor: const Color(0xFF10B981),
      emoji: '🍞',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
      categoryType: 'Bakery',
    ),
    InventoryItem(
      name: 'Greek Yogurt',
      category: 'Dairy • 500g',
      expirationText: 'Expires in 2 days',
      statusColor: const Color(0xFFF59E0B),
      statusBadge: 'Soon',
      badgeColor: const Color(0xFFFEF3C7),
      badgeTextColor: const Color(0xFF92400E),
      borderColor: const Color(0xFFF59E0B),
      emoji: '🥛',
      expirationDate: DateTime.now().add(const Duration(days: 2)),
      categoryType: 'Dairy',
    ),
    InventoryItem(
      name: 'Fresh Spinach',
      category: 'Vegetables • 250g',
      expirationText: 'Expires today',
      statusColor: const Color(0xFFEF4444),
      statusBadge: 'Today',
      badgeColor: const Color(0xFFFEE2E2),
      badgeTextColor: const Color(0xFF991B1B),
      borderColor: const Color(0xFFEF4444),
      emoji: '🥬',
      expirationDate: DateTime.now(),
      categoryType: 'Vegetables',
    ),
    InventoryItem(
      name: 'Chicken Breast',
      category: 'Meat • 500g',
      expirationText: 'Expires in 3 days',
      statusColor: const Color(0xFF10B981),
      statusBadge: 'Fresh',
      badgeColor: const Color(0xFFD1FAE5),
      badgeTextColor: const Color(0xFF065F46),
      borderColor: const Color(0xFF10B981),
      emoji: '🍗',
      expirationDate: DateTime.now().add(const Duration(days: 3)),
      categoryType: 'Meat',
    ),
    InventoryItem(
      name: 'Cheddar Cheese',
      category: 'Dairy • 200g',
      expirationText: 'Expires in 1 day',
      statusColor: const Color(0xFFEF4444),
      statusBadge: 'Urgent',
      badgeColor: const Color(0xFFFEE2E2),
      badgeTextColor: const Color(0xFF991B1B),
      borderColor: const Color(0xFFEF4444),
      emoji: '🧀',
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      categoryType: 'Dairy',
    ),
    InventoryItem(
      name: 'Fresh Apples',
      category: 'Fruits • 4 pieces',
      expirationText: 'Expires in 6 days',
      statusColor: const Color(0xFF10B981),
      statusBadge: 'Fresh',
      badgeColor: const Color(0xFFD1FAE5),
      badgeTextColor: const Color(0xFF065F46),
      borderColor: const Color(0xFF10B981),
      emoji: '🍎',
      expirationDate: DateTime.now().add(const Duration(days: 6)),
      categoryType: 'Fruits',
    ),
    InventoryItem(
      name: 'Pasta',
      category: 'Pantry • 500g',
      expirationText: 'Expires in 30 days',
      statusColor: const Color(0xFF10B981),
      statusBadge: 'Fresh',
      badgeColor: const Color(0xFFD1FAE5),
      badgeTextColor: const Color(0xFF065F46),
      borderColor: const Color(0xFF10B981),
      emoji: '🍝',
      expirationDate: DateTime.now().add(const Duration(days: 30)),
      categoryType: 'Pantry',
    ),
    InventoryItem(
      name: 'Expired Milk',
      category: 'Dairy • 1 liter',
      expirationText: 'Expired 2 days ago',
      statusColor: const Color(0xFF7F1D1D),
      statusBadge: 'Expired',
      badgeColor: const Color(0xFFFEE2E2),
      badgeTextColor: const Color(0xFF7F1D1D),
      borderColor: const Color(0xFF7F1D1D),
      emoji: '🥛',
      expirationDate: DateTime.now().subtract(const Duration(days: 2)),
      categoryType: 'Dairy',
    ),
  ];

  List<String> get allCategories =>
      dummyItems.map((e) => e.categoryType).toSet().toList()..sort();

  List<InventoryItem> get filteredItems {
    List<InventoryItem> filtered = List.from(dummyItems);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.category.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.categoryType.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Apply category filter from the icon
    if (selectedCategories.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return selectedCategories.contains(item.categoryType);
          }).toList();
    }

    final today = _dateOnly(DateTime.now());

    // Apply expiration status filter from tabs
    switch (selectedFilter) {
      case 'Expiring Soon':
        filtered =
            filtered.where((item) {
              final expirationDay = _dateOnly(item.expirationDate);
              final daysUntilExpiration =
                  expirationDay.difference(today).inDays;
              return daysUntilExpiration > 0 && daysUntilExpiration <= 3;
            }).toList();
        break;
      case 'Expires Today':
        filtered =
            filtered.where((item) {
              final expirationDay = _dateOnly(item.expirationDate);
              return expirationDay.isAtSameMomentAs(today);
            }).toList();
        break;
      case 'Expired':
        filtered =
            filtered.where((item) {
              final expirationDay = _dateOnly(item.expirationDate);
              return expirationDay.isBefore(today);
            }).toList();
        break;
      case 'All Items':
      default:
        // No additional filtering needed
        break;
    }

    // Apply sorting
    switch (sortBy) {
      case 'expiration':
        filtered.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'category':
        filtered.sort((a, b) => a.categoryType.compareTo(b.categoryType));
        break;
    }

    return filtered;
  }

  Map<String, int> get statisticsData {
    final today = _dateOnly(DateTime.now());
    int expiring = 0;
    int todayCount = 0;
    int total = dummyItems.length;

    for (final item in dummyItems) {
      final expirationDay = _dateOnly(item.expirationDate);
      final daysUntilExpiration = expirationDay.difference(today).inDays;

      if (expirationDay.isAtSameMomentAs(today)) {
        todayCount++;
      } else if (daysUntilExpiration > 0 && daysUntilExpiration <= 3) {
        expiring++;
      }
    }

    return {'expiring': expiring, 'today': todayCount, 'total': total};
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryFilterBottomSheet() {
    final tempSelectedCategories = Set<String>.from(selectedCategories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Category',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          allCategories.map((category) {
                            return CheckboxListTile(
                              title: Text(category),
                              value: tempSelectedCategories.contains(category),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    tempSelectedCategories.add(category);
                                  } else {
                                    tempSelectedCategories.remove(category);
                                  }
                                });
                              },
                              activeColor: const Color(0xFF10B981),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedCategories.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategories = tempSelectedCategories;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              _buildSortOption(
                'Expiration Date',
                'expiration',
                Icons.access_time_rounded,
              ),
              _buildSortOption('Name', 'name', Icons.sort_by_alpha_rounded),
              _buildSortOption('Category', 'category', Icons.category_rounded),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    final isSelected = sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF111827),
        ),
      ),
      trailing:
          isSelected
              ? const Icon(Icons.check_rounded, color: Color(0xFF10B981))
              : null,
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = statisticsData;
    final filtered = filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: Column(
        children: [
          // Sticky Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
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
                // Header with title and action buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Inventory',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF111827),
                          height: 1.3,
                        ),
                      ),
                      Row(
                        children: [
                          // Sort button
                          GestureDetector(
                            onTap: _showSortBottomSheet,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2.4,
                                    offset: const Offset(0, 1.2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.sort,
                                color: Color(0xFF4B5563),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Filter button
                          GestureDetector(
                            onTap: _showCategoryFilterBottomSheet,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    selectedCategories.isNotEmpty
                                        ? const Color(0xFFD1FAE5)
                                        : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2.4,
                                    offset: const Offset(0, 1.2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.filter_alt_outlined,
                                color:
                                    selectedCategories.isNotEmpty
                                        ? const Color(0xFF065F46)
                                        : const Color(0xFF4B5563),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Statistics Cards
                  _buildStatisticsCards(stats),
                  const SizedBox(height: 24),

                  // Filter Tabs
                  _buildFilterTabs(),
                  const SizedBox(height: 24),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 24),

                  // Results info
                  if (searchQuery.isNotEmpty ||
                      selectedFilter != 'All Items' ||
                      selectedCategories.isNotEmpty)
                    _buildResultsInfo(filtered.length),

                  // Inventory Items
                  _buildInventoryList(filtered),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo(int count) {
    String filterText = '';
    List<String> activeFilters = [];

    if (searchQuery.isNotEmpty) {
      activeFilters.add('for "$searchQuery"');
    }
    if (selectedCategories.isNotEmpty) {
      activeFilters.add('in ${selectedCategories.length} categories');
    }
    if (selectedFilter != 'All Items') {
      activeFilters.add('in $selectedFilter');
    }

    if (activeFilters.isNotEmpty) {
      filterText = activeFilters.join(' ');
    }

    final hasActiveFilters =
        searchQuery.isNotEmpty ||
        selectedFilter != 'All Items' ||
        selectedCategories.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'} found $filterText',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  searchQuery = '';
                  selectedFilter = 'All Items';
                  selectedCategories.clear();
                  _searchController.clear();
                });
              },
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning_rounded,
            iconColor: const Color(0xFFEF4444),
            iconBgColor: const Color(0xFFFEE2E2),
            value: '${stats['expiring']}',
            valueColor: const Color(0xFFEF4444),
            label: 'Expiring',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFEF3C7),
            value: '${stats['today']}',
            valueColor: const Color(0xFFF59E0B),
            label: 'Today',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFD1FAE5),
            value: '${stats['total']}',
            valueColor: const Color(0xFF10B981),
            label: 'Total',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                label,
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
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
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
              widthFactor:
                  label.contains('Expiring')
                      ? 0.3
                      : label.contains('Today')
                      ? 0.2
                      : 0.8,
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

  Widget _buildFilterTabs() {
    final filters = ['All Items', 'Expiring Soon', 'Expires Today', 'Expired'];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Container(
            margin: EdgeInsets.only(right: index < filters.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2.4,
                      offset: const Offset(0, 1.2),
                    ),
                  ],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF9CA3AF),
            height: 1.2,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryList(List<InventoryItem> items) {
    if (items.isEmpty) {
      String title = 'No items in inventory';
      String subtitle = 'Start by scanning your first product';

      if (searchQuery.isNotEmpty ||
          selectedFilter != 'All Items' ||
          selectedCategories.isNotEmpty) {
        title = 'No items found';
        subtitle = 'Try adjusting your search or filters';
      }

      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) => _buildInventoryItem(item)).toList(),
    );
  }

  Widget _buildInventoryItem(InventoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        border: Border(left: BorderSide(color: item.borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.4,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image/Emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(9.6),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                    item.category,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.expirationText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: item.statusColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge and Menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.statusBadge,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: item.badgeTextColor,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItem {
  final String name;
  final String category;
  final String expirationText;
  final Color statusColor;
  final String statusBadge;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color borderColor;
  final String emoji;
  final DateTime expirationDate;
  final String categoryType;

  InventoryItem({
    required this.name,
    required this.category,
    required this.expirationText,
    required this.statusColor,
    required this.statusBadge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.borderColor,
    required this.emoji,
    required this.expirationDate,
    required this.categoryType,
  });
}
