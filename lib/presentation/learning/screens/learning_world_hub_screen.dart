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

    final List<Widget> cards = [
      LearningHubCard(
        title: 'Maths fun',
        subtitle: 'Fun math games and puzzles!',
        titleEmoji: '🔢',
        imagePath: 'assets/images/number_magic.png', // reusing an existing asset
        fallbackIcon: Icons.calculate_rounded,
        titleColor: const Color(0xFFF06292), // Pink
        onTap: () => context.push('/arithmetic-hub'),
      ),
      LearningHubCard(
        title: 'Colors Adventure',
        subtitle: 'Paint the world with colors!',
        imagePath: 'assets/images/colors_adventure.png',
        fallbackIcon: Icons.palette_rounded,
        titleColor: const Color(0xFFFF8B66), // Salmon
        onTap: () => context.push('/colors-adventure'),
      ),
      LearningHubCard(
        title: 'Number Magic',
        subtitle: 'Learn counting and math fun!',
        imagePath: 'assets/images/number_magic.png',
        fallbackIcon: Icons.calculate_rounded,
        titleColor: const Color(0xFF4ECDC4), // Teal
        onTap: () => context.push('/number-magic'),
      ),
      LearningHubCard(
        title: 'Alphabet Fun',
        subtitle: 'Discover letters and surprises!',
        titleEmoji: '🎁',
        imagePath: 'assets/images/alphabet_fun.png',
        fallbackIcon: Icons.abc_rounded,
        titleColor: const Color(0xFFFF7B9C), // Pink
        onTap: () => context.push('/alphabet-surprise'),
      ),
      LearningHubCard(
        title: 'Word Match',
        subtitle: 'Match words to pictures!',
        titleEmoji: '🧩',
        imagePath: 'assets/images/word_matching.png',
        fallbackIcon: Icons.image_search_rounded,
        titleColor: const Color(0xFF8C52FF), // Purple
        onTap: () => context.push('/match-word'),
      ),
      LearningHubCard(
        title: 'Listen & Choose',
        subtitle: 'Hear the word, find the match!',
        titleEmoji: '👂',
        imagePath: 'assets/images/listen_and_choose.png',
        fallbackIcon: Icons.hearing_rounded,
        titleColor: const Color(0xFFFF914D), // Orange
        onTap: () => context.push('/listen-word'),
      ),
      LearningHubCard(
        title: 'Word Builder',
        subtitle: 'Drag letters to build words!',
        titleEmoji: '🏗️',
        imagePath: 'assets/images/alphabet_fun.png',
        fallbackIcon: Icons.extension_rounded,
        titleColor: const Color(0xFF00BF63), // Green
        onTap: () => context.push('/drag-letters'),
      ),
      LearningHubCard(
        title: 'Learn Grammar',
        subtitle: 'Master words and sentences!',
        titleEmoji: '📝',
        imagePath: 'assets/images/grammar.png',
        fallbackIcon: Icons.menu_book_rounded,
        titleColor: const Color(0xFFFF66B2), // Bright Pink
        onTap: () => context.push('/grammar-hub'),
      ),
    ];

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
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
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
