import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/learning_hub_card.dart';
import '../../../core/widgets/custom_banner_ad.dart';

class LearningWorldHubScreen extends StatelessWidget {
  const LearningWorldHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          if (Theme.of(context).brightness == Brightness.light)
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
          
          SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? screenWidth * 0.08 : 16.0, 
                    vertical: 12.0
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black87),
                          iconSize: isTablet ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF67E1F5),
                                  Color(0xFFB497FF),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Learning World Hub',
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.07).clamp(24.0, 32.0),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final List<Widget> cards = [
                        LearningHubCard(
                          title: 'Colors Adventure',
                          subtitle: 'Paint the world with colors!',
                          secondaryEmoji: '🌈',
                          imagePath: 'assets/images/colors_adventure.png',
                          fallbackIcon: Icons.palette_rounded,
                          titleColor: const Color(0xFFFF8B66), // Salmon
                          onTap: () => context.push('/colors-adventure'),
                        ),
                        LearningHubCard(
                          title: 'Number Magic',
                          subtitle: 'Learn counting and math fun!',
                          secondaryEmoji: '🔢',
                          imagePath: 'assets/images/number_magic.png',
                          fallbackIcon: Icons.calculate_rounded,
                          titleColor: const Color(0xFF4ECDC4), // Teal
                          onTap: () => context.push('/number-magic'),
                        ),
                        LearningHubCard(
                          title: 'Alphabet Fun',
                          subtitle: 'Discover letters and surprises!',
                          titleEmoji: '🎁',
                          secondaryEmoji: '✨',
                          imagePath: 'assets/images/alphabet_fun.png',
                          fallbackIcon: Icons.abc_rounded,
                          titleColor: const Color(0xFFFF7B9C), // Pink
                          onTap: () => context.push('/alphabet-surprise'),
                        ),
                      ];

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 150)),
                        curve: Curves.easeOutBack,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: cards[index],
                      );
                    }, 
                  ),
                ),
              ],
            ),
          ),
          
          // Banner Ad at the bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBannerAd(),
          ),
        ],
      ),
    );
  }
}
