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
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8F6FA),
                    Color(0xFFFEF2F4),
                    Color(0xFFFAFAFA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Magical Background Elements - Using screen size for positioning
          Positioned(top: screenHeight * 0.14, left: screenWidth * 0.08, child: const _FloatingIcon(icon: Icons.star_rounded, color: Color(0xFFFFD600), size: 30, duration: 3000)),
          Positioned(bottom: screenHeight * 0.25, right: screenWidth * 0.1, child: const _FloatingIcon(icon: Icons.auto_awesome_rounded, color: Color(0xFFB39DDB), size: 24, duration: 4000)),
          Positioned(top: screenHeight * 0.35, right: screenWidth * 0.15, child: const _FloatingIcon(icon: Icons.favorite_rounded, color: Color(0xFFF48FB1), size: 20, duration: 3500)),
          Positioned(bottom: screenHeight * 0.12, left: screenWidth * 0.2, child: const _FloatingIcon(icon: Icons.circle, color: Color(0xFF81D4FA), size: 15, duration: 5000)),

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
                  _buildGrid(context, isTablet, screenWidth),
                  const SizedBox(height: 100), // Padding for Curved Navigation Bar
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
        onTap: () => context.push('/quiz-selection'),
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
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 200)),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: cards[index],
        );
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

class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final int duration;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.duration))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Opacity(
            opacity: 0.3,
            child: Icon(widget.icon, color: widget.color, size: widget.size),
          ),
        );
      },
    );
  }
}

