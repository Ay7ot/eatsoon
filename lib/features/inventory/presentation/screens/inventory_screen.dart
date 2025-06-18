import 'package:flutter/material.dart';
import 'package:eat_soon/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:eat_soon/features/inventory/data/services/inventory_service.dart';
import 'package:eat_soon/features/home/models/food_item.dart';
import 'package:eat_soon/features/inventory/presentation/screens/edit_item_screen.dart';
import 'package:shimmer/shimmer.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String selectedFilter = 'All Items';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String sortBy = 'expiration'; // 'expiration', 'name', 'category'
  Set<String> selectedCategories = {};
  final InventoryService _inventoryService = InventoryService();

  // Initialize the stream once to avoid rebuilding and refetching on every
  // state change (e.g., while typing in the search bar).
  late final Stream<List<FoodItem>> _itemsStream =
      _inventoryService.getFoodItemsStream();

  DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Fallback emojis for different categories
  String _getEmojiForCategory(String category) {
    final categoryLower = category.toLowerCase();

    // Dairy products
    if (categoryLower.contains('dairy') ||
        categoryLower.contains('milk') ||
        categoryLower.contains('cheese') ||
        categoryLower.contains('yogurt')) {
      return '🥛';
    }

    // Fruits
    if (categoryLower.contains('fruit') ||
        categoryLower.contains('apple') ||
        categoryLower.contains('banana') ||
        categoryLower.contains('orange')) {
      return '🍎';
    }

    // Vegetables
    if (categoryLower.contains('vegetable') ||
        categoryLower.contains('lettuce') ||
        categoryLower.contains('spinach') ||
        categoryLower.contains('carrot')) {
      return '🥬';
    }

    // Meat
    if (categoryLower.contains('meat') ||
        categoryLower.contains('chicken') ||
        categoryLower.contains('beef') ||
        categoryLower.contains('pork')) {
      return '🍗';
    }

    // Bakery
    if (categoryLower.contains('bakery') ||
        categoryLower.contains('bread') ||
        categoryLower.contains('baked')) {
      return '🍞';
    }

    // Pantry/Dry goods
    if (categoryLower.contains('pantry') ||
        categoryLower.contains('pasta') ||
        categoryLower.contains('rice') ||
        categoryLower.contains('cereal')) {
      return '🥫';
    }

    // Beverages
    if (categoryLower.contains('beverage') ||
        categoryLower.contains('drink') ||
        categoryLower.contains('juice')) {
      return '🥤';
    }

    // Snacks
    if (categoryLower.contains('snack') ||
        categoryLower.contains('chip') ||
        categoryLower.contains('cookie')) {
      return '🍪';
    }

    // Frozen
    if (categoryLower.contains('frozen')) {
      return '🧊';
    }

    // Default fallback
    return '🥫';
  }

  List<FoodItem> _filterItems(List<FoodItem> items) {
    List<FoodItem> filtered = List.from(items);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                item.category.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
    }

    // Apply category filter
    if (selectedCategories.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return selectedCategories.contains(item.category);
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
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return filtered;
  }

  Map<String, int> _calculateStatistics(List<FoodItem> items) {
    final today = _dateOnly(DateTime.now());
    int expiring = 0;
    int todayCount = 0;
    int total = items.length;

    for (final item in items) {
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

  void _showDeleteConfirmation(FoodItem item) {
    showDialog<bool>(
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
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Delete Item',
                    style: TextStyle(
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
                    'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
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
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
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
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                            try {
                              await _inventoryService.deleteFoodItem(item.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item.name} deleted successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting item: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
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
  }

  void _showItemMenu(FoodItem item) {
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
              Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF6B7280)),
                title: const Text('Edit Item'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(item: item),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Item'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(item);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilterBottomSheet(List<String> categories) {
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
                  if (categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No categories available',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children:
                            categories.map((category) {
                            return CheckboxListTile(
                              title: Text(category),
                                value: tempSelectedCategories.contains(
                                  category,
                                ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Eatsoon'),
      body: StreamBuilder<List<FoodItem>>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _InventorySkeleton();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading inventory',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    textAlign: TextAlign.center,
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

          final allItems = snapshot.data ?? [];
          final filteredItems = _filterItems(allItems);
          final statistics = _calculateStatistics(allItems);
          final allCategories =
              allItems.map((item) => item.category).toSet().toList()..sort();

          return Column(
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
                child: Padding(
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
                            onTap:
                                () => _showCategoryFilterBottomSheet(
                                  allCategories,
                                ),
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
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Statistics Cards
                      _buildStatisticsCards(statistics),
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
                        _buildResultsInfo(filteredItems.length),

                  // Inventory Items
                      _buildInventoryList(filteredItems),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count & Icon row at the top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const Spacer(),
          // Label just above the progress bar
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
          const SizedBox(height: 4),
          // Progress bar
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

  Widget _buildInventoryList(List<FoodItem> items) {
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

  Widget _buildInventoryItem(FoodItem item) {
    // Get status badge info based on expiration
    final daysUntilExpiration = item.daysUntilExpiration;
    String statusBadge;
    Color badgeColor;
    Color badgeTextColor;

    if (daysUntilExpiration < 0) {
      statusBadge = 'Expired';
      badgeColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFF7F1D1D);
    } else if (daysUntilExpiration == 0) {
      statusBadge = 'Today';
      badgeColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFF991B1B);
    } else if (daysUntilExpiration == 1) {
      statusBadge = 'Urgent';
      badgeColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFF991B1B);
    } else if (daysUntilExpiration <= 3) {
      statusBadge = 'Soon';
      badgeColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFF92400E);
    } else {
      statusBadge = 'Fresh';
      badgeColor = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF065F46);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.4),
        border: Border(left: BorderSide(color: item.statusColor, width: 4)),
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
                child:
                    item.imageUrl.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(9.6),
                          child: Image.network(
                            item.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                _getEmojiForCategory(item.category),
                                style: const TextStyle(fontSize: 24),
                              );
                            },
                          ),
                        )
                        : Text(
                          _getEmojiForCategory(item.category),
                          style: const TextStyle(fontSize: 24),
                        ),
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
                    '${item.category} • ${item.quantity} ${item.unit}',
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
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusBadge,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: badgeTextColor,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showItemMenu(item),
                  child: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Skeleton Loader Widget
class _InventorySkeleton extends StatelessWidget {
  const _InventorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Header Skeleton
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 24, width: 120, color: Colors.white),
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Statistics
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          height: 115,
                          margin: EdgeInsets.only(left: index == 0 ? 0 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tabs
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder:
                          (context, index) => Container(
                            width: 100,
                            height: 44,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(9.6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 16,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 14,
                                    width: 150,
                                    color: Colors.grey.shade200,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 14,
                                    width: 100,
                                    color: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 24,
                                  width: 60,
                                  color: Colors.grey.shade200,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
