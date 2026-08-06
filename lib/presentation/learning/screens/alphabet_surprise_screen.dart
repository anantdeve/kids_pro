import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../../../core/widgets/magical_blob.dart';
import '../../../core/providers/user_provider.dart';

class AlphabetSurpriseScreen extends ConsumerStatefulWidget {
  const AlphabetSurpriseScreen({super.key});

  @override
  ConsumerState<AlphabetSurpriseScreen> createState() => _AlphabetSurpriseScreenState();
}

class _AlphabetSurpriseScreenState extends ConsumerState<AlphabetSurpriseScreen> with TickerProviderStateMixin {
  late String currentLetter;
  final List<String> alphabets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  final Random random = Random();
  
  final Map<String, Map<String, String>> surpriseData = {
    'A': {'emoji': '🍎', 'name': 'Apple'},
    'B': {'emoji': '🐻', 'name': 'Bear'},
    'C': {'emoji': '🐱', 'name': 'Cat'},
    'D': {'emoji': '🐶', 'name': 'Dog'},
    'E': {'emoji': '🐘', 'name': 'Elephant'},
    'F': {'emoji': '🐟', 'name': 'Fish'},
    'G': {'emoji': '🍇', 'name': 'Grapes'},
    'H': {'emoji': '🐴', 'name': 'Horse'},
    'I': {'emoji': '🍦', 'name': 'Ice Cream'},
    'J': {'emoji': '🍹', 'name': 'Juice'},
    'K': {'emoji': '🪁', 'name': 'Kite'},
    'L': {'emoji': '🦁', 'name': 'Lion'},
    'M': {'emoji': '🐒', 'name': 'Monkey'},
    'N': {'emoji': '🪹', 'name': 'Nest'},
    'O': {'emoji': '🍊', 'name': 'Orange'},
    'P': {'emoji': '🐧', 'name': 'Penguin'},
    'Q': {'emoji': '👸', 'name': 'Queen'},
    'R': {'emoji': '🐰', 'name': 'Rabbit'},
    'S': {'emoji': '☀️', 'name': 'Sun'},
    'T': {'emoji': '🐯', 'name': 'Tiger'},
    'U': {'emoji': '☂️', 'name': 'Umbrella'},
    'V': {'emoji': '🎻', 'name': 'Violin'},
    'W': {'emoji': '🐳', 'name': 'Whale'},
    'X': {'emoji': '🪘', 'name': 'Xylophone'},
    'Y': {'emoji': '⛵', 'name': 'Yacht'},
    'Z': {'emoji': '🦓', 'name': 'Zebra'},
  };

  int? revealedBoxIndex;
  int winningBoxIndex = 0;
  bool isDragging = false;
  bool _isBigReveal = false;
  int sessionScore = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _openingController;
  late Animation<double> _lidOffsetAnimation;
  late Animation<double> _boxShakeAnimation;
  late Animation<double> _boxBodySlideAnimation;
  
  late AnimationController _bigRevealController;
  late Animation<double> _bigRevealScale;

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
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -60).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: -60, end: -40).chain(CurveTween(curve: Curves.bounceOut)), weight: 60),
    ]).animate(_openingController);

    _boxShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: -5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: 0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _openingController,
      curve: const Interval(0.0, 0.3, curve: Curves.linear),
    ));

    _boxBodySlideAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 15).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 15, end: 0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _openingController,
      curve: const Interval(0.0, 0.5, curve: Curves.linear),
    ));

    _bigRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bigRevealScale = CurvedAnimation(
      parent: _bigRevealController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _openingController.dispose();
    _bigRevealController.dispose();
    super.dispose();
  }

  void _generateNextLetter() {
    setState(() {
      currentLetter = alphabets[random.nextInt(alphabets.length)];
      revealedBoxIndex = null;
      _isBigReveal = false;
      winningBoxIndex = random.nextInt(3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFFFF9F5),
      body: Stack(
        children: [
          // Background
          if (Theme.of(context).brightness == Brightness.light) ...[
            Positioned.fill(
              child: Container(color: const Color(0xFFFFF9F5)),
            ),
            MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withValues(alpha: 0.4), top: 100, left: -50),
            MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withValues(alpha: 0.5), top: -50, right: -50),
            MagicalBlob(size: 400, color: const Color(0xFFF3E5F5).withValues(alpha: 0.4), bottom: 100, right: -80),
            MagicalBlob(size: 300, color: const Color(0xFFFFF9C4).withValues(alpha: 0.3), bottom: -50, left: -20),
          ],

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(flex: 3),
                
                // Gift Boxes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGiftBox(0, const Color(0xFF4FC3F7), 0), // Light Blue
                      _buildGiftBox(1, const Color(0xFFF48FB1), -40), // Pink (Higher)
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
                    color: Theme.of(context).cardTheme.color ?? const Color(0xFFFFE0D0).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Drag Me! ✨',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFF8B66) : const Color(0xFFFF7043),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Big Central Reveal Overlay
          if (_isBigReveal) _buildBigRevealOverlay(),

          // Confetti / Success Overlay
          SuccessOverlay(
            isVisible: _isBigReveal,
            showBadge: false,
            onFinished: () {}, // Handled by _showSurprise
          ),
        ],
      ),
    );
  }

  Widget _buildBigRevealOverlay() {
    final item = surpriseData[currentLetter]!;
    
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: ScaleTransition(
              scale: _bigRevealScale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Giant Sticker Object
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).cardTheme.color ?? Colors.white, width: 8),
                      boxShadow: [
                        BoxShadow(color: (Theme.of(context).cardTheme.color ?? Colors.white).withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 10),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          item['emoji']!,
                          style: const TextStyle(fontSize: 120),
                        ),
                        // Corner Letter
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7043),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              currentLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // "E is for Elephant" Giant Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$currentLetter is for',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF757575),
                          ),
                        ),
                        Text(
                          item['name']!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142),
                            letterSpacing: 2,
                          ),
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
                color: Theme.of(context).cardTheme.color ?? const Color(0xFFFFF5F0).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Alphabet Surprise 📦✨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9F1C).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  sessionScore.toString(),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 16,
                  ),
                ),
              ],
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
          if (index == winningBoxIndex) {
            setState(() {
              revealedBoxIndex = index;
              _isBigReveal = true;
              sessionScore += 10;
            });
            ref.read(userProvider.notifier).addPoints('Learning', 10);
            _openingController.forward(from: 0);
            _bigRevealController.forward(from: 0);
            _showSurprise();
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Transform.translate(
            offset: Offset(0, yOffset),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return AnimatedBuilder(
                  animation: _openingController,
                  builder: (context, child) {
                    final double boxWidth = min(boxConstraints.maxWidth, 85.0);
                    final double lidWidth = boxWidth * 1.2;
                    final double shake = isRevealed ? _boxShakeAnimation.value : 0;
                    final double boxSlide = isRevealed ? _boxBodySlideAnimation.value : 0;
                    
                    return Transform.translate(
                      offset: Offset(shake, boxSlide),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // 1. BOX BODY
                          Container(
                            width: boxWidth,
                            height: boxWidth * 1.1,
                            margin: const EdgeInsets.only(top: 25),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Vertical Ribbon
                                Container(width: 12, color: const Color(0xFFFF1744).withValues(alpha: 0.8)),
                              ],
                            ),
                          ),

                          // 2. BOX LID
                          Positioned(
                            top: 15 + (isRevealed ? _lidOffsetAnimation.value : 0),
                            child: Transform.rotate(
                              angle: isRevealed ? _openingController.value * 0.3 : 0,
                              child: Container(
                                width: lidWidth,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Center(
                                  // Horizontal Ribbon on Lid
                                  child: Container(height: 12, color: const Color(0xFFFF1744).withValues(alpha: 0.8)),
                                ),
                              ),
                            ),
                          ),

                          // 3. BOW
                          Positioned(
                            top: -5 + (isRevealed ? _lidOffsetAnimation.value : 0),
                            child: Transform.rotate(
                              angle: isRevealed ? _openingController.value * 0.3 : 0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.rotate(angle: -0.5, child: const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 28)),
                                      Transform.rotate(angle: 0.5, child: const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 28)),
                                    ],
                                  ),
                                  Container(
                                    width: 12,
                                    height: 12,
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
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFFFAB91),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFAB91).withValues(alpha: 0.4),
              blurRadius: isFeedback ? 25 : 15,
              offset: Offset(0, isFeedback ? 12 : 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 65,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showSurprise() {
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _openingController.reverse();
        _bigRevealController.reverse().then((_) {
          _generateNextLetter();
        });
      }
    });
  }

}
