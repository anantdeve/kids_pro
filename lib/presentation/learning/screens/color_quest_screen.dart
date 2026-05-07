import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class ColorQuestScreen extends StatefulWidget {
  const ColorQuestScreen({super.key});

  @override
  State<ColorQuestScreen> createState() => _ColorQuestScreenState();
}

class _ColorQuestScreenState extends State<ColorQuestScreen> {
  final List<GameColor> allColors = [
    GameColor(name: 'YELLOW', color: const Color(0xFFFFD166)),
    GameColor(name: 'PINK', color: const Color(0xFFFF7B9C)),
    GameColor(name: 'GREEN', color: const Color(0xFF5CD6A1)),
    GameColor(name: 'ORANGE', color: const Color(0xFFFF8B66)),
    GameColor(name: 'BLUE', color: const Color(0xFF67E1F5)),
    GameColor(name: 'PURPLE', color: const Color(0xFFB497FF)),
  ];

  late GameColor targetColor;
  late List<GameColor> options;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewLevel();
  }

  void _generateNewLevel() {
    setState(() {
      targetColor = allColors[random.nextInt(allColors.length)];
      
      // Get 3 other unique colors
      final otherColors = allColors.where((c) => c.name != targetColor.name).toList();
      otherColors.shuffle();
      
      options = [targetColor, ...otherColors.take(3)];
      options.shuffle();
    });
  }

  void _onColorTap(GameColor tappedColor) {
    if (tappedColor.name == targetColor.name) {
      // Success! Show a quick animation or just new level
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Awesome! 🌟'),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: targetColor.color,
        ),
      );
      _generateNewLevel();
    } else {
      // Wrong! Maybe a shake effect (TODO)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Try again! 😊'),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find the magic color!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF8B66),
                                  Color(0xFFFFB6C1),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'COLOR QUEST',
                                style: TextStyle(
                                  fontSize: 28,
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

                const Spacer(),

                // Target Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: targetColor.color.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tap the',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        targetColor.name,
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: targetColor.color,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Color Options Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      return GestureDetector(
                        onTap: () => _onColorTap(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 8),
                            boxShadow: [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameColor {
  final String name;
  final Color color;
  GameColor({required this.name, required this.color});
}
