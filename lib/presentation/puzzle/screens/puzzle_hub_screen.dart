import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../music/widgets/music_activity_card.dart';
import 'shape_matcher_screen.dart';
import 'animal_jigsaw_list_screen.dart';
import 'blockbuster_puzzle_screen.dart';
import 'arrow_escape_difficulty_screen.dart';

class PuzzleHubScreen extends StatelessWidget {
  const PuzzleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Magical Background (matching Music screen style but different colors)
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF5F8), // Light Pink
                    Color(0xFFF0F7FF), // Light Blue
                    Color(0xFFFFF9E1), // Light Yellow
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
                // Header (matching Music screen)
                _buildHeader(context, screenWidth, isTablet),

                // Puzzle Activity Cards
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: isTablet ? screenWidth * 0.08 : 20.0,
                      right: isTablet ? screenWidth * 0.08 : 20.0,
                      top: 10.0,
                      bottom: 150.0, // Extra padding to allow scrolling past the bottom bar
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final List<Widget> cards = [
                        MusicActivityCard(
                          title: 'Magical Shapes 🌟',
                          subtitle: 'Match the stars, circles, and more!',
                          imagePath: 'assets/images/number_puzzle.png',
                          themeColor: Colors.orangeAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ShapeMatcherScreen()),
                            );
                          },
                        ),
                        MusicActivityCard(
                          title: 'Animal Jigsaw 🦁',
                          subtitle: 'Put the animal pieces together!',
                          imagePath: 'assets/images/number_puzzle.png',
                          themeColor: Colors.greenAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AnimalJigsawListScreen()),
                            );
                          },
                        ),
                        MusicActivityCard(
                          title: 'BlockBuster 🧱',
                          subtitle: 'Place the blocks to clear rows!',
                          imagePath: 'assets/images/number_puzzle.png',
                          themeColor: Colors.blueAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BlockBusterPuzzleScreen()),
                            );
                          },
                        ),
                        MusicActivityCard(
                          title: 'Arrow Escape 🚀',
                          subtitle: 'Tap to free the blocks!',
                          imagePath: 'assets/images/number_puzzle.png',
                          themeColor: Colors.purpleAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ArrowEscapeDifficultyScreen()),
                            );
                          },
                        ),
                      ];

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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? screenWidth * 0.08 : 20.0,
        vertical: 16.0,
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(color: AppColors.shadowGlow, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  'Magical Puzzle Hub 🧩',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.055).clamp(20.0, 26.0),
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.displayMedium?.color ?? const Color(0xFF334E68),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
