import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import 'home_screen.dart';
import 'cgpa_screen.dart';
import 'course_screen.dart';
import 'vault_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late ThemeController themeController;

  late final pages = [
    HomeScreen(onNavigate: _changeTab),
    CGPAScreen(),
    CourseScreen(),
    VaultScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
  }

  void _changeTab(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only update palette reference, don't rebuild entire widget
      final palette = themeController.palette;

      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: _OptimizedNavBar(
          selectedIndex: _selectedIndex,
          onTap: _changeTab,
          palette: palette,
        ),
      );
    });
  }
}

// Separated widget to prevent full rebuild
class _OptimizedNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final dynamic palette;

  const _OptimizedNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.palette,
  });

  static const icons = [
    Icons.home_rounded,
    Icons.calculate,
    Icons.menu_book,
    Icons.lock,
    Icons.settings,
  ];

  static const labels = ["Home", "CGPA", "Courses", "Vault", "Settings"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.theme,
        boxShadow: [
          BoxShadow(
            color: palette.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Using map instead of List.generate for better performance
          for (int index = 0; index < icons.length; index++)
            _NavBarItem(
              icon: icons[index],
              label: labels[index],
              isSelected: selectedIndex == index,
              onTap: () => onTap(index),
              primary: palette.primary,
              theme: palette.theme,
            ),
        ],
      ),
    );
  }
}

// Isolated nav item to prevent sibling rebuilds
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color theme;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : theme,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? theme : Colors.grey[700],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
