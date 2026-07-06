import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/child_standard_provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../learning/widgets/success_overlay.dart';

enum AsmrPhase { tracing, coloring, done }

class AsmrLevel {
  final String name;
  final String emoji;
  final Path Function(Size) pathBuilder;
  const AsmrLevel(this.name, this.emoji, this.pathBuilder);
}

class AsmrColoringScreen extends ConsumerStatefulWidget {
  const AsmrColoringScreen({super.key});

  @override
  ConsumerState<AsmrColoringScreen> createState() => _AsmrColoringScreenState();
}

class _AsmrColoringScreenState extends ConsumerState<AsmrColoringScreen> with SingleTickerProviderStateMixin {
  int _currentLevelIndex = 0;
  
  AsmrPhase _phase = AsmrPhase.tracing;
  double _traceProgress = 0.0;
  bool _canColor = false; // Prevents accidental fill if finger isn't lifted after tracing
  
  Color _selectedColor = const Color(0xFFFF4757);
  
  // Scrubbing logic
  List<Offset?> _colorStrokes = [];
  
  // Advanced Visual Fill Detection (Grid-based)
  Set<int> _validPathCells = {};
  Set<int> _coloredCells = {};
  Rect _currentBounds = Rect.zero;
  
  // Dynamic Pen tracking
  Offset? _currentFingerPos;
  double _penTilt = 0.1;
  
  bool _isSuccess = false;
  
  late final List<AsmrLevel> _levels;
  
  final List<Color> _colors = [
    const Color(0xFFFF4757), // Red
    const Color(0xFFFF6B81), // Pink
    const Color(0xFFFFA502), // Orange
    const Color(0xFFECCC68), // Gold
    const Color(0xFF7BED9F), // Light Green
    const Color(0xFF2ED573), // Green
    const Color(0xFF70A1FF), // Light Blue
    const Color(0xFF1E90FF), // Blue
    const Color(0xFF5352ED), // Indigo
    const Color(0xFF3742FA), // Deep Purple
    const Color(0xFFA4B0BE), // Silver
    const Color(0xFF2F3542), // Dark
  ];

  @override
  void initState() {
    super.initState();
    _levels = [
      AsmrLevel('Fluffy Cloud', '☁️', _getCloudPath),
      AsmrLevel('Magic Heart', '💖', _getHeartPath),
      AsmrLevel('Shiny Star', '⭐', _getStarPath),
      AsmrLevel('Juicy Apple', '🍎', _getApplePath),
    ];
  }

  void _nextLevel() {
    setState(() {
      _currentLevelIndex = (_currentLevelIndex + 1) % _levels.length;
      _resetLevel();
    });
  }
  
  void _resetLevel() {
    setState(() {
      _phase = AsmrPhase.tracing;
      _traceProgress = 0.0;
      _canColor = false;
      _colorStrokes.clear();
      
      _validPathCells.clear();
      _coloredCells.clear();
      _currentBounds = Rect.zero;
      
      _currentFingerPos = null;
      _penTilt = 0.1;
      _isSuccess = false;
    });
  }

  void _onPanUpdateTracing(DragUpdateDetails details, PathMetric metric) {
    if (_phase == AsmrPhase.tracing) {
      final currentDistance = metric.length * _traceProgress;
      final tangent = metric.getTangentForOffset(currentDistance);
      if (tangent == null) return;

      final penTip = tangent.position;
      final fingerPos = details.localPosition;
      
      setState(() {
        _currentFingerPos = fingerPos;
        final targetTilt = (details.delta.dx * 0.03).clamp(-0.3, 0.3);
        _penTilt = (_penTilt * 0.7) + (targetTilt * 0.3);
      });
      
      // Massive grab radius to make tracing perfectly forgiving for kids
      if ((fingerPos - penTip).distance < 250.0) {
        final dragVector = details.delta;
        final pathDirection = tangent.vector; 
        final dot = (dragVector.dx * pathDirection.dx) + (dragVector.dy * pathDirection.dy);
        
        if (dot > 0) {
          setState(() {
            _traceProgress += (dot / metric.length); 
            if (_traceProgress >= 1.0) {
              _traceProgress = 1.0;
              _phase = AsmrPhase.coloring;
              _canColor = false; // Force them to lift finger first!
              _currentFingerPos = null;
              HapticFeedback.mediumImpact();
            } else {
              if (DateTime.now().millisecond % 50 < 10) {
                HapticFeedback.lightImpact();
              }
            }
          });
        }
      }
    }
  }

  void _onPanUpdateColoring(DragUpdateDetails details) {
    if (_phase == AsmrPhase.coloring && _canColor) {
      setState(() {
        _currentFingerPos = details.localPosition;
        _colorStrokes.add(details.localPosition);
        
        final targetTilt = (details.delta.dx * 0.03).clamp(-0.3, 0.3);
        _penTilt = (_penTilt * 0.7) + (targetTilt * 0.3);
        
        if (DateTime.now().millisecond % 50 < 10) {
           HapticFeedback.lightImpact();
        }
        
        // Advanced Grid-based Visual Fill Detection
        if (_validPathCells.isNotEmpty && _currentBounds != Rect.zero) {
          double cellW = _currentBounds.width / 15;
          double cellH = _currentBounds.height / 15;
          int col = ((details.localPosition.dx - _currentBounds.left) / cellW).floor();
          int row = ((details.localPosition.dy - _currentBounds.top) / cellH).floor();
          
          // Brush is thick (~60px), mark 3x3 surrounding cells
          for (int r = row - 1; r <= row + 1; r++) {
            for (int c = col - 1; c <= col + 1; c++) {
              if (r >= 0 && r < 15 && c >= 0 && c < 15) {
                int idx = r * 15 + c;
                if (_validPathCells.contains(idx)) {
                  _coloredCells.add(idx);
                }
              }
            }
          }
          
          // Require 95% visually filled to prevent premature "auto snap fill"
          if (_coloredCells.length >= _validPathCells.length * 0.95) {
            _phase = AsmrPhase.done;
            _currentFingerPos = null;
            _triggerSuccess();
          }
        }
      });
    }
  }
  
  void _onPanDown(DragDownDetails details) {
    setState(() {
      _currentFingerPos = details.localPosition;
      _penTilt = 0.1; 
    });
    if (_phase == AsmrPhase.coloring) {
      setState(() {
        _canColor = true; // They lifted and touched down again!
        _colorStrokes.add(details.localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _currentFingerPos = null;
      _penTilt = 0.1;
    });
    if (_phase == AsmrPhase.coloring) {
      setState(() {
        _colorStrokes.add(null);
      });
    }
  }

  void _triggerSuccess() {
    setState(() {
      _isSuccess = true;
    });
    HapticFeedback.heavyImpact();
    ref.read(userProvider.notifier).addPoints('Learning', 50);
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6), // Slightly darker bg for contrast
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(currentLevel),
                
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      final path = currentLevel.pathBuilder(size);
                      
                      final bounds = path.getBounds();
                      
                      // Calculate Grid Cells for precise Visual Fill Detection (Run once per level)
                      if (_validPathCells.isEmpty || _currentBounds != bounds) {
                        final validCells = <int>{};
                        double cellW = bounds.width / 15;
                        double cellH = bounds.height / 15;
                        for (int r = 0; r < 15; r++) {
                          for (int c = 0; c < 15; c++) {
                            double px = bounds.left + c * cellW + cellW / 2;
                            double py = bounds.top + r * cellH + cellH / 2;
                            if (path.contains(Offset(px, py))) {
                              validCells.add(r * 15 + c);
                            }
                          }
                        }
                        Future.microtask(() {
                          if (mounted && (_validPathCells.isEmpty || _currentBounds != bounds)) {
                            setState(() {
                              _currentBounds = bounds;
                              _validPathCells = validCells;
                              // Clear colored cells if the bounds just changed
                              _coloredCells.clear();
                            });
                          }
                        });
                      }
                      
                      final metrics = path.computeMetrics().toList();
                      final metric = metrics.isNotEmpty ? metrics.first : null;
                      
                      return GestureDetector(
                        onPanUpdate: (details) {
                          if (_phase == AsmrPhase.tracing && metric != null) {
                            _onPanUpdateTracing(details, metric);
                          } else if (_phase == AsmrPhase.coloring) {
                            _onPanUpdateColoring(details);
                          }
                        },
                        onPanDown: _onPanDown,
                        onPanEnd: _onPanEnd,
                        onPanCancel: () => _onPanEnd(DragEndDetails()),
                        child: Container(
                          color: Colors.transparent, 
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: AsmrPainter(
                              phase: _phase,
                              traceProgress: _traceProgress,
                              colorStrokes: _colorStrokes,
                              selectedColor: _selectedColor,
                              path: path,
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
                
                // Sleek 3D Color Dock
                _buildBottomControls(),
              ],
            ),
            
            // The Realistic 3D Sketch Pen
            if (_currentFingerPos != null)
              Positioned(
                left: _currentFingerPos!.dx - 40, // Centered horizontally on the tip
                top: _currentFingerPos!.dy - 120, // Hover above the finger
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: _penTilt, end: _penTilt),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    builder: (context, tilt, child) {
                      return Transform(
                        alignment: const Alignment(0.0, 0.8), // Rotate around the tip
                        transform: Matrix4.identity()..rotateZ(tilt),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 80,
                      height: 150,
                      child: CustomPaint(
                        painter: SketchPenPainter(color: _selectedColor),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Success Overlay
            SuccessOverlay(
              key: ValueKey('success_$_currentLevelIndex'), // Force complete rebuild on new levels to replay confetti!
              isVisible: _isSuccess,
              lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json',
              onFinished: () {}, 
            ),
            
            // Floating Points Reward
            if (_isSuccess)
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('points_tween_$_currentLevelIndex'), // Force tween to replay!
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeOutExpo,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -100 * value), // Floats upward
                        child: Opacity(
                          opacity: value < 0.8 ? 1.0 : (1.0 - (value - 0.8) * 5).clamp(0.0, 1.0), // Fades out at the end
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      ),
                      child: const Text(
                        '+50 Points! 🌟',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            if (_isSuccess)
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('next_tween_$_currentLevelIndex'), // Force tween to replay!
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: ElevatedButton.icon(
                      onPressed: _nextLevel,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 28),
                      label: const Text(
                        'Next Page!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Path _getCloudPath(Size size) {
    final width = size.width * 0.8;
    final height = width * 0.6;
    final dx = (size.width - width) / 2;
    final dy = (size.height - height) / 2;
    
    final path = Path();
    path.moveTo(dx + width * 0.2, dy + height * 0.6);
    path.quadraticBezierTo(dx + width * 0.2, dy + height * 0.4, dx + width * 0.4, dy + height * 0.4);
    path.quadraticBezierTo(dx + width * 0.5, dy + height * 0.1, dx + width * 0.7, dy + height * 0.4);
    path.quadraticBezierTo(dx + width * 0.95, dy + height * 0.4, dx + width * 0.95, dy + height * 0.7);
    path.quadraticBezierTo(dx + width * 0.95, dy + height * 0.9, dx + width * 0.7, dy + height * 0.9);
    path.lineTo(dx + width * 0.3, dy + height * 0.9);
    path.quadraticBezierTo(dx + width * 0.05, dy + height * 0.9, dx + width * 0.05, dy + height * 0.7);
    path.quadraticBezierTo(dx + width * 0.05, dy + height * 0.6, dx + width * 0.2, dy + height * 0.6);
    path.close();
    return path;
  }
  
  Path _getHeartPath(Size size) {
    final width = size.width * 0.7;
    final height = width * 0.9;
    final dx = (size.width - width) / 2;
    final dy = (size.height - height) / 2;

    final path = Path();
    path.moveTo(dx + width / 2, dy + height / 4);
    path.cubicTo(dx + width * 5 / 6, dy - height / 4, dx + width * 1.5, dy + height / 2, dx + width / 2, dy + height);
    path.cubicTo(dx - width / 2, dy + height / 2, dx + width / 6, dy - height / 4, dx + width / 2, dy + height / 4);
    path.close();
    return path;
  }

  Path _getStarPath(Size size) {
    final w = size.width * 0.7;
    final h = w;
    final dx = (size.width - w) / 2;
    final dy = (size.height - h) / 2;

    final path = Path();
    path.moveTo(dx + w * 0.5, dy);
    path.lineTo(dx + w * 0.618, dy + h * 0.382);
    path.lineTo(dx + w, dy + h * 0.382);
    path.lineTo(dx + w * 0.691, dy + h * 0.618);
    path.lineTo(dx + w * 0.809, dy + h);
    path.lineTo(dx + w * 0.5, dy + h * 0.764);
    path.lineTo(dx + w * 0.191, dy + h);
    path.lineTo(dx + w * 0.309, dy + h * 0.618);
    path.lineTo(dx, dy + h * 0.382);
    path.lineTo(dx + w * 0.382, dy + h * 0.382);
    path.close();
    return path;
  }

  Path _getApplePath(Size size) {
    final w = size.width * 0.6;
    final h = w;
    final dx = (size.width - w) / 2;
    final dy = (size.height - h) / 2 + size.height * 0.1;

    final path = Path();
    path.moveTo(dx + w * 0.5, dy + h * 0.1);
    path.cubicTo(dx + w * 0.9, dy - h * 0.1, dx + w * 1.1, dy + h * 0.6, dx + w * 0.5, dy + h);
    path.cubicTo(dx - w * 0.1, dy + h * 0.6, dx + w * 0.1, dy - h * 0.1, dx + w * 0.5, dy + h * 0.1);
    path.close();
    return path;
  }

  Widget _buildTopBar(AsmrLevel currentLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 28, color: Color(0xFF2D3436)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
              elevation: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Level ${_currentLevelIndex + 1}: ${currentLevel.name} ${currentLevel.emoji}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Text(
                  _phase == AsmrPhase.tracing ? 'Trace the drawing!' : (_phase == AsmrPhase.coloring ? 'Scrub to fill!' : 'Beautiful!'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (_phase == AsmrPhase.done)
            IconButton(
              onPressed: _resetLevel,
              icon: const Icon(Icons.refresh_rounded, size: 28, color: Color(0xFF2D3436)),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(10),
                elevation: 2,
              ),
            )
          else 
            const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E272E), // Sleek dark dock
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _colors.map((c) => _buildColorButton(c)).toList(),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        if (_phase != AsmrPhase.done) {
          setState(() {
            _selectedColor = color;
            HapticFeedback.selectionClick();
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: isSelected ? 1.0 : 0.0, end: isSelected ? 1.0 : 0.0),
          builder: (context, val, child) {
            return Transform.translate(
              offset: Offset(0, -15 * val), // Pops up satisfyingly when selected
              child: Container(
                width: 55.0,
                height: 55.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.5), // Specular highlight (top left)
                      color,
                      color.withValues(alpha: 0.2), // Deep shadow edge (bottom right)
                    ],
                    stops: const [0.0, 0.6, 1.0],
                    center: const Alignment(-0.3, -0.3), // Top left light source
                    radius: 0.8,
                  ),
                  boxShadow: [
                    if (val > 0)
                      BoxShadow(
                        color: color.withValues(alpha: (0.6 * val).clamp(0.0, 1.0)),
                        blurRadius: (15 * val).clamp(0.0, 50.0),
                        spreadRadius: (2 * val).clamp(0.0, 50.0),
                      ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    )
                  ],
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: (3 * val).clamp(0.0, 10.0),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Realistic 3D Sketch Pen rendered purely in Flutter Paint
class SketchPenPainter extends CustomPainter {
  final Color color;
  SketchPenPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // 1. Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3 + 8, h * 0.2 + 8, w * 0.4, h * 0.65),
        const Radius.circular(8),
      ),
      shadowPaint,
    );

    // 2. Realistic Felt Tip
    final tipPaint = Paint()
      ..color = color.withValues(alpha: 0.9) // slightly darker ink saturation
      ..style = PaintingStyle.fill;
    
    final tipPath = Path();
    tipPath.moveTo(w * 0.35, h * 0.8);
    tipPath.lineTo(w * 0.65, h * 0.8);
    tipPath.lineTo(w * 0.55, h * 0.95);
    tipPath.quadraticBezierTo(w * 0.5, h * 1.0, w * 0.45, h * 0.95); // rounded sharp tip
    tipPath.close();
    canvas.drawPath(tipPath, tipPaint);

    // 3. Silver Clip / Band near the tip
    final bandRect = Rect.fromLTWH(w * 0.3, h * 0.75, w * 0.4, h * 0.05);
    final bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7F8FA6), Color(0xFFF5F6FA), Color(0xFF7F8FA6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bandRect);
    canvas.drawRect(bandRect, bandPaint);

    // 4. Metallic/Plastic Main Body with 3D cylindrical lighting
    final bodyRect = Rect.fromLTWH(w * 0.3, h * 0.15, w * 0.4, h * 0.6);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.8), // Dark edge
          color,                        // Base color
          Colors.white.withValues(alpha: 0.9), // Bright specular highlight
          color,                        // Base color
          color.withValues(alpha: 0.6)  // Shadowed edge
        ],
        stops: const [0.0, 0.2, 0.4, 0.7, 1.0], // Position the highlight slightly left of center
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bodyRect);
    
    canvas.drawRect(bodyRect, bodyPaint); // Flat bottom connects to band

    // 5. Dark Plastic Top Cap
    final capRect = Rect.fromLTWH(w * 0.3, h * 0.05, w * 0.4, h * 0.1);
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2F3542), Color(0xFF747D8C), Color(0xFF2F3542)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(capRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        capRect, 
        topLeft: const Radius.circular(8), 
        topRight: const Radius.circular(8)
      ), 
      capPaint
    );
  }

  @override
  bool shouldRepaint(covariant SketchPenPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class AsmrPainter extends CustomPainter {
  final AsmrPhase phase;
  final double traceProgress;
  final List<Offset?> colorStrokes;
  final Color selectedColor;
  final Path path;

  AsmrPainter({
    required this.phase,
    required this.traceProgress,
    required this.colorStrokes,
    required this.selectedColor,
    required this.path,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (phase == AsmrPhase.coloring || phase == AsmrPhase.done) {
      canvas.save();
      canvas.clipPath(path);
      
      if (phase == AsmrPhase.done) {
        canvas.drawColor(selectedColor, BlendMode.srcOver);
      } else {
        final Paint fillPaint = Paint()
          ..color = selectedColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 60.0;
          
        for (int i = 0; i < colorStrokes.length - 1; i++) {
          if (colorStrokes[i] != null && colorStrokes[i + 1] != null) {
            canvas.drawLine(colorStrokes[i]!, colorStrokes[i + 1]!, fillPaint);
          } else if (colorStrokes[i] != null && colorStrokes[i + 1] == null) {
            canvas.drawPoints(PointMode.points, [colorStrokes[i]!], fillPaint);
          }
        }
      }
      canvas.restore();
    }

    final Paint outlinePaint = Paint()
      ..color = const Color(0xFF2D3436)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (phase == AsmrPhase.tracing) {
      final Paint faintPaint = Paint()
        ..color = const Color(0xFFDFE6E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      canvas.drawPath(path, faintPaint);
      
      if (traceProgress >= 0) {
        final metrics = path.computeMetrics().toList();
        if (metrics.isNotEmpty) {
          final metric = metrics.first;
          final extract = metric.extractPath(0, metric.length * traceProgress);
          canvas.drawPath(extract, outlinePaint);
          
          if (traceProgress < 1.0) {
            final tangent = metric.getTangentForOffset(metric.length * traceProgress);
            if (tangent != null) {
              canvas.drawCircle(
                tangent.position, 
                24.0, 
                Paint()..color = const Color(0xFFFF7675).withValues(alpha: 0.3)
              );
              canvas.drawCircle(
                tangent.position, 
                16.0, 
                Paint()..color = const Color(0xFFFF7675)
              );
              canvas.drawCircle(
                tangent.position, 
                8.0, 
                Paint()..color = Colors.white
              );
            }
          }
        }
      }
    } else {
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AsmrPainter oldDelegate) {
    return true; 
  }
}
