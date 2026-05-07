import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math';

class AlphabetSurpriseScreen extends StatefulWidget {
  const AlphabetSurpriseScreen({super.key});

  @override
  State<AlphabetSurpriseScreen> createState() => _AlphabetSurpriseScreenState();
}

class _AlphabetSurpriseScreenState extends State<AlphabetSurpriseScreen> with TickerProviderStateMixin {
  late String currentLetter;
  final List<String> alphabets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  final Random random = Random();
  
  int? revealedBoxIndex;
  bool isDragging = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _openingController;
  late Animation<double> _lidOffsetAnimation;
  late Animation<double> _boxShakeAnimation;
  late Animation<double> _revealScaleAnimation;

  @override
  void initState() {
    super.initState();
    _generateNextLetter();
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _openingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _lidOffsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -40).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: -40, end: -20).chain(CurveTween(curve: Curves.bounceOut)), weight: 60),
    ]).animate(_openingController);

    _boxShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: -5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: 0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _openingController,
      curve: const Interval(0.0, 0.4, curve: Curves.linear),
    ));

    _revealScaleAnimation = CurvedAnimation(
      parent: _openingController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _openingController.dispose();
    super.dispose();
  }

  void _generateNextLetter() {
    setState(() {
      currentLetter = alphabets[random.nextInt(alphabets.length)];
      revealedBoxIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(color: const Color(0xFFFFF9F5)),
          ),
          _buildBlurredBlob(300, const Color(0xFFFFD1E1).withValues(alpha: 0.4), top: 100, left: -50),
          _buildBlurredBlob(350, const Color(0xFFE1F5FE).withValues(alpha: 0.5), top: -50, right: -50),
          _buildBlurredBlob(400, const Color(0xFFF3E5F5).withValues(alpha: 0.4), bottom: 100, right: -80),
          _buildBlurredBlob(300, const Color(0xFFFFF9C4).withValues(alpha: 0.3), bottom: -50, left: -20),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(flex: 1),
                
                // Gift Boxes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGiftBox(0, const Color(0xFF4FC3F7), 0), // Light Blue
                      _buildGiftBox(1, const Color(0xFFF48FB1), -60), // Pink (Higher)
                      _buildGiftBox(2, const Color(0xFFB39DDB), 0), // Light Purple
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Draggable Letter
                _buildDraggableLetter(),
                
                const SizedBox(height: 20),
                
                // Drag Me Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0D0).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Drag Me! ✨',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7043),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: const Text(
                'Alphabet Surprise 📦✨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftBox(int index, Color color, double yOffset) {
    bool isRevealed = revealedBoxIndex == index;
    
    return Flexible(
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => revealedBoxIndex == null,
        onAcceptWithDetails: (details) {
          setState(() {
            revealedBoxIndex = index;
          });
          _openingController.forward(from: 0);
          _showSurprise();
        },
        builder: (context, candidateData, rejectedData) {
          return Transform.translate(
            offset: Offset(0, yOffset),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return AnimatedBuilder(
                  animation: _openingController,
                  builder: (context, child) {
                    final double boxWidth = min(boxConstraints.maxWidth, 80.0);
                    final double lidWidth = boxWidth * 1.2;
                    final double shake = isRevealed ? _boxShakeAnimation.value : 0;
                    
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Box Body
                          Container(
                            width: boxWidth,
                            height: boxWidth * 1.1,
                            margin: const EdgeInsets.only(top: 25),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Vertical Ribbon
                                Container(width: 10, color: const Color(0xFFFF1744)),
                                if (isRevealed)
                                  Transform.scale(
                                    scale: _revealScaleAnimation.value,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Sparkle background
                                        ...List.generate(6, (i) {
                                          final angle = (i * 60) * pi / 180;
                                          return Transform.translate(
                                            offset: Offset(cos(angle) * 30 * _openingController.value, sin(angle) * 30 * _openingController.value),
                                            child: Icon(Icons.star_rounded, color: Colors.yellow, size: 15 * _openingController.value),
                                          );
                                        }),
                                        Text(
                                          currentLetter,
                                          style: TextStyle(
                                            fontSize: boxWidth * 0.6,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Box Lid
                          Positioned(
                            top: 15 + (isRevealed ? _lidOffsetAnimation.value : 0),
                            child: Transform.rotate(
                              angle: isRevealed ? _openingController.value * 0.2 : 0,
                              child: Container(
                                width: lidWidth,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  // Horizontal Ribbon on Lid
                                  child: Container(height: 10, color: const Color(0xFFFF1744)),
                                ),
                              ),
                            ),
                          ),
                          // Bow
                          Positioned(
                            top: -5 + (isRevealed ? _lidOffsetAnimation.value : 0),
                            child: Transform.rotate(
                              angle: isRevealed ? _openingController.value * 0.2 : 0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.rotate(angle: -0.5, child: const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 25)),
                                      Transform.rotate(angle: 0.5, child: const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 25)),
                                    ],
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(color: Color(0xFFFF1744), shape: BoxShape.circle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableLetter() {
    if (revealedBoxIndex != null) return const SizedBox(height: 100);

    return Draggable<String>(
      data: currentLetter,
      feedback: _buildLetterCircle(currentLetter, isFeedback: true),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildLetterCircle(currentLetter),
      ),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: _buildLetterCircle(currentLetter),
          );
        },
      ),
    );
  }

  Widget _buildLetterCircle(String letter, {bool isFeedback = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFFFAB91),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFAB91).withValues(alpha: 0.4),
              blurRadius: isFeedback ? 20 : 10,
              offset: Offset(0, isFeedback ? 10 : 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showSurprise() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _openingController.reverse().then((_) {
          _generateNextLetter();
        });
      }
    });
  }

  Widget _buildBlurredBlob(double size, Color color, {double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
