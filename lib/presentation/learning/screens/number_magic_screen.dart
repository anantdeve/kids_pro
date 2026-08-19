import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/color_activity_card.dart'; // Reusing the same card style

class NumberMagicScreen extends StatefulWidget {
  const NumberMagicScreen({super.key});

  @override
  State<NumberMagicScreen> createState() => _NumberMagicScreenState();
}

class _NumberMagicScreenState extends State<NumberMagicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playPopSound() {
    _audioPlayer.play(AssetSource('audio/Sounds/pop click.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic Background with soft blobs
          if (Theme.of(context).brightness == Brightness.light) ...[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF9F0), Color(0xFFF0F9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            
            // Soft decorative blobs
            Positioned(
              top: -100,
              right: -50,
              child: _buildBlob(300, const Color(0xFFFFD166).withValues(alpha: 0.2)),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _buildBlob(250, const Color(0xFF67E1F5).withValues(alpha: 0.15)),
            ),
            Positioned(
              top: 300,
              right: -20,
              child: _buildBlob(200, const Color(0xFFFF7B9C).withValues(alpha: 0.1)),
            ),
          ],

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          onPressed: () => context.popWithSound(),
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black87, size: 24),
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
                                  Color(0xFFFF8B66),
                                  Color(0xFF67E1F5),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Number Magic',
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.07).clamp(24.0, 30.0),
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

                // Activity List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final List<Widget> cards = [
                        ColorActivityCard(
                          title: 'Number Matching',
                          subtitle: 'Match numbers to sets of objects!',
                          imagePath: 'assets/images/number_matching.png',
                          themeColor: const Color(0xFF67E1F5), // Blue
                          onTap: () {
                            _playPopSound();
                            context.push(Uri(path: '/number-matching-game', queryParameters: {'bgmPath': 'audio/Sounds/feature bk sound.mp3'}).toString());
                          },
                        ),
                        ColorActivityCard(
                          title: 'Count and Tap',
                          subtitle: 'Tap the correct number of stars!',
                          imagePath: 'assets/images/count_and_tap.png',
                          themeColor: const Color(0xFFFF7B9C), // Pink
                          onTap: () {
                            _playPopSound();
                            context.push(Uri(path: '/count-and-tap-game', queryParameters: {'bgmPath': 'audio/Sounds/background_music.mp3'}).toString());
                          },
                        ),
                        ColorActivityCard(
                          title: 'Missing Number',
                          subtitle: 'Find the hidden number in the line!',
                          imagePath: 'assets/images/missing_number.png',
                          themeColor: const Color(0xFFB497FF), // Purple
                          onTap: () {
                            _playPopSound();
                            context.push(Uri(path: '/missing-number-game', queryParameters: {'bgmPath': 'audio/Sounds/feature bk sound.mp3'}).toString());
                          },
                        ),
                        ColorActivityCard(
                          title: 'Number Puzzle',
                          subtitle: 'Build the numbers piece by piece!',
                          imagePath: 'assets/images/number_puzzle.png',
                          themeColor: const Color(0xFF5CD6A1), // Green
                          onTap: () {
                            _playPopSound();
                            context.push(Uri(path: '/number-puzzle-game', queryParameters: {'bgmPath': 'audio/Sounds/background_music.mp3'}).toString());
                          },
                        ),
                        ColorActivityCard(
                          title: 'Look and Match',
                          subtitle: 'Match the numbers to their names!',
                          imagePath: 'assets/images/look_and_match.png',
                          themeColor: const Color(0xFFFF8B66), // Orange
                          onTap: () {
                            _playPopSound();
                            context.push(Uri(path: '/look-and-match-game', queryParameters: {'bgmPath': 'audio/Sounds/feature bk sound.mp3'}).toString());
                          },
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
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
