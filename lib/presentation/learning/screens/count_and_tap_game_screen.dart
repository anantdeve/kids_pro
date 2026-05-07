import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class CountAndTapGameScreen extends StatefulWidget {
  const CountAndTapGameScreen({super.key});

  @override
  State<CountAndTapGameScreen> createState() => _CountAndTapGameScreenState();
}

class _CountAndTapGameScreenState extends State<CountAndTapGameScreen> with TickerProviderStateMixin {
  final Random random = Random();
  late int targetNumber;
  int currentCount = 0;
  List<Offset> starPositions = [];
  Set<int> tappedStarIndices = {};

  @override
  void initState() {
    super.initState();
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      targetNumber = random.nextInt(5) + 3; // 3 to 7 for better spacing
      currentCount = 0;
      tappedStarIndices.clear();
      
      List<Offset> positions = [];
      int attempts = 0;
      while (positions.length < targetNumber + 2 && attempts < 100) {
        final newPos = Offset(
          0.15 + random.nextDouble() * 0.7,
          0.1 + random.nextDouble() * 0.75,
        );
        
        bool tooClose = false;
        for (var p in positions) {
          if ((p - newPos).distance < 0.2) {
            tooClose = true;
            break;
          }
        }
        
        if (!tooClose) {
          positions.add(newPos);
        }
        attempts++;
      }
      starPositions = positions;
    });
  }

  void _onStarTap(int index) {
    if (tappedStarIndices.contains(index)) return;
    if (currentCount >= targetNumber) return;

    setState(() {
      tappedStarIndices.add(index);
      currentCount++;
    });

    if (currentCount == targetNumber) {
      _showSuccessEffect();
    }
  }

  void _showSuccessEffect() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Great counting! 🌟'),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFF7B9C),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _generateLevel();
      });
    });
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
                              'Tap the stars to count!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF7B9C),
                                  Color(0xFFFFB6C1),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Count and Tap',
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

                const SizedBox(height: 20),

                // Progress Tracker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7B9C).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TAP $targetNumber STARS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$currentCount / $targetNumber',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF7B9C),
                        ),
                      ),
                    ],
                  ),
                ),

                // Star Field
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: starPositions.asMap().entries.map((entry) {
                          int idx = entry.key;
                          Offset pos = entry.value;
                          bool isTapped = tappedStarIndices.contains(idx);

                          return Positioned(
                            left: pos.dx * constraints.maxWidth - 40,
                            top: pos.dy * constraints.maxHeight - 40,
                            child: _FloatingStar(
                              isTapped: isTapped,
                              tappedIndex: isTapped 
                                  ? List.from(tappedStarIndices).indexOf(idx) + 1 
                                  : null,
                              onTap: () => _onStarTap(idx),
                              delay: idx * 200, // Staggered animation
                            ),
                          );
                        }).toList(),
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
}

class _FloatingStar extends StatefulWidget {
  final bool isTapped;
  final int? tappedIndex;
  final VoidCallback onTap;
  final int delay;

  const _FloatingStar({
    required this.isTapped,
    this.tappedIndex,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_FloatingStar> createState() => _FloatingStarState();
}

class _FloatingStarState extends State<_FloatingStar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _horizontalOffset;
  late Animation<double> _verticalOffset;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + Random().nextInt(2000)),
    );

    // Multi-directional orbital movement
    _horizontalOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 15).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 15, end: 0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
    ]).animate(_controller);

    _verticalOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: -10).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
    ]).animate(_controller);

    _rotation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
    ]).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isTapped 
              ? Offset.zero 
              : Offset(_horizontalOffset.value, _verticalOffset.value),
          child: Transform.rotate(
            angle: widget.isTapped ? 0 : _rotation.value,
            child: Transform.scale(
              scale: widget.isTapped ? 1.0 : _scale.value,
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.bounceOut,
                  width: widget.isTapped ? 100 : 80,
                  height: widget.isTapped ? 100 : 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isTapped 
                        ? const Color(0xFFFFD166) 
                        : Colors.white.withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isTapped ? const Color(0xFFFFD166) : Colors.white)
                            .withValues(alpha: 0.3),
                        blurRadius: widget.isTapped ? 20 : 10,
                        spreadRadius: widget.isTapped ? 5 : 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '⭐',
                        style: TextStyle(
                          fontSize: widget.isTapped ? 50 : 40,
                          color: widget.isTapped ? Colors.white : Colors.amber.shade200,
                        ),
                      ),
                      if (widget.isTapped)
                        Text(
                          '${widget.tappedIndex}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
