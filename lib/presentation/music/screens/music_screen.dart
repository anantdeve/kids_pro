import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/music_activity_card.dart';
import 'piano_screen.dart';
import 'drums_screen.dart';
import 'xylophone_screen.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom Header (Smaller and Responsive)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? screenWidth * 0.08 : 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      // Avatar
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
                            BoxShadow(
                              color: AppColors.shadowGlow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
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
                              'Music Magic Hub 🎶🎶',
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
                ),

                // Music Activity Cards with Staggered Animation
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? screenWidth * 0.08 : 20.0,
                      vertical: 10.0,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final List<Widget> cards = [
                        MusicActivityCard(
                          title: 'Magic Piano 🎹',
                          imagePath: 'assets/images/piano.png',
                          themeColor: Colors.lightBlue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PianoScreen()),
                            );
                          },
                        ),
                        MusicActivityCard(
                          title: 'Fun Drums 🥁',
                          imagePath: 'assets/images/drums.png',
                          themeColor: Colors.lightGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DrumsScreen()),
                            );
                          },
                        ),
                        MusicActivityCard(
                          title: 'Happy Xylophone 🌈',
                          imagePath: 'assets/images/xylophone.png',
                          themeColor: Colors.pinkAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const XylophoneScreen()),
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
                const SizedBox(height: 100), // Bottom padding for curved bar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
