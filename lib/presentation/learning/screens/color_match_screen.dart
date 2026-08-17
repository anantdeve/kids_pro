import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/success_overlay.dart';
import '../services/learning_tts_service.dart';
import '../widgets/tts_animated_speaker.dart';
import 'package:audioplayers/audioplayers.dart';


class ColorMatchScreen extends ConsumerStatefulWidget {
  const ColorMatchScreen({super.key});

  @override
  ConsumerState<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends ConsumerState<ColorMatchScreen> {
  late final LearningTtsNotifier _ttsNotifier;
  bool _isSuccess = false;
  bool _isMuted = false;
  final AudioPlayer _bgmPlayer = AudioPlayer();

  
  final Map<String, List<String>> emojiPool = {
    'yellow': ['🍌', '🍋', '🐥', '🧀', '🌻', '🟡', '🌽'],
    'pink': ['🌸', '🐷', '🎀', '🍭', '💗', '🍬', '🦩'],
    'blue': ['🐳', '🐋', '🚙', '🧊', '🔵', '🌊', '🐬'],
    'purple': ['🍇', '🍆', '🐙', '🌂', '🟣', '🔮', '👿'],
    'red': ['🍎', '🍓', '🚗', '🎈', '🔴', '🍒', '🍅'],
    'green': ['🥦', '🌲', '🐸', '🐢', '🟢', '🥬', '🍐'],
    'orange': ['🥕', '🍊', '🦊', '🏀', '🟠', '🎃', '🐯'],
    'brown': ['🐻', '🍩', '🥔', '👞', '🟤', '🍫', '🍪'],
  };

  final List<ColorItem> allAvailableColors = [
    ColorItem(id: 'yellow', label: 'YELLOW', color: const Color(0xFFFFD166)),
    ColorItem(id: 'pink', label: 'PINK', color: const Color(0xFFFF7B9C)),
    ColorItem(id: 'blue', label: 'BLUE', color: const Color(0xFF67E1F5)),
    ColorItem(id: 'purple', label: 'PURPLE', color: const Color(0xFFB497FF)),
    ColorItem(id: 'red', label: 'RED', color: const Color(0xFFFF595E)),
    ColorItem(id: 'green', label: 'GREEN', color: const Color(0xFF8AC926)),
    ColorItem(id: 'orange', label: 'ORANGE', color: const Color(0xFFFF9248)),
    ColorItem(id: 'brown', label: 'BROWN', color: const Color(0xFF967259)),
  ];

  List<ColorItem> labels = [];
  List<ObjectItem> objects = [];

  final Map<String, GlobalKey> labelKeys = {};
  final Map<String, GlobalKey> objectKeys = {};
  final GlobalKey _gameAreaKey = GlobalKey();
  final Map<String, String> matches = {}; // labelId -> objectId

  Offset? dragStart;
  Offset? dragCurrent;
  String? activeLabelId;

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(learningTtsServiceProvider.notifier);
    _setupGame();
    
    // Play intro voice immediately
    Future.microtask(() async {
      if (!_isMuted && mounted) {
        await _ttsNotifier.playFeedback('Color Match');
      }
      if (mounted) {
        _bgmPlayer.setReleaseMode(ReleaseMode.loop);
        _bgmPlayer.play(AssetSource('audio/Sounds/feature bk sound.mp3'));
      }
    });
  }

  void _setupGame() {
    final random = Random();
    
    // Pick 4 random colors from the available pool for this round
    final shuffledColors = List<ColorItem>.from(allAvailableColors)..shuffle();
    final selectedColors = shuffledColors.take(4).toList();
    
    // Shuffled labels for the left column
    labels = List<ColorItem>.from(selectedColors)..shuffle();
    
    // Create objects with random emojis for each selected color for the right column
    objects = selectedColors.map((colorItem) {
      final pool = emojiPool[colorItem.id] ?? ['❓'];
      final emoji = pool[random.nextInt(pool.length)];
      return ObjectItem(id: colorItem.id, emoji: emoji, color: colorItem.color);
    }).toList();
    
    // Shuffle objects column
    objects.shuffle();

    // Re-initialize keys
    labelKeys.clear();
    objectKeys.clear();
    for (var item in labels) {
      labelKeys[item.id] = GlobalKey();
    }
    for (var item in objects) {
      objectKeys[item.id] = GlobalKey();
    }
    
    matches.clear();
  }

  @override
  void dispose() {
    _ttsNotifier.stop();
    _bgmPlayer.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details, String labelId) {
    if (matches.containsKey(labelId)) return;
    
    final RenderBox? gameBox = _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (gameBox != null) {
      setState(() {
        activeLabelId = labelId;
        dragStart = gameBox.globalToLocal(details.globalPosition);
        dragCurrent = dragStart;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (activeLabelId == null) return;
    final RenderBox? gameBox = _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (gameBox != null) {
      setState(() {
        dragCurrent = gameBox.globalToLocal(details.globalPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (activeLabelId == null || dragCurrent == null) return;

    // Check if dragCurrent is over an object
    String? targetObjectId;
    final RenderBox? gameBox = _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (gameBox != null) {
      for (var entry in objectKeys.entries) {
        final RenderBox? box = entry.value.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final Offset position = box.localToGlobal(Offset.zero);
          final Offset localPos = gameBox.globalToLocal(position);
          final Size size = box.size;
          final Rect rect = Rect.fromLTWH(localPos.dx, localPos.dy, size.width, size.height);
          
          if (rect.inflate(20).contains(dragCurrent!)) { // Added some tolerance
            targetObjectId = entry.key;
            break;
          }
        }
      }
    }

    if (targetObjectId != null && targetObjectId == activeLabelId) {
      final matchedLabel = labels.firstWhere((l) => l.id == activeLabelId).label;
      if (!_isMuted) {
        ref.read(learningTtsServiceProvider.notifier).playFeedback(matchedLabel.toLowerCase());
      }

      setState(() {
        matches[activeLabelId!] = targetObjectId!;
      });

      // Check for completion
      if (matches.length == labels.length) {
        setState(() {
          _isSuccess = true;
        });
      }
    }

    setState(() {
      activeLabelId = null;
      dragStart = null;
      dragCurrent = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          if (Theme.of(context).brightness == Brightness.light)
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
                          color: Theme.of(context).cardTheme.color ?? Colors.white,
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
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF7B9C),
                                  Color(0xFF67E1F5),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'COLOR MATCH',
                                style: TextStyle(
                                  fontSize: 18, // Updated to match Draw & Match card
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TtsAnimatedSpeaker(
                        isMuted: _isMuted,
                        onTap: () {
                          setState(() {
                            _isMuted = !_isMuted;
                            if (_isMuted) {
                              ref.read(learningTtsServiceProvider.notifier).stop();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Stack(
                    key: _gameAreaKey,
                    children: [
                      // Canvas for lines
                      Positioned.fill(
                        child: CustomPaint(
                            painter: LinePainter(
                              matches: matches,
                              activeLabelId: activeLabelId,
                              dragStart: dragStart,
                              dragCurrent: dragCurrent,
                              labelKeys: labelKeys,
                              objectKeys: objectKeys,
                              gameAreaKey: _gameAreaKey,
                              labels: labels,
                            ),
                        ),
                      ),

                      // Labels and Objects
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left Column: Labels
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: labels.map((item) {
                                final isMatched = matches.containsKey(item.id);
                                return GestureDetector(
                                  onPanStart: (d) => _onPanStart(d, item.id),
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: Container(
                                    key: labelKeys[item.id],
                                    width: 120,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: item.color,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: isMatched || activeLabelId == item.id 
                                            ? Colors.white 
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.color.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Right Column: Objects
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: objects.map((item) {
                                final isMatched = matches.containsValue(item.id);
                                return Container(
                                  key: objectKeys[item.id],
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(alpha: 0.25), // Slightly darker tinted background
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isMatched 
                                          ? item.color 
                                          : item.color.withValues(alpha: 0.5), // More visible border
                                      width: isMatched ? 4 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isMatched 
                                            ? item.color.withValues(alpha: 0.4) 
                                            : Colors.black.withValues(alpha: 0.05),
                                        blurRadius: isMatched ? 15 : 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.emoji,
                                    style: const TextStyle(
                                      fontSize: 45,
                                      fontFamilyFallback: ['Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji'],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SuccessOverlay(
            isVisible: _isSuccess,
            onFinished: () {
              setState(() {
                _isSuccess = false;
                _setupGame();
              });
            },
          ),
        ],
      ),
    );
  }
}

class ColorItem {
  final String id;
  final String label;
  final Color color;
  ColorItem({required this.id, required this.label, required this.color});
}

class ObjectItem {
  final String id;
  final String emoji;
  final Color color;
  ObjectItem({required this.id, required this.emoji, required this.color});
}

class LinePainter extends CustomPainter {
  final Map<String, String> matches;
  final String? activeLabelId;
  final Offset? dragStart;
  final Offset? dragCurrent;
  final Map<String, GlobalKey> labelKeys;
  final Map<String, GlobalKey> objectKeys;
  final GlobalKey gameAreaKey;
  final List<ColorItem> labels;

  LinePainter({
    required this.matches,
    this.activeLabelId,
    this.dragStart,
    this.dragCurrent,
    required this.labelKeys,
    required this.objectKeys,
    required this.gameAreaKey,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw completed matches
    matches.forEach((labelId, objectId) {
      final start = _getWidgetCenter(labelKeys[labelId], isLeft: true);
      final end = _getWidgetCenter(objectKeys[objectId], isLeft: false);
      if (start != null && end != null) {
        final color = labels.firstWhere((l) => l.id == labelId).color;
        _drawCurve(canvas, start, end, basePaint..color = color.withValues(alpha: 0.6));
      }
    });

    // Draw active drag
    if (dragStart != null && dragCurrent != null && activeLabelId != null) {
      final color = labels.firstWhere((l) => l.id == activeLabelId).color;
      _drawCurve(canvas, dragStart!, dragCurrent!, basePaint..color = color.withValues(alpha: 0.8));
    }
  }

  Offset? _getWidgetCenter(GlobalKey? key, {required bool isLeft}) {
    final RenderBox? box = key?.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset position = box.localToGlobal(Offset.zero);
      final Size widgetSize = box.size;
      
      final RenderBox? gameBox = gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (gameBox != null) {
        final Offset localPos = gameBox.globalToLocal(position);
        return Offset(
          isLeft ? localPos.dx + widgetSize.width : localPos.dx,
          localPos.dy + widgetSize.height / 2,
        );
      }
    }
    return null;
  }

  void _drawCurve(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // Create a smooth curve
    final controlPoint1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );
    
    canvas.drawPath(path, paint);

    // Draw arrow at the end
    final arrowSize = 10.0;
    final angle = 0.0; // Horizontal-ish end
    
    final pathArrow = Path();
    pathArrow.moveTo(end.dx, end.dy);
    pathArrow.lineTo(end.dx - arrowSize, end.dy - arrowSize / 2);
    pathArrow.lineTo(end.dx - arrowSize, end.dy + arrowSize / 2);
    pathArrow.close();
    
    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(pathArrow, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}
