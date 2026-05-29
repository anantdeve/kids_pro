import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../music/screens/music_screen.dart';
import '../../puzzle/screens/puzzle_hub_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/navigation_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();


  final List<Widget> _screens = [
    const HomeScreen(),
    const MusicScreen(),
    const PuzzleHubScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    // Sync external navigation changes to the CurvedNavigationBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = _bottomNavigationKey.currentState;
      if (navState != null) {
        // CurvedNavigationBar doesn't expose its internal index easily,
        // but setPage will trigger animation. Only call if necessary to avoid loops.
        // It's usually safer to let the external state drive it through rebuild.
      }
    });

    return Scaffold(
      extendBody: true, // Important for CurvedNavigationBar
      body: _screens[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: currentIndex,
        height: 65.0,
        items: <Widget>[
          _buildNavItem(Icons.home_rounded, 0, currentIndex),
          _buildNavItem(Icons.music_note_rounded, 1, currentIndex),
          _buildNavItem(Icons.extension_rounded, 2, currentIndex),
          _buildNavItem(Icons.face_rounded, 3, currentIndex),
        ],
        color: Theme.of(context).cardColor,
        buttonBackgroundColor: _getButtonColor(currentIndex),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int currentIndex) {
    bool isSelected = currentIndex == index;
    return Icon(
      icon,
      size: 26,
      color: isSelected ? Colors.white : Colors.pink.shade300,
    );
  }

  Color _getButtonColor(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return Colors.pink.shade300;
      case 1:
        return Colors.pink.shade300;
      case 2:
        return Colors.pink.shade300;
      case 3:
        return Colors.pink.shade300;
      default:
        return Colors.pink.shade300;
    }
  }
}
