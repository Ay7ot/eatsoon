import 'package:eat_soon/core/theme/app_theme.dart';
import 'package:eat_soon/features/home/presentation/screens/home_screen.dart';
import 'package:eat_soon/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:eat_soon/features/shell/widgets/custom_nav_bar_item.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Define the pages for the navigation (5 tabs now including scan)
  final List<Widget> _pages = [
    const HomeScreen(),
    const InventoryScreen(),
    const Center(child: Text('Scan Screen')), // Scan is now a regular tab
    const Center(child: Text('Recipes Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  // Navigation items data
  final List<Map<String, dynamic>> _navItems = [
    {'icon': 'assets/icons/home.svg', 'label': 'Home'},
    {'icon': 'assets/icons/inventory.svg', 'label': 'Inventory'},
    {'icon': 'assets/icons/scan.svg', 'label': 'Scan'},
    {'icon': 'assets/icons/recipes.svg', 'label': 'Recipes'},
    {'icon': 'assets/icons/profile.svg', 'label': 'Profile'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
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
                        onTap: () => _onItemTapped(index),
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
