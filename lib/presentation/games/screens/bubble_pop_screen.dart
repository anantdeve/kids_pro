import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';
import '../../learning/widgets/success_overlay.dart';

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({super.key});

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen> with TickerProviderStateMixin {
  final List<Bubble> bubbles = [];
  int score = 0;
  late Timer spawnTimer;
  late Timer updateTimer;
  final Random random = Random();
  double _elapsedTime = 0.0;

  @override
  void initState() {
    super.initState();
    _startSpawning();
    _startUpdating();
  }

  void _startSpawning() {
    spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (bubbles.length < 10) {
        _addBubble();
      }
    });
  }

  void _startUpdating() {
    updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || isGameOver) return;
      
      _elapsedTime += 0.016; // Increment elapsed time by 16ms
      
      // Starts slow (cos(0)=1 -> 1.25 - 0.75 = 0.5)
      // Gradually speeds up to fast (cos(pi)=-1 -> 1.25 + 0.75 = 2.0)
      // Then slows down again in a smooth wave.
      final double speedMultiplier = 1.25 - 0.75 * cos(_elapsedTime);

      setState(() {
        for (var i = bubbles.length - 1; i >= 0; i--) {
          bubbles[i].position = Offset(
            bubbles[i].position.dx + (bubbles[i].velocity.dx * speedMultiplier),
            bubbles[i].position.dy + (bubbles[i].velocity.dy * speedMultiplier),
          );

          // Check if bubble is missed (floats off screen)
          if (bubbles[i].position.dy < -100) {
            _handleGameOver();
            return;
          }
        }
      });
    });
  }

  bool isGameOver = false;
  bool _isGameOverState = false;

  void _handleGameOver() {
    setState(() {
      isGameOver = true;
      _isGameOverState = true;
    });
  }

  void _restartGame() {
    setState(() {
      score = 0;
      bubbles.clear();
      isGameOver = false;
      _elapsedTime = 0.0;
    });
  }

  void _addBubble() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    final Color color = [
      const Color(0xFF81D4FA), // Blue
      const Color(0xFFA5D6A7), // Green
      const Color(0xFFF48FB1), // Pink
    ][random.nextInt(3)];

    bubbles.add(Bubble(
      id: DateTime.now().millisecondsSinceEpoch,
      position: Offset(random.nextDouble() * (screenWidth - 80), screenHeight + 50),
      velocity: Offset(0, -(random.nextDouble() * 2 + 1.5)),
      color: color,
      size: 60 + random.nextDouble() * 30,
    ));
  }

  void _popBubble(int index) {
    setState(() {
      score++;
      bubbles.removeAt(index);
    });
    // Add pop effect here if desired
  }

  @override
  void dispose() {
    spawnTimer.cancel();
    updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bubble_pop_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFE3F2FD)),
            ),
          ),

          // Header
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildScoreRow(),
              ],
            ),
          ),

          // Bubbles
          ...bubbles.asMap().entries.map((entry) {
            final index = entry.key;
            final bubble = entry.value;
            return Positioned(
              left: bubble.position.dx,
              top: bubble.position.dy,
              child: GestureDetector(
                onTap: () => _popBubble(index),
                child: BubbleWidget(bubble: bubble),
              ),
            );
          }),
          SuccessOverlay(
            isVisible: _isGameOverState,
            showBadge: false,
            onFinished: () {
              setState(() {
                _isGameOverState = false;
                _restartGame();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.popWithSound(),
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D3142), size: 32),
          ),
          const Expanded(
            child: Text(
              'Bubble Pop! 🫧',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow() {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Score: $score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF8A65), // Orange
            ),
          ),
        ),
      ),
    );
  }
}

class Bubble {
  final int id;
  Offset position;
  final Offset velocity;
  final Color color;
  final double size;

  Bubble({
    required this.id,
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

class BubbleWidget extends StatelessWidget {
  final Bubble bubble;

  const BubbleWidget({super.key, required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bubble.size,
      height: bubble.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            bubble.color.withValues(alpha: 0.4),
            bubble.color.withValues(alpha: 0.7),
          ],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: bubble.color.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sparkles
          Positioned(
            top: bubble.size * 0.2,
            left: bubble.size * 0.2,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: bubble.size * 0.4,
            ),
          ),
          // Inner light
          Center(
            child: Container(
              width: bubble.size * 0.8,
              height: bubble.size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
