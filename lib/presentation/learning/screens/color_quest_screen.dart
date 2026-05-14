import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class ColorQuestScreen extends StatefulWidget {
  const ColorQuestScreen({super.key});

  @override
  State<ColorQuestScreen> createState() => _ColorQuestScreenState();
}

class _ColorQuestScreenState extends State<ColorQuestScreen> with TickerProviderStateMixin {
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
  
  late AnimationController _shakeController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  
  String? _lastTappedName;
  GameColor? _lastTargetColor;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _generateNewLevel();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _generateNewLevel() {
    setState(() {
      // Pick a new color that is not the same as the last one
      final availableColors = allColors.where((c) => c.name != _lastTargetColor?.name).toList();
      targetColor = availableColors[random.nextInt(availableColors.length)];
      _lastTargetColor = targetColor;
      
      // Get 3 other unique colors for options
      final otherColors = allColors.where((c) => c.name != targetColor.name).toList();
      otherColors.shuffle();
      
      options = [targetColor, ...otherColors.take(3)];
      options.shuffle();
    });
  }

  void _onColorTap(GameColor tappedColor) {
    setState(() => _lastTappedName = tappedColor.name);
    
    if (tappedColor.name == targetColor.name) {
      _showSuccessEffect();
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _showSuccessEffect() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌟', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text(
                  'BRILLIANT!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFB6C1),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _generateNewLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF67E1F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('NEXT LEVEL', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
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

          // Animated Bubbles
          ...List.generate(5, (index) {
            return Positioned(
              left: random.nextDouble() * 300,
              top: random.nextDouble() * 600,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin((_floatController.value + index) * pi) * 20,
                      cos((_floatController.value + index) * pi) * 20,
                    ),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 100 + (index * 20),
                        height: 100 + (index * 20),
                        decoration: BoxDecoration(
                          color: allColors[index % allColors.length].color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

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
                              'Level up your streak!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'COLOR QUEST',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A4A4A),
                                letterSpacing: -0.5,
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
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
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
                            fontSize: 48, // Reduced from 60
                            fontWeight: FontWeight.w900,
                            color: targetColor.color,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
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
                        child: AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            double offset = 0;
                            if (_lastTappedName == item.name && item.name != targetColor.name) {
                              offset = sin(_shakeController.value * 4 * pi) * 10;
                            }
                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },
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
