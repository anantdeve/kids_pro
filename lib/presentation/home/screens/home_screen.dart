import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/home_header.dart';
import '../widgets/featured_banner.dart';
import '../widgets/home_card.dart';
import '../../../core/providers/child_standard_provider.dart';
import '../../../domain/entities/child_standard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? screenWidth * 0.08 : 20.0, 
                vertical: 16.0
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HomeHeader(),
                  const SizedBox(height: 24),
                  const FeaturedBanner(),
                  const SizedBox(height: 24),
                  _buildGrid(context, ref, isTablet, screenWidth),
                  const SizedBox(height: 100), // Padding for Curved Navigation Bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, bool isTablet, double screenWidth) {
    final List<Widget> cards = [
      HomeCard(
        title: 'Learning World',
        subtitle: 'Explore & Discover',
        imagePath: 'assets/images/learning_world.png',
        shadowColor: const Color(0x2600D4FF),
        onTap: () => context.push('/learning-hub'),
      ),
      HomeCard(
        title: 'Magic Quiz',
        subtitle: 'Show your skills!',
        imagePath: 'assets/images/magic_quiz.png',
        shadowColor: const Color(0x264CAF50),
        onTap: () {
          context.push('/quiz-selection');
        },
      ),
      HomeCard(
        title: 'Fun Games',
        subtitle: 'Play & Laugh',
        imagePath: 'assets/images/fun_games.png',
        shadowColor: const Color(0x262196F3),
        onTap: () => context.push('/fun-games'),
      ),
      HomeCard(
        title: 'Magic Paint',
        subtitle: 'Create Art',
        imagePath: 'assets/images/magic_paint.png',
        shadowColor: const Color(0x26FF5722),
        onTap: () => context.push('/magic-paint'),
      ),
    ];

    // Dynamic aspect ratio based on screen width
    final double aspectRatio = isTablet ? 0.95 : (screenWidth > 400 ? 0.9 : 0.82);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        return cards[index];
      },
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

