import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import 'dart:math' as math;

class FeedTheMonsterScreen extends ConsumerStatefulWidget {
  const FeedTheMonsterScreen({super.key});

  @override
  ConsumerState<FeedTheMonsterScreen> createState() => _FeedTheMonsterScreenState();
}

class _FeedTheMonsterScreenState extends ConsumerState<FeedTheMonsterScreen> with TickerProviderStateMixin {
  int num1 = 3;
  int num2 = 2;
  int get correctAnswer => num1 + num2;
  
  List<int> options = [4, 5, 6];
  int? _droppedAnswer;

  // Animations
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _blinkController;
  late AnimationController _eyeMovementController;

  bool _isMouthOpen = false;
  double _eyeOffsetX = 0;
  double _eyeOffsetY = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Shake Animation (Wrong Answer)
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    
    // Blink Animation
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _startRandomBlinking();

    // Eye Movement Animation
    _eyeMovementController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _eyeMovementController.addListener(() {
      setState(() {
        _eyeOffsetX = math.sin(_eyeMovementController.value * math.pi * 2) * 5;
        _eyeOffsetY = math.cos(_eyeMovementController.value * math.pi) * 3;
      });
    });
  }

  void _startRandomBlinking() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 2 + math.Random().nextInt(4)));
      if (mounted) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }
    }
  }

  void _shakeMonster() {
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _blinkController.dispose();
    _eyeMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final mathsPoints = userState.value?.featurePoints['FeedMonster'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFDDF6FF), // Sky blue
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8FD3FF), Color(0xFFDDF6FF)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Feed the Monster',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                            const SizedBox(width: 4),
                            Text(
                              '$mathsPoints',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Equation
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final shake = math.sin(_shakeController.value * math.pi * 4) * 10;
                          return Transform.translate(
                            offset: Offset(shake, 0),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Text(
                            '$num1 + $num2 = ${_droppedAnswer ?? "?"}',
                            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFFFF7B9C)),
                          ),
                        ),
                      ),
                      
                      // Monster
                      DragTarget<int>(
                        onWillAcceptWithDetails: (details) {
                          setState(() => _isMouthOpen = true);
                          return true;
                        },
                        onLeave: (data) {
                          setState(() => _isMouthOpen = false);
                        },
                        onAcceptWithDetails: (details) {
                          if (details.data == correctAnswer) {
                            setState(() {
                              _isMouthOpen = false;
                              _droppedAnswer = details.data;
                              options.remove(details.data);
                            });
                            _confettiController.play();
                            ref.read(userProvider.notifier).addPoints('FeedMonster', 10);
                            // Next level
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  num1 = math.Random().nextInt(5) + 1;
                                  num2 = math.Random().nextInt(5) + 1;
                                  _droppedAnswer = null;
                                  options = [correctAnswer - 1, correctAnswer, correctAnswer + 1];
                                  if (options.contains(0)) {
                                    options = [1, 2, 3];
                                  }
                                  options.shuffle();
                                });
                              }
                            });
                          } else {
                            setState(() => _isMouthOpen = false);
                            _shakeMonster();
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final shake = math.sin(_shakeController.value * math.pi * 4) * 10;
                              return Transform.translate(
                                offset: Offset(shake, 0),
                                child: child,
                              );
                            },
                            child: _buildMonster(),
                          );
                        },
                      ),

                      // Food Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: options.map((option) {
                          return Draggable<int>(
                            data: option,
                            onDragStarted: () {
                              // Optional: trigger mouth slightly open when they start dragging anything
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildFoodItem(option, isDragging: true),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildFoodItem(option),
                            ),
                            child: _buildFoodItem(option),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              createParticlePath: drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonster() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 200,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF4FACFE), // Blue monster
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4FACFE).withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Eyes
            Positioned(
              top: 50,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEye(),
                  const SizedBox(width: 20),
                  _buildEye(),
                ],
              ),
            ),
            // Mouth
            Positioned(
              bottom: 40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: _isMouthOpen ? 120 : 80,
                height: _isMouthOpen ? 80 : 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3142), // Dark mouth interior
                  borderRadius: BorderRadius.circular(_isMouthOpen ? 40 : 10),
                ),
                child: _isMouthOpen
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Teeth top
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) => _buildTooth(isTop: true)),
                          ),
                          // Tongue
                          Container(
                            width: 60,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7B9C),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                          ),
                        ],
                      )
                    : null, // Closed mouth
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEye() {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final heightScale = 1.0 - _blinkController.value; // 1.0 = open, 0.0 = closed
        return Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Transform.scale(
            scaleY: math.max(heightScale, 0.1),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(_eyeOffsetX, _eyeOffsetY),
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTooth({required bool isTop}) {
    return Container(
      width: 12,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isTop ? const BorderRadius.vertical(bottom: Radius.circular(10)) : const BorderRadius.vertical(top: Radius.circular(10)),
      ),
    );
  }

  Widget _buildFoodItem(int number, {bool isDragging = false}) {
    // A cute bouncy food item (like a colorful rounded box or cookie)
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: isDragging ? 100 : 80,
        height: isDragging ? 100 : 80,
        decoration: BoxDecoration(
          color: const Color(0xFFFFB74D), // Orange cookie color
          borderRadius: BorderRadius.circular(isDragging ? 50 : 30), // Becomes round when dragged
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDragging ? 0.3 : 0.1),
              blurRadius: isDragging ? 15 : 8,
              offset: Offset(0, isDragging ? 10 : 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: isDragging ? 48 : 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }

  /// A custom Path to paint stars for the confetti
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
