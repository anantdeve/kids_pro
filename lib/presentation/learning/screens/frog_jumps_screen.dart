import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../../../core/providers/user_provider.dart';
import 'dart:math' as math;

class FrogJumpsScreen extends ConsumerStatefulWidget {
  const FrogJumpsScreen({super.key});

  @override
  ConsumerState<FrogJumpsScreen> createState() => _FrogJumpsScreenState();
}

class _FrogJumpsScreenState extends ConsumerState<FrogJumpsScreen> with TickerProviderStateMixin {
  int startNum = 3;
  int jumpAmount = 4;
  
  late int currentNum;
  int jumpsMade = 0;
  bool _showRainbow = false;

  late AnimationController _jumpController;
  late AnimationController _rippleController;
  late AnimationController _rainbowController;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    currentNum = startNum;

    // Start background music
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.play(AssetSource('audio/Sounds/feature bk sound.mp3'));

    // Jump Animation (Squash and Stretch + Parabola)
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    
    // Water Ripple Animation
    _rippleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

    // Rainbow Animation
    _rainbowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    
    // Confetti Controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _rippleController.dispose();
    _rainbowController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }

  void _makeJump() {
    if (jumpsMade < jumpAmount && !_jumpController.isAnimating) {
      _jumpController.forward(from: 0.0).then((_) {
        setState(() {
          currentNum++;
          jumpsMade++;
        });

        if (jumpsMade == jumpAmount) {
          _showWinState();
        }
      });
    }
  }

  void _showWinState() {
    setState(() => _showRainbow = true);
    _rainbowController.forward(from: 0.0);
    _confettiController.play();
    _audioPlayer.play(AssetSource('audio/Sounds/mixkit-fairy-arcade-sparkle-866.wav'));
    ref.read(userProvider.notifier).addPoints('FrogJumps', 20);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _rainbowController.reverse().then((_) {
          setState(() {
            _showRainbow = false;
            startNum = currentNum;
            jumpAmount = (currentNum % 3) + 2;
            jumpsMade = 0;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final mathsPoints = userState.value?.featurePoints['FrogJumps'] ?? 0;

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

          // Animated Water (bottom area)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WaterPainter(_rippleController.value),
                  child: Container(),
                );
              },
            ),
          ),

          // Rainbow Effect (Win State)
          if (_showRainbow)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rainbowController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _rainbowController.value,
                    child: CustomPaint(
                      painter: _RainbowPainter(),
                    ),
                  );
                },
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
                          'Frog Jumps',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
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

                // Equation
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Text(
                      '$startNum + $jumpAmount = ${jumpsMade == jumpAmount ? currentNum : "?"}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF4ECDC4)),
                    ),
                  ),
                ),

                const Spacer(),

                // Number Line & Frog Area
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // The Number Line
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                        ),
                      ),

                      // Animated Frog
                      AnimatedBuilder(
                        animation: _jumpController,
                        builder: (context, child) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final jumpWidth = (screenWidth - 80) / jumpAmount;
                          
                          // Base X position + animation X offset
                          final baseLeft = 20.0 + (jumpsMade * jumpWidth);
                          final animatedLeft = baseLeft + (_jumpController.value * jumpWidth);
                          
                          // Y position (Parabola for jump)
                          final jumpHeight = math.sin(_jumpController.value * math.pi) * 100;
                          final bottomPos = 50.0 + jumpHeight;

                          // Squash and Stretch
                          // When jumping (middle of animation), stretch vertically, squash horizontally
                          // When landing/taking off (start/end), squash vertically, stretch horizontally
                          double scaleX = 1.0;
                          double scaleY = 1.0;
                          
                          if (_jumpController.isAnimating) {
                            if (_jumpController.value < 0.2 || _jumpController.value > 0.8) {
                              // Taking off / Landing = Squash
                              scaleX = 1.2;
                              scaleY = 0.8;
                            } else {
                              // Mid-air = Stretch
                              scaleX = 0.9;
                              scaleY = 1.2;
                            }
                          } else if (jumpsMade == jumpAmount) {
                             // Victory bounce
                             scaleX = 1.0 + math.sin(DateTime.now().millisecondsSinceEpoch / 200) * 0.1;
                             scaleY = 1.0 - math.sin(DateTime.now().millisecondsSinceEpoch / 200) * 0.1;
                          }

                          return Positioned(
                            bottom: bottomPos,
                            left: _jumpController.isAnimating ? animatedLeft : baseLeft,
                            child: GestureDetector(
                              onTap: _makeJump,
                              child: Transform.scale(
                                scaleX: scaleX,
                                scaleY: scaleY,
                                child: _buildFrog(),
                              ),
                            ),
                          );
                        },
                      ),

                      // Current Number Indicator (Lily Pad)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        bottom: -10,
                        left: 30.0 + (jumpsMade * ((MediaQuery.of(context).size.width - 80) / jumpAmount)),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF84FAB0),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Center(
                            child: Text(
                              '$currentNum',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3142)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrog() {
    return Image.asset(
      'assets/images/cute_cartoon_frog.png',
      width: 80,
      height: 80,
      fit: BoxFit.contain,
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double animationValue;

  _WaterPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4FACFE).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 50);

    for (double i = 0; i <= size.width; i++) {
      // Create a moving sine wave
      final y = math.sin((i / 50) + (animationValue * 2 * math.pi)) * 10 + 50;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave layer
    final paint2 = Paint()
      ..color = const Color(0xFF00F2FE).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 70);

    for (double i = 0; i <= size.width; i++) {
      final y = math.cos((i / 60) + (animationValue * 2 * math.pi)) * 12 + 70;
      path2.lineTo(i, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2 + 100), width: size.width * 1.5, height: size.width * 1.5);
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20;

      // Draw arcs representing the rainbow
      canvas.drawArc(rect.deflate(i * 20.0), math.pi, math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
