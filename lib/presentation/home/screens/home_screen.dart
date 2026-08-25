import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/home_header.dart';
import '../widgets/featured_banner.dart';
import '../widgets/home_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  const SizedBox(height: 16),
                  const FeaturedBanner(),
                  const SizedBox(height: 16),
                  _buildGrid(context, isTablet, screenWidth),
                  const SizedBox(height: 80), // Padding for Curved Navigation Bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isTablet, double screenWidth) {
    final List<Widget> cards = [
      HomeCard(
        title: 'Learning World',
        subtitle: '',
        imagePath: 'assets/images/learning_world.png',
        shadowColor: const Color(0x2600D4FF),
        onTap: () {
          _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
          context.push('/learning-hub');
        },
      ),
      HomeCard(
        title: 'Magic Quiz',
        subtitle: '',
        imagePath: 'assets/images/magic_quiz.png',
        shadowColor: const Color(0x264CAF50),
        onTap: () {
          _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
          context.push('/quiz-selection');
        },
      ),
      HomeCard(
        title: 'Fun Games',
        subtitle: '',
        imagePath: 'assets/images/fun_games.png',
        shadowColor: const Color(0x262196F3),
        onTap: () {
          _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
          context.push('/fun-games');
        },
      ),
      HomeCard(
        title: 'Magic Paint',
        subtitle: '',
        imagePath: 'assets/images/magic_paint.png',
        shadowColor: const Color(0x26FF5722),
        onTap: () {
          _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
          context.push('/magic-paint');
        },
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

