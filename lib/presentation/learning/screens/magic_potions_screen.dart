import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/providers/user_provider.dart';
import 'dart:math' as math;

class MagicPotionsScreen extends ConsumerStatefulWidget {
  const MagicPotionsScreen({super.key});

  @override
  ConsumerState<MagicPotionsScreen> createState() => _MagicPotionsScreenState();
}

class _MagicPotionsScreenState extends ConsumerState<MagicPotionsScreen> with TickerProviderStateMixin {
  int num1 = 0;
  int num2 = 0;
  int get correctAnswer => num1 + num2;
  
  List<int> options = [];

  late ConfettiController _confettiController;
  late AnimationController _bubbleController;
  late AnimationController _smokeController;
  late AnimationController _shakeController;

  bool _isHovering = false;
  final AudioPlayer _bgmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // Start background music
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.play(AssetSource('audio/Sounds/feature bk sound.mp3'));

    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1500));
    
    // Continuous bubbling effect
    _bubbleController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    // Continuous smoke effect
    _smokeController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    // Shake for wrong answer
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _generateEquation();
  }

  void _generateEquation() {
    final random = math.Random();
    num1 = random.nextInt(6) + 1;
    num2 = random.nextInt(6) + 1;
    
    options = [
      correctAnswer,
      correctAnswer + random.nextInt(3) + 1,
      math.max(1, correctAnswer - random.nextInt(3) - 1),
    ];
    options.shuffle();
  }

  void _shakeCauldron() {
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bubbleController.dispose();
    _smokeController.dispose();
    _shakeController.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final mathsPoints = userState.value?.featurePoints['MagicPotions'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark magical background
      body: Stack(
        children: [
          // Background Gradient (Dark magical theme)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
              ),
            ),
          ),

          // Floating Sparkles
          _buildSparkles(),

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
                          'Magic Potions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [Shadow(color: Color(0xFF8C52FF), blurRadius: 10, offset: Offset(0, 0))],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Equation Scroll / Spellbook
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8DC), // Parchment color
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFF6D365).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 0)),
                      ],
                      border: Border.all(color: const Color(0xFFDEB887), width: 4),
                    ),
                    child: Text(
                      'Recipe: $num1 + $num2',
                      style: const TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        color: Color(0xFF5C4033),
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Potion Shelf
                Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF8B4513), width: 10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: options.map((option) {
                      return Draggable<int>(
                        data: option,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _GlowingPotion(number: option, isDragging: true),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _GlowingPotion(number: option),
                        ),
                        child: _GlowingPotion(number: option),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                // Cauldron
                DragTarget<int>(
                  onWillAcceptWithDetails: (details) {
                    setState(() => _isHovering = true);
                    return true;
                  },
                  onLeave: (data) {
                    setState(() => _isHovering = false);
                  },
                  onAcceptWithDetails: (details) {
                    setState(() => _isHovering = false);
                    if (details.data == correctAnswer) {
                      _confettiController.play();
                      ref.read(userProvider.notifier).addPoints('MagicPotions', 15);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _generateEquation());
                      });
                    } else {
                      _shakeCauldron();
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
                      child: _BubblingCauldron(
                        bubbleAnimation: _bubbleController,
                        smokeAnimation: _smokeController,
                        isHovering: _isHovering,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // Confetti for correct answers
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.purple, Colors.blue, Colors.green, Colors.pink, Colors.yellow],
              numberOfParticles: 50,
              maxBlastForce: 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkles() {
    return Stack(
      children: List.generate(20, (index) {
        return Positioned(
          left: math.Random().nextDouble() * 400,
          top: math.Random().nextDouble() * 800,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1500 + math.Random().nextInt(2000)),
            builder: (context, val, child) {
              return Opacity(
                opacity: math.sin(val * math.pi),
                child: const Icon(Icons.star_rounded, color: Color(0xFFF6D365), size: 10),
              );
            },
            onEnd: () {},
          ),
        );
      }),
    );
  }
}

class _GlowingPotion extends StatefulWidget {
  final int number;
  final bool isDragging;

  const _GlowingPotion({required this.number, this.isDragging = false});

  @override
  State<_GlowingPotion> createState() => _GlowingPotionState();
}

class _GlowingPotionState extends State<_GlowingPotion> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final Color _potionColor = Colors.primaries[math.Random().nextInt(Colors.primaries.length)].shade400;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isDragging ? 120.0 : 80.0;
    
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: size,
          height: size * 1.5,
          decoration: BoxDecoration(
            color: _potionColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size / 2),
              topRight: Radius.circular(size / 2),
              bottomLeft: Radius.circular(size / 4),
              bottomRight: Radius.circular(size / 4),
            ),
            boxShadow: [
              BoxShadow(
                color: _potionColor.withValues(alpha: widget.isDragging ? 0.8 : _glowController.value * 0.5),
                blurRadius: widget.isDragging ? 30 : 15,
                spreadRadius: widget.isDragging ? 5 : 0,
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
          ),
          child: Column(
            children: [
              // Cork
              Container(
                width: size * 0.3,
                height: size * 0.2,
                color: const Color(0xFF8B4513),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      '${widget.number}',
                      style: TextStyle(
                        fontSize: widget.isDragging ? 36 : 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BubblingCauldron extends StatelessWidget {
  final Animation<double> bubbleAnimation;
  final Animation<double> smokeAnimation;
  final bool isHovering;

  const _BubblingCauldron({
    required this.bubbleAnimation,
    required this.smokeAnimation,
    required this.isHovering,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Smoke particles
          AnimatedBuilder(
            animation: smokeAnimation,
            builder: (context, child) {
              return Stack(
                children: List.generate(5, (index) {
                  final offset = (smokeAnimation.value + (index / 5)) % 1.0;
                  final xMovement = math.sin(offset * math.pi * 2) * 20;
                  return Positioned(
                    bottom: 120 + (offset * 100),
                    left: 100 + xMovement,
                    child: Opacity(
                      opacity: (1.0 - offset) * 0.5,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 5)],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          
          // Liquid inside cauldron
          Positioned(
            top: 60,
            child: AnimatedBuilder(
              animation: bubbleAnimation,
              builder: (context, child) {
                return Container(
                  width: 180,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isHovering ? const Color(0xFF00FF87) : const Color(0xFF8C52FF),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: (isHovering ? const Color(0xFF00FF87) : const Color(0xFF8C52FF)).withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Cauldron Body
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(100), top: Radius.circular(20)),
              border: Border.all(color: const Color(0xFF3A3A3A), width: 5),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
          ),
          
          // Cauldron Rim
          Positioned(
            top: 90,
            child: Container(
              width: 220,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4A4A4A), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
