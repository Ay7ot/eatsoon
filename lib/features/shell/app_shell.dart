import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/home/presentation/screens/home_screen.dart';
import 'package:eat_soon/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:eat_soon/features/scanner/presentation/screens/scan_screen.dart';
import 'package:eat_soon/features/recipes/presentation/screens/recipes_screen.dart';
import 'package:eat_soon/features/profile/presentation/screens/profile_screen.dart';
import 'package:eat_soon/features/shell/widgets/custom_nav_bar_item.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  // Global key to access AppShell state from anywhere
  static final GlobalKey<AppShellState> shellKey = GlobalKey<AppShellState>();

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Use IndexedStack instead of PageView for better performance
  // Pages are built lazily and maintain their state
  late final List<Widget> _pages;

  // Track which pages have been visited to enable lazy loading
  final Set<int> _visitedPages = {0}; // Home is visited by default

  // Navigation items data
  final List<Map<String, dynamic>> _navItems = [
    {'icon': 'assets/icons/home.svg', 'label': 'Home'},
    {'icon': 'assets/icons/inventory.svg', 'label': 'Inventory'},
    {'icon': 'assets/icons/scan.svg', 'label': 'Scan'},
    {'icon': 'assets/icons/recipes.svg', 'label': 'Recipes'},
    {'icon': 'assets/icons/profile.svg', 'label': 'Profile'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize pages list
    _pages = [
      const HomeScreen(),
      const InventoryScreen(),
      const ScanScreen(),
      const RecipesScreen(),
      const ProfileScreen(),
    ];
  }

  // Method to navigate to a specific tab from external widgets
  void navigateToTab(int index) {
    if (index >= 0 && index < _pages.length && index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _visitedPages.add(index); // Mark page as visited for lazy loading
      });
    }
  }

  void onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _visitedPages.add(index); // Mark page as visited for lazy loading
      });
    }
  }

  Widget _buildPage(int index) {
    // Lazy loading: only build pages that have been visited
    if (_visitedPages.contains(index)) {
      return _pages[index];
    } else {
      // Return a lightweight placeholder for unvisited pages
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_pages.length, (index) => _buildPage(index)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFFAFAFA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]!
                      : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _navItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return CustomNavBarItem(
                        svgPath: item['icon'],
                        label: item['label'],
                        isSelected: _selectedIndex == index,
                        onTap: () => onItemTapped(index),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
