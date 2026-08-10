import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_pro/core/widgets/magical_blob.dart';
import 'dart:math';
import '../services/learning_tts_service.dart';
import '../widgets/tts_animated_speaker.dart';
import '../widgets/success_overlay.dart';
import '../../../core/providers/user_provider.dart';

enum PuzzlePart { top, bottom }

class PuzzlePieceData {
  final int number;
  final PuzzlePart part;
  PuzzlePieceData({required this.number, required this.part});
}

class NumberPuzzleGameScreen extends ConsumerStatefulWidget {
  const NumberPuzzleGameScreen({super.key});

  @override
  ConsumerState<NumberPuzzleGameScreen> createState() => _NumberPuzzleGameScreenState();
}

class _NumberPuzzleGameScreenState extends ConsumerState<NumberPuzzleGameScreen> with TickerProviderStateMixin {
  late final LearningTtsNotifier _ttsNotifier;
  bool _isMuted = false;
  bool _isFirstLoad = true;
  final Random random = Random();
  late int targetNumber;
  List<PuzzlePart> placedParts = [];
  List<PuzzlePart> availablePieces = [];
  bool isCompleted = false;
  bool _isSuccess = false;
  int _points = 0;

  late AnimationController _successController;
  late Animation<double> _successScale;

  final List<Color> themeColors = [
    const Color(0xFF5CD6A1), // Green
    const Color(0xFF67E1F5), // Blue
    const Color(0xFFFF7B9C), // Pink
    const Color(0xFFFFB347), // Orange
    const Color(0xFFB497FF), // Purple
  ];

  late Color currentThemeColor;

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(learningTtsServiceProvider.notifier);
    currentThemeColor = themeColors[0];
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeInOut));
    
    _generateLevel();
  }

  @override
  void dispose() {
    _successController.dispose();
    _ttsNotifier.stop();
    super.dispose();
  }

  void _generateLevel() {
    setState(() {
      targetNumber = random.nextInt(10);
      currentThemeColor = themeColors[random.nextInt(themeColors.length)];
      placedParts = [];
      availablePieces = [PuzzlePart.top, PuzzlePart.bottom];
      availablePieces.shuffle();
      isCompleted = false;
      _isSuccess = false;
    });
    _successController.reset();

    if (!_isMuted && _isFirstLoad) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Assemble the number $targetNumber');
      _isFirstLoad = false;
    }
  }

  void _onPartPlaced(PuzzlePart part) {
    setState(() {
      placedParts.add(part);
      if (placedParts.length == 2) {
        isCompleted = true;
        if (!_isMuted) {
          ref.read(learningTtsServiceProvider.notifier).playFeedback(targetNumber.toString());
        }
        _successController.forward();
        _showSuccessEffect();
      }
    });
  }

  void _showSuccessEffect() {
    setState(() {
      _isSuccess = true;
      _points += 50;
    });
    ref.read(userProvider.notifier).addPoints('Learning', 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with soft mesh gradient effect
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFFF9F5),
            ),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withValues(alpha: 0.4)),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withValues(alpha: 0.5)),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: MagicalBlob(size: 400, color: const Color(0xFFF3E5F5).withValues(alpha: 0.4)),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: MagicalBlob(size: 300, color: const Color(0xFFFFF9C4).withValues(alpha: 0.3)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(flex: 1),
                Text(
                  'Assemble the number $targetNumber',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C677D),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _successScale,
                  child: _buildAssemblyArea(),
                ),
                const Spacer(flex: 2),
                _buildPiecesArea(),
                const SizedBox(height: 60),
              ],
            ),
          ),
          // Success Overlay
          SuccessOverlay(
            isVisible: _isSuccess,
            lottieUrl: 'https://assets10.lottiefiles.com/packages/lf20_rovf9gzu.json', // Confetti 2
            onFinished: () {
              if (mounted) _generateLevel();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2D3142), size: 28),
            ),
          ),
          const SizedBox(width: 8),
          TtsAnimatedSpeaker(
            isMuted: _isMuted,
            color: const Color(0xFF2D3142),
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
                if (_isMuted) {
                  _ttsNotifier.stop();
                }
              });
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Number Puzzle',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF67E1F5).withValues(alpha: 0.9),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD166),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    '$_points',
                    key: ValueKey<int>(_points),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyArea() {
    return Container(
      width: 220,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          Expanded(child: _buildDropTarget(PuzzlePart.top)),
          Expanded(child: _buildDropTarget(PuzzlePart.bottom)),
        ],
      ),
    );
  }

  Widget _buildDropTarget(PuzzlePart part) {
    final bool isPlaced = placedParts.contains(part);

    return DragTarget<PuzzlePieceData>(
      onWillAcceptWithDetails: (details) => details.data.part == part && !isPlaced,
      onAcceptWithDetails: (details) => _onPartPlaced(part),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? currentThemeColor.withValues(alpha: 0.1) 
                : Colors.transparent,
            borderRadius: part == PuzzlePart.top 
                ? const BorderRadius.vertical(top: Radius.circular(36))
                : const BorderRadius.vertical(bottom: Radius.circular(36)),
          ),
          child: Center(
            child: isPlaced
                ? _buildNumberPart(targetNumber, part, size: 300, color: currentThemeColor)
                : Icon(
                    part == PuzzlePart.top ? Icons.add_circle_outline : Icons.add_circle_outline,
                    color: Colors.grey.withValues(alpha: 0.2),
                    size: 40,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPiecesArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: availablePieces.map((part) {
        final bool isPlaced = placedParts.contains(part);
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isPlaced ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: isPlaced,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Draggable<PuzzlePieceData>(
                data: PuzzlePieceData(number: targetNumber, part: part),
                feedback: _buildDraggablePiece(part, isFeedback: true),
                childWhenDragging: const SizedBox(width: 120, height: 120),
                child: _buildDraggablePiece(part),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDraggablePiece(PuzzlePart part, {bool isFeedback = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF86E3C1),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF86E3C1).withValues(alpha: isFeedback ? 0.4 : 0.2),
              blurRadius: isFeedback ? 20 : 10,
              offset: Offset(0, isFeedback ? 10 : 4),
            ),
          ],
        ),
        child: Center(
          child: _buildNumberPart(targetNumber, part, size: 120),
        ),
      ),
    );
  }

  Widget _buildNumberPart(int number, PuzzlePart part, {required double size, Color? color}) {
    // The 'size' is the full height of the number.
    // Each piece should be half that height.
    final double pieceHeight = size / 2;
    
    return SizedBox(
      width: size,
      height: pieceHeight,
      child: ClipRect(
        child: OverflowBox(
          alignment: part == PuzzlePart.top ? Alignment.topCenter : Alignment.bottomCenter,
          maxHeight: size,
          maxWidth: size,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: size * 0.9,
                  fontWeight: FontWeight.w900,
                  color: color ?? Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
