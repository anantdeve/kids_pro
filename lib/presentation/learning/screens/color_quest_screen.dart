import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/success_overlay.dart';

class ColorQuestScreen extends StatefulWidget {
  const ColorQuestScreen({super.key});

  @override
  State<ColorQuestScreen> createState() => _ColorQuestScreenState();
}

class _ColorQuestScreenState extends State<ColorQuestScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool _isMuted = false;
  final List<GameColor> allColors = [
    GameColor(name: 'YELLOW', color: const Color(0xFFFFD166)),
    GameColor(name: 'PINK', color: const Color(0xFFFF7B9C)),
    GameColor(name: 'GREEN', color: const Color(0xFF5CD6A1)),
    GameColor(name: 'ORANGE', color: const Color(0xFFFF8B66)),
    GameColor(name: 'BLUE', color: const Color(0xFF67E1F5)),
    GameColor(name: 'PURPLE', color: const Color(0xFFB497FF)),
  ];

  final Random random = Random();
  int level = 1;
  late GameColor targetColor;
  late List<GameColor> options;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? _lastTappedName;
  bool _isSuccess = false;
  GameColor? _lastTargetColor;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

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
    
    // Automatically speak the target color when a new level is generated
    if (!_isMuted) {
      flutterTts.speak('Tap the ${targetColor.name.toLowerCase()}');
    }
  }

  void _onColorTap(GameColor tappedColor) {
    setState(() => _lastTappedName = tappedColor.name);
    
    if (tappedColor.name == targetColor.name) {
      if (!_isMuted) {
        flutterTts.speak(tappedColor.name.toLowerCase());
      }
      _showSuccessEffect();
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _showSuccessEffect() {
    setState(() {
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          if (Theme.of(context).brightness == Brightness.light)
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
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              'COLOR QUEST',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF4A4A4A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                              if (_isMuted) {
                                flutterTts.stop();
                              }
                            });
                          },
                          icon: Icon(
                            _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black87,
                          ),
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
                  child: GestureDetector(
                    onTap: () {
                      if (!_isMuted) {
                        flutterTts.speak('Tap the ${targetColor.name.toLowerCase()}');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? Colors.white,
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
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey[600],
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
                              border: Border.all(color: Theme.of(context).cardTheme.color ?? Colors.white, width: 8),
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
          SuccessOverlay(
            isVisible: _isSuccess,
            onFinished: () {
              setState(() {
                _isSuccess = false;
                _generateNewLevel();
              });
            },
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
