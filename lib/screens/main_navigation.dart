import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'trending_screen.dart';
import '../i18n/strings.dart';
import 'all_tokens_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TrendingScreen(),
    const AllTokensScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          _screens.length,
          (i) => ExcludeFocus(
            excluding: i != _currentIndex,
            child: _screens[i],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(IconlyLight.chart),
            selectedIcon: const Icon(IconlyBold.chart),
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(IconlyLight.document),
            selectedIcon: const Icon(IconlyBold.document),
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(IconlyLight.setting),
            selectedIcon: const Icon(IconlyBold.setting),
            label: '',
          ),
        ],
      ),
    );
  }
}
