import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/home_header.dart';
import '../widgets/featured_banner.dart';
import '../widgets/home_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white, // Fallback
      body: Stack(
        children: [
          // Background Gradient Mesh Effect
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8F6FA), // Light blue top left
                    Color(0xFFFEF2F4), // Light pink top right
                    Color(0xFFFAFAFA), // Whiteish bottom
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? screenWidth * 0.1 : 20.0, 
                    vertical: 16.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HomeHeader(),
                      const SizedBox(height: 24),
                      const FeaturedBanner(),
                      const SizedBox(height: 24),
                      _buildGrid(context, isTablet),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        HomeCard(
          title: 'Learning World',
          subtitle: 'Explore & Discover',
          imagePath: 'assets/images/learning_world.png',
          shadowColor: const Color(0x2600D4FF), // cyan shadow
          onTap: () => context.push('/abc'),
        ),
        HomeCard(
          title: 'Magic Quiz',
          subtitle: 'Show your skills!',
          imagePath: 'assets/images/magic_quiz.png',
          shadowColor: const Color(0x264CAF50), // green shadow
          onTap: () => _showComingSoon(context),
        ),
        HomeCard(
          title: 'Fun Games',
          subtitle: 'Play & Laugh',
          imagePath: 'assets/images/fun_games.png',
          shadowColor: const Color(0x262196F3), // blue shadow
          onTap: () => _showComingSoon(context),
        ),
        HomeCard(
          title: 'Magic Paint',
          subtitle: 'Create Art',
          imagePath: 'assets/images/magic_paint.png',
          shadowColor: const Color(0x26FF5722), // deep orange/red shadow
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming Soon!', style: TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
