import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math';

class LookAndMatchGameScreen extends StatefulWidget {
  const LookAndMatchGameScreen({super.key});

  @override
  State<LookAndMatchGameScreen> createState() => _LookAndMatchGameScreenState();
}

class _LookAndMatchGameScreenState extends State<LookAndMatchGameScreen> {
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

  @override
  void initState() {
    super.initState();
    _generateLevel();
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
    });
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

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.globalPosition;
    
    // Check if touch started on a left item
    for (var item in leftItems) {
      if (matchedPairs.any((p) => p.leftId == item.id)) continue;
      
      final RenderBox? box = leftKeys[item.id]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      
      final pos = box.localToGlobal(Offset.zero);
      final rect = pos & box.size;
      
      if (rect.contains(localPosition)) {
        setState(() {
          activeLeftId = item.id;
          currentStart = _getCenterOfWidget(leftKeys[item.id]!);
          currentEnd = localPosition;
        });
        break;
      }
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
        
        if (rect.inflate(20).contains(currentEnd!)) {
          foundRightId = item.id;
          break;
        }
      }

      if (foundRightId != null && foundRightId == activeLeftId) {
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Great Job!'),
        content: const Text('You matched all the numbers!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateLevel();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Draw lines to connect!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D99AE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                        fontSize: 24,
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
    return Container(
      key: leftKeys[item.id],
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
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
    final paint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw matched lines with arrows
    for (var pair in matchedPairs) {
      paint.color = pair.color.withValues(alpha: 0.6);
      _drawArrowLine(canvas, pair.start, pair.end, paint);
    }

    // Draw current line
    if (currentStart != null && currentEnd != null) {
      paint.color = Colors.grey.withValues(alpha: 0.4);
      _drawArrowLine(canvas, currentStart!, currentEnd!, paint);
    }
  }

  void _drawArrowLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    
    // Draw circle at start
    final dotPaint = Paint()..color = paint.color.withValues(alpha: 0.8)..style = PaintingStyle.fill;
    canvas.drawCircle(start, 5, dotPaint);

    // Calculate arrowhead
    final double arrowSize = 12.0;
    final double angle = (end - start).direction;
    
    final Path arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..relativeLineTo(
        arrowSize * cos(angle + 4 * pi / 5),
        arrowSize * sin(angle + 4 * pi / 5),
      )
      ..moveTo(end.dx, end.dy)
      ..relativeLineTo(
        arrowSize * cos(angle - 4 * pi / 5),
        arrowSize * sin(angle - 4 * pi / 5),
      );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}
