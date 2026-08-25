import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/music_activity_card.dart';
import 'piano_screen.dart';
import 'drums_screen.dart';
import 'xylophone_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
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
            child: Column(
              children: [
                // Custom Header (Smaller and Responsive)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? screenWidth * 0.08 : 20.0,
                    vertical: 16.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 0.0, bottom: 0.0),
                      child: Text(
                        'Music',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pinkPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
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
                            _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
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
                            _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
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
                            _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
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
