import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../music/screens/music_screen.dart';
import '../../puzzle/screens/puzzle_hub_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MusicScreen(),
    const PuzzleHubScreen(),
    const Center(child: Text('Me Screen Coming Soon')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for CurvedNavigationBar
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 65.0,
        items: <Widget>[
          _buildNavItem(Icons.home_rounded, 0),
          _buildNavItem(Icons.music_note_rounded, 1),
          _buildNavItem(Icons.extension_rounded, 2),
          _buildNavItem(Icons.face_rounded, 3),
        ],
        color: Colors.white,
        buttonBackgroundColor: _getButtonColor(),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Icon(
      icon,
      size: 26,
      color: isSelected ? Colors.white : Colors.redAccent.shade100,
    );
  }

  Color _getButtonColor() {
    switch (_currentIndex) {
      case 0:
        return Colors.pink.shade300;
      case 1:
        return AppColors.primaryYellow;
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      default:
        return Colors.lightBlue;
    }
  }
}
