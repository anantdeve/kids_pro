import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';
import '../widgets/tts_animated_speaker.dart';

class LookAndMatchGameScreen extends ConsumerStatefulWidget {
  final String bgmPath;
  const LookAndMatchGameScreen({super.key, this.bgmPath = 'audio/Sounds/feature bk sound.mp3'});

  @override
  ConsumerState<LookAndMatchGameScreen> createState() => _LookAndMatchGameScreenState();
}

class _LookAndMatchGameScreenState extends ConsumerState<LookAndMatchGameScreen> {
  late final LearningTtsNotifier _ttsNotifier;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;
  bool _isFirstLoad = true;
  late List<MatchItem> leftItems;
  late List<MatchItem> rightItems;

  final List<MatchItem> allItems = [
    MatchItem(id: 1, text: 'ONE', digit: '1', color: const Color(0xFF1E88E5)),
    MatchItem(id: 2, text: 'TWO', digit: '2', color: const Color(0xFFFF1EAD)),
    MatchItem(id: 3, text: 'THREE', digit: '3', color: const Color(0xFF4CAF50)),
    MatchItem(id: 4, text: 'FOUR', digit: '4', color: const Color(0xFFE91E63)),
    MatchItem(id: 5, text: 'FIVE', digit: '5', color: const Color(0xFFFF9800)),
    MatchItem(id: 6, text: 'SIX', digit: '6', color: const Color(0xFF00BCD4)),
    MatchItem(id: 7, text: 'SEVEN', digit: '7', color: const Color(0xFFFF5722)),
    MatchItem(id: 8, text: 'EIGHT', digit: '8', color: const Color(0xFF009688)),
    MatchItem(id: 9, text: 'NINE', digit: '9', color: const Color(0xFF9C27B0)),
  ];

  final Map<int, GlobalKey> leftKeys = {};
  final Map<int, GlobalKey> rightKeys = {};
  
  List<MatchedPair> matchedPairs = [];
  Offset? currentStart;
  Offset? currentEnd;
  int? activeLeftId;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(learningTtsServiceProvider.notifier);
    _initBgm();
    _generateLevel();
  }

  Future<void> _initBgm() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource(widget.bgmPath));
  }

  void _generateLevel() {
    final random = Random();
    final List<MatchItem> shuffled = List.from(allItems)..shuffle(random);
    final selected = shuffled.take(6).toList();
    
    setState(() {
      leftItems = List.from(selected)..shuffle(random);
      rightItems = List.from(selected)..shuffle(random);
      matchedPairs = [];
      activeLeftId = null;
      currentStart = null;
      currentEnd = null;
      
      leftKeys.clear();
      rightKeys.clear();
      for (var item in leftItems) {
        leftKeys[item.id] = GlobalKey();
      }
      for (var item in rightItems) {
        rightKeys[item.id] = GlobalKey();
      }
      _isSuccess = false;
    });
    if (!_isMuted && _isFirstLoad) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Match the words to the numbers');
      _isFirstLoad = false;
    }
  }

  Offset _getCenterOfWidget(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    final position = renderBox.localToGlobal(Offset.zero);
    return Offset(
      position.dx + renderBox.size.width / 2,
      position.dy + renderBox.size.height / 2,
    );
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _ttsNotifier.stop();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details, int leftId) {
    if (matchedPairs.any((p) => p.leftId == leftId)) return;
    
    final RenderBox? gameBox = context.findRenderObject() as RenderBox?;
    if (gameBox != null) {
      setState(() {
        activeLeftId = leftId;
        currentStart = _getCenterOfWidget(leftKeys[leftId]!);
        currentEnd = details.globalPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (activeLeftId != null) {
      setState(() {
        currentEnd = details.globalPosition;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (activeLeftId != null && currentEnd != null) {
      int? foundRightId;
      for (var item in rightItems) {
        final RenderBox? box = rightKeys[item.id]?.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) continue;
        
        final pos = box.localToGlobal(Offset.zero);
        final rect = pos & box.size;
        
        if (rect.inflate(25).contains(currentEnd!)) {
          foundRightId = item.id;
          break;
        }
      }

      if (foundRightId != null && foundRightId == activeLeftId) {
        // Haptic feedback for a successful match
        HapticFeedback.mediumImpact();
        
        if (!_isMuted) {
          final matchedItem = rightItems.firstWhere((it) => it.id == foundRightId);
          ref.read(learningTtsServiceProvider.notifier).playFeedback(matchedItem.text.toLowerCase());
        }

        setState(() {
          matchedPairs.add(MatchedPair(
            leftId: activeLeftId!,
            rightId: foundRightId!,
            start: currentStart!,
            end: _getCenterOfWidget(rightKeys[foundRightId]!),
            color: rightItems.firstWhere((it) => it.id == foundRightId).color!,
          ));
        });
        
        if (matchedPairs.length == leftItems.length) {
          _showSuccess();
        }
      }
    }

    setState(() {
      activeLeftId = null;
      currentStart = null;
      currentEnd = null;
    });
  }

  void _showSuccess() {
    setState(() {
      _isSuccess = true;
    });
    // Add points for Learning
    ref.read(userProvider.notifier).addPoints('Learning', 50);
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
            Positioned(
              top: 100,
              left: -50,
              child: _buildBlurredBlob(300, const Color(0xFFFFD1E1).withValues(alpha: 0.4)),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: _buildBlurredBlob(350, const Color(0xFFE1F5FE).withValues(alpha: 0.5)),
            ),
            Positioned(
              bottom: 100,
              right: -80,
              child: _buildBlurredBlob(400, const Color(0xFFF3E5F5).withValues(alpha: 0.4)),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: _buildBlurredBlob(300, const Color(0xFFFFF9C4).withValues(alpha: 0.3)),
            ),

            // Lines
            Positioned.fill(
              child: CustomPaint(
                painter: LinePainter(
                  matchedPairs: matchedPairs,
                  currentStart: currentStart,
                  currentEnd: currentEnd,
                  currentColor: activeLeftId != null 
                    ? Colors.grey.withValues(alpha: 0.5)
                    : Colors.transparent,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double itemHeight = constraints.maxHeight / 7;
                        final double fontSizeNames = min(itemHeight * 0.4, 24.0);
                        final double fontSizeDigits = min(itemHeight * 0.8, 60.0);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left column (Names)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: leftItems.map((item) => _buildLeftItem(item, fontSizeNames)).toList(),
                                ),
                              ),
                              const Spacer(flex: 1),
                              // Right column (Digits)
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: rightItems.map((item) => _buildRightItem(item, fontSizeDigits)).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Success Overlay
            SuccessOverlay(
              isVisible: _isSuccess,
              lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_obhph3sh.json', // Confetti
              onFinished: () {
                _generateLevel();
              },
            ),
          ],
        ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.popWithSound(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2D3142), size: 24),
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
                  _bgmPlayer.pause();
                } else {
                  _bgmPlayer.resume();
                }
              });
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFB347),
                        Color(0xFFB497FF),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'LOOK AND MATCH',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
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

  Widget _buildLeftItem(MatchItem item, double fontSize) {
    bool isMatched = matchedPairs.any((p) => p.leftId == item.id);
    return GestureDetector(
      onPanStart: (d) => _onPanStart(d, item.id),
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        key: leftKeys[item.id],
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isMatched || activeLeftId == item.id ? item.color! : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            item.text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: isMatched ? Colors.grey.withValues(alpha: 0.5) : const Color(0xFF5C677D),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightItem(MatchItem item, double fontSize) {
    bool isMatched = matchedPairs.any((p) => p.rightId == item.id);
    return Container(
      key: rightKeys[item.id],
      width: double.infinity,
      height: fontSize + 10,
      alignment: Alignment.center,
      child: Text(
        item.digit!,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: isMatched ? Colors.grey.withValues(alpha: 0.3) : item.color,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildBlurredBlob(double size, Color color) {
    return Container(
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
    );
  }
}

class MatchItem {
  final int id;
  final String text;
  final String? digit;
  final Color? color;
  MatchItem({required this.id, required this.text, this.digit, this.color});
}

class MatchedPair {
  final int leftId;
  final int rightId;
  final Offset start;
  final Offset end;
  final Color color;
  MatchedPair({
    required this.leftId, 
    required this.rightId, 
    required this.start, 
    required this.end, 
    required this.color
  });
}

class LinePainter extends CustomPainter {
  final List<MatchedPair> matchedPairs;
  final Offset? currentStart;
  final Offset? currentEnd;
  final Color currentColor;

  LinePainter({
    required this.matchedPairs,
    this.currentStart,
    this.currentEnd,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw matched lines with sticker-style trails
    for (var pair in matchedPairs) {
      _drawMagicalTrail(canvas, pair.start, pair.end, pair.color);
    }

    // Draw current line
    if (currentStart != null && currentEnd != null) {
      _drawMagicalTrail(canvas, currentStart!, currentEnd!, Colors.grey.withValues(alpha: 0.5), isDrawing: true);
    }
  }

  void _drawMagicalTrail(Canvas canvas, Offset start, Offset end, Color color, {bool isDrawing = false}) {
    final paint = Paint()
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (!isDrawing) {
      paint.shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.5)],
      ).createShader(Rect.fromPoints(start, end));
    } else {
      paint.color = color;
    }

    // Cubic Bezier for elegant S-curve
    final path = Path()..moveTo(start.dx, start.dy);
    final controlPoint1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );

    if (!isDrawing) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 14.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
          ..style = PaintingStyle.stroke,
      );
    }
    
    canvas.drawPath(path, paint);
    
    // Start Dot
    canvas.drawCircle(start, 8, Paint()..color = color);
    canvas.drawCircle(start, 10, Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

    // End Arrow
    _drawStickerArrowHead(canvas, controlPoint2, end, color);
  }

  void _drawStickerArrowHead(Canvas canvas, Offset controlPoint, Offset end, Color color) {
    final double arrowSize = 22.0;
    final double angle = (end - controlPoint).direction;
    
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx + arrowSize * cos(angle + 3.4 * pi / 4),
      end.dy + arrowSize * sin(angle + 3.4 * pi / 4),
    );
    path.quadraticBezierTo(
      end.dx + (arrowSize * 0.5) * cos(angle + pi),
      end.dy + (arrowSize * 0.5) * sin(angle + pi),
      end.dx + arrowSize * cos(angle - 3.4 * pi / 4),
      end.dy + arrowSize * sin(angle - 3.4 * pi / 4),
    );
    path.close();

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}
