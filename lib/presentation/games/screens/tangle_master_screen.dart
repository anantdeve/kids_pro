import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

class Rope {
  final int id;
  final int bottomAnchorIndex;
  final Color color;

  Rope(this.id, this.bottomAnchorIndex, this.color);
}

class TangleMasterScreen extends StatefulWidget {
  const TangleMasterScreen({super.key});

  @override
  State<TangleMasterScreen> createState() => _TangleMasterScreenState();
}

class _TangleMasterScreenState extends State<TangleMasterScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  
  List<Offset> _topSockets = [];
  List<Offset> _bottomAnchors = [];
  
  List<Rope> _ropes = [];
  List<int?> _socketOccupants = []; // length: numSockets, value: Rope ID or null
  
  int _currentLevel = 1;
  int _numRopes = 3;
  int _numSockets = 4;
  
  int? _draggedSocketIndex;
  Offset? _dragPosition;
  
  bool _isLevelComplete = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateLevel(context.size ?? const Size(400, 800));
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _generateLevel(Size size) {
    setState(() {
      _isLevelComplete = false;
      isPlaying = false;
      _draggedSocketIndex = null;
      _dragPosition = null;
      
      _numRopes = min(2 + _currentLevel, 7); // Starts at 3 ropes, max 7
      _numSockets = _numRopes + 1; // 1 empty socket
      
      double horizontalPadding = 40.0;
      double availableWidth = size.width - (horizontalPadding * 2);
      
      double topY = size.height * 0.25;
      double bottomY = size.height * 0.75;
      
      // Calculate positions
      _topSockets = [];
      double socketSpacing = availableWidth / max(1, _numSockets - 1);
      for (int i = 0; i < _numSockets; i++) {
        _topSockets.add(Offset(horizontalPadding + (i * socketSpacing), topY));
      }

      _bottomAnchors = [];
      double anchorSpacing = availableWidth / max(1, _numRopes - 1);
      for (int i = 0; i < _numRopes; i++) {
        _bottomAnchors.add(Offset(horizontalPadding + (i * anchorSpacing), bottomY));
      }
      
      final colors = [
        const Color(0xFFFF5252),
        const Color(0xFF448AFF),
        const Color(0xFF69F0AE),
        const Color(0xFFFFAB40),
        const Color(0xFFE040FB),
        const Color(0xFF18FFFF),
        const Color(0xFFFF4081),
      ];
      
      _ropes = [];
      for (int i = 0; i < _numRopes; i++) {
         _ropes.add(Rope(i, i, colors[i % colors.length]));
      }
      
      _socketOccupants = List.filled(_numSockets, null);
      
      // Shuffle ropes into sockets ensuring at least one intersection
      bool hasIntersections = false;
      int attempts = 0;
      while (!hasIntersections && attempts < 100) {
        _socketOccupants = List.filled(_numSockets, null);
        List<int> availableSockets = List.generate(_numSockets, (i) => i);
        availableSockets.shuffle(Random());
        
        for (int i = 0; i < _numRopes; i++) {
          _socketOccupants[availableSockets[i]] = i; // Assign rope i to random socket
        }
        
        hasIntersections = _checkAnyIntersection();
        attempts++;
      }
    });
  }

  bool _checkAnyIntersection() {
    return _getIntersectingRopes().isNotEmpty;
  }

  Set<int> _getIntersectingRopes() {
    Set<int> intersectingRopeIds = {};
    
    // Find where each rope is currently plugged in
    Map<int, int> ropeToSocket = {}; // ropeId -> socketIndex
    for (int i = 0; i < _numSockets; i++) {
      if (_socketOccupants[i] != null) {
        ropeToSocket[_socketOccupants[i]!] = i;
      }
    }

    // Check all pairs for topological crossing
    for (int i = 0; i < _ropes.length; i++) {
      for (int j = i + 1; j < _ropes.length; j++) {
        final r1 = _ropes[i];
        final r2 = _ropes[j];
        
        int? s1 = ropeToSocket[r1.id];
        int? s2 = ropeToSocket[r2.id];
        
        if (s1 != null && s2 != null) {
          // If the order at top is different from the order at bottom, they cross.
          // Since bottom anchor indices are strictly increasing, we just check:
          int topDiff = s1 - s2;
          int bottomDiff = r1.bottomAnchorIndex - r2.bottomAnchorIndex;
          
          if ((topDiff * bottomDiff) < 0) {
            intersectingRopeIds.add(r1.id);
            intersectingRopeIds.add(r2.id);
          }
        }
      }
    }
    return intersectingRopeIds;
  }

  void _onPanStart(DragStartDetails details) {
    if (_isLevelComplete || _topSockets.isEmpty || !isPlaying) return;
    
    // Find nearest occupied top socket
    for (int i = 0; i < _numSockets; i++) {
      final pos = _topSockets[i];
      if ((details.localPosition - pos).distance < 40) { // Hitbox radius
        if (_socketOccupants[i] != null) {
          setState(() {
            _draggedSocketIndex = i;
            _dragPosition = details.localPosition;
          });
          HapticFeedback.selectionClick();
        }
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedSocketIndex != null) {
      setState(() {
        _dragPosition = details.localPosition;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggedSocketIndex != null && _dragPosition != null) {
      // Find nearest EMPTY peg to snap to
      int nearestEmptySocket = -1;
      double minDistance = double.infinity;
      
      for (int i = 0; i < _topSockets.length; i++) {
        double dist = (_topSockets[i] - _dragPosition!).distance;
        if (dist < 60 && dist < minDistance) { // Snap radius
          if (_socketOccupants[i] == null) {
            nearestEmptySocket = i;
            minDistance = dist;
          }
        }
      }

      setState(() {
        if (nearestEmptySocket != -1) {
          // Move plug to empty socket
          int ropeId = _socketOccupants[_draggedSocketIndex!]!;
          _socketOccupants[nearestEmptySocket] = ropeId;
          _socketOccupants[_draggedSocketIndex!] = null;
          
          HapticFeedback.mediumImpact();
        } else {
          // Snap back
          HapticFeedback.lightImpact();
        }
        
        _draggedSocketIndex = null;
        _dragPosition = null;
        
        // Check win condition
        if (!_checkAnyIntersection()) {
          _isLevelComplete = true;
          _confettiController.play();
          HapticFeedback.heavyImpact();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background Gradient (Premium Frosted Glass look)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF3E5F5), 
                    Color(0xFFE8EAF6), 
                    Color(0xFFE0F7FA),
                    Color(0xFFFCE4EC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Container(
                          color: Colors.transparent, // Catch all touches
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: _TanglePainter(
                              topSockets: _topSockets,
                              bottomAnchors: _bottomAnchors,
                              socketOccupants: _socketOccupants,
                              ropes: _ropes,
                              draggedSocketIndex: _draggedSocketIndex,
                              dragPosition: _dragPosition,
                              intersectingRopeIds: _getIntersectingRopes(),
                            ),
                          ),
                        ),
                      ),
                      
                      // Play button overlay
                      if (!isPlaying && !_isLevelComplete)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.5),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 60.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isPlaying = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Play',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Win overlay
          if (_isLevelComplete)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🌟 Brilliant! 🌟',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFB300),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'You untangled the ropes!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF455A64),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentLevel++;
                                _generateLevel(MediaQuery.of(context).size);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DB6AC),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Next Level',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2D3142), size: 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level $_currentLevel',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4DB6AC),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _TanglePainter extends CustomPainter {
  final List<Offset> topSockets;
  final List<Offset> bottomAnchors;
  final List<int?> socketOccupants;
  final List<Rope> ropes;
  final int? draggedSocketIndex;
  final Offset? dragPosition;
  final Set<int> intersectingRopeIds;

  _TanglePainter({
    required this.topSockets,
    required this.bottomAnchors,
    required this.socketOccupants,
    required this.ropes,
    required this.draggedSocketIndex,
    required this.dragPosition,
    required this.intersectingRopeIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw top sockets (empty ones) and bottom anchors
    for (var pos in topSockets) {
      // Outer bevel
      final outerBevel = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFB0BEC5)],
        ).createShader(Rect.fromCircle(center: pos, radius: 24));
      canvas.drawCircle(pos, 24, outerBevel);

      // Inner hole shadow (depth)
      final innerHole = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF263238), Color(0xFF78909C)],
          stops: [0.4, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: 20));
      canvas.drawCircle(pos, 20, innerHole);
      
      // Inner rim highlight
      final rim = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pos, 20, rim);
    }

    for (var pos in bottomAnchors) {
      // Draw metallic block for anchors
      final anchorPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCFD8DC), Color(0xFF546E7A)],
        ).createShader(Rect.fromCenter(center: pos, width: 44, height: 20));
      
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: 44, height: 20),
        const Radius.circular(10),
      );
      
      // Shadow
      canvas.drawRRect(rrect.shift(const Offset(0, 4)), Paint()..color = Colors.black26);
      canvas.drawRRect(rrect, anchorPaint);
      
      // Highlight
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // 2. Draw ropes (we draw non-intersecting first to keep them behind, maybe?)
    // Actually, draw them all, but maybe highlight the intersecting ones.
    for (int i = 0; i < ropes.length; i++) {
      final rope = ropes[i];
      
      // Find where this rope's top is
      Offset? topPos;
      bool isBeingDragged = false;
      
      for (int s = 0; s < topSockets.length; s++) {
        if (socketOccupants[s] == rope.id) {
          if (draggedSocketIndex == s && dragPosition != null) {
            topPos = dragPosition;
            isBeingDragged = true;
          } else {
            topPos = topSockets[s];
          }
          break;
        }
      }
      
      if (topPos == null) continue; // Safety check
      
      final bottomPos = bottomAnchors[rope.bottomAnchorIndex];
      bool isIntersecting = intersectingRopeIds.contains(rope.id);

      // Create droopy path
      final path = Path();
      path.moveTo(topPos.dx, topPos.dy);
      // The control point is halfway down, but we push it lower to create a sag effect
      double sagY = bottomPos.dy - 60;
      if (isBeingDragged) {
        sagY = bottomPos.dy - 20; // Less sag when pulling
      }
      path.quadraticBezierTo(
        (topPos.dx + bottomPos.dx) / 2, 
        sagY, 
        bottomPos.dx, 
        bottomPos.dy
      );

      // Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      
      final shadowPath = Path();
      shadowPath.moveTo(topPos.dx, topPos.dy + 8);
      shadowPath.quadraticBezierTo(
        (topPos.dx + bottomPos.dx) / 2, 
        sagY + 8, 
        bottomPos.dx, 
        bottomPos.dy + 8
      );
      canvas.drawPath(shadowPath, shadowPaint);

      // Rope Base (Darker edge for 3D effect)
      final ropeBase = Paint()
        ..color = isIntersecting ? const Color(0xFFB71C1C) : HSLColor.fromColor(rope.color).withLightness(0.3).toColor()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, ropeBase);

      // Rope Body (Main Color)
      final ropePaint = Paint()
        ..color = isIntersecting ? const Color(0xFFFF5252) : rope.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, ropePaint);
      
      // Braided Texture
      final metrics = path.computeMetrics();
      final braidDark = Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
        
      final braidLight = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      for (var metric in metrics) {
        for (double d = 0; d < metric.length; d += 10) {
          final ui.Tangent? tangent = metric.getTangentForOffset(d);
          if (tangent != null) {
            final pos = tangent.position;
            final vec = tangent.vector;
            final normal = Offset(-vec.dy, vec.dx); // Perpendicular vector
            
            // Draw criss-cross diagonals to simulate braiding
            final start1 = pos - (normal * 5) - (vec * 4);
            final end1 = pos + (normal * 5) + (vec * 4);
            canvas.drawLine(start1, end1, braidDark);
            canvas.drawLine(start1 + const Offset(1, 1), end1 + const Offset(1, 1), braidLight);
            
            final start2 = pos + (normal * 5) - (vec * 4);
            final end2 = pos - (normal * 5) + (vec * 4);
            canvas.drawLine(start2, end2, braidDark);
            canvas.drawLine(start2 + const Offset(1, 1), end2 + const Offset(1, 1), braidLight);
          }
        }
      }
      
      // Rope highlight (3D shine)
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
        
      final highlightPath = Path();
      highlightPath.moveTo(topPos.dx - 2, topPos.dy - 2);
      highlightPath.quadraticBezierTo(
        ((topPos.dx + bottomPos.dx) / 2) - 2, 
        sagY - 2, 
        bottomPos.dx - 2, 
        bottomPos.dy - 2
      );
      canvas.drawPath(highlightPath, highlightPaint);
      
      // Draw plug head at top position
      double plugRadius = isBeingDragged ? 28 : 24;
      
      // Plug shadow
      final nodeShadow = Paint()
        ..color = Colors.black.withValues(alpha: isBeingDragged ? 0.4 : 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(topPos + Offset(0, isBeingDragged ? 12 : 6), plugRadius, nodeShadow);

      // Plug Base (Metallic border)
      final nodeOuter = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFF90A4AE)],
        ).createShader(Rect.fromCircle(center: topPos, radius: plugRadius));
      canvas.drawCircle(topPos, plugRadius, nodeOuter);

      // Plug Inner (Shiny Colored Dome)
      double innerRadius = isBeingDragged ? 20 : 16;
      final nodeInner = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            rope.color,
            HSLColor.fromColor(rope.color).withLightness(0.3).toColor(),
          ],
          stops: const [0.0, 0.4, 1.0],
          center: const Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: topPos, radius: innerRadius));
      canvas.drawCircle(topPos, innerRadius, nodeInner);
    }
  }

  @override
  bool shouldRepaint(covariant _TanglePainter oldDelegate) {
    return true; 
  }
}
