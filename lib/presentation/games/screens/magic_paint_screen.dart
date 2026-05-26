import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/child_standard_provider.dart';
import '../../../../domain/entities/child_standard.dart';

class MagicPaintScreen extends ConsumerStatefulWidget {
  const MagicPaintScreen({super.key});

  @override
  ConsumerState<MagicPaintScreen> createState() => _MagicPaintScreenState();
}

class _MagicPaintScreenState extends ConsumerState<MagicPaintScreen> {
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.red;
  double strokeWidth = 5.0;
  double opacity = 1.0;
  bool isEraser = false;
  final GlobalKey _canvasKey = GlobalKey();
  int? activePointerId;

  final List<Color> colors = [
    const Color(0xFFFF3D41), // Red
    const Color(0xFFFF914D), // Orange
    const Color(0xFFFFDE59), // Yellow
    const Color(0xFF00FF00), // Green
    const Color(0xFF00FFFF), // Cyan
    const Color(0xFF38B6FF), // Blue
    const Color(0xFF7D3CFF), // Purple
    const Color(0xFFFF31B2), // Pink
  ];

  final Map<String, double> sizes = {
    'S': 3.0,
    'M': 8.0,
    'L': 15.0,
    'XL': 25.0,
  };

  String selectedSize = 'M';

  @override
  void initState() {
    super.initState();
    strokeWidth = sizes[selectedSize]!;
  }

  void _undo() {
    setState(() {
      if (points.isNotEmpty) {
        // Find the last null (end of a stroke) and remove everything after it, then remove the null itself
        int lastNull = points.lastIndexOf(null);
        if (lastNull == points.length - 1) {
          // If the last point is null, find the one before it
          points.removeLast();
          lastNull = points.lastIndexOf(null);
        }
        points.removeRange(lastNull + 1, points.length);
      }
    });
  }

  void _clear() {
    setState(() {
      points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Listener(
                onPointerDown: (event) {
                  if (activePointerId != null) return;
                  
                  final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox == null) return;
                  
                  setState(() {
                    activePointerId = event.pointer;
                    points.add(DrawingPoint(
                      offset: renderBox.globalToLocal(event.position),
                      paint: Paint()
                        ..color = (isEraser ? Colors.white : selectedColor).withValues(alpha: opacity)
                        ..strokeCap = StrokeCap.round
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true,
                    ));
                  });
                },
                onPointerMove: (event) {
                  if (event.pointer != activePointerId) return;
                  
                  final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox == null) return;
                  
                  setState(() {
                    points.add(DrawingPoint(
                      offset: renderBox.globalToLocal(event.position),
                      paint: Paint()
                        ..color = (isEraser ? Colors.white : selectedColor).withValues(alpha: opacity)
                        ..strokeCap = StrokeCap.round
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true,
                    ));
                  });
                },
                onPointerUp: (event) {
                  if (event.pointer == activePointerId) {
                    setState(() {
                      activePointerId = null;
                      points.add(null);
                    });
                  }
                },
                onPointerCancel: (event) {
                  if (event.pointer == activePointerId) {
                    setState(() {
                      activePointerId = null;
                      points.add(null);
                    });
                  }
                },
                child: CustomPaint(
                  key: _canvasKey,
                  size: Size.infinite,
                  painter: DrawingPainter(pointsList: points),
                ),
              ),
            ),
            _buildBottomControls(ref.watch(childStandardProvider).value ?? ChildStandard.standard1),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFF1EB),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Creative Corner 🎨',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo_rounded, color: Color(0xFF2D3436), size: 22),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7675), size: 22),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(ChildStandard standard) {
    bool isStandard1 = standard == ChildStandard.standard1;
    bool isStandard3 = standard == ChildStandard.standard3;
    
    // Standard 1: Basic colors only
    List<Color> availableColors = isStandard1 ? colors.take(4).toList() : colors;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tools and Sizes
          Row(
            children: [
              // Pencil/Wand Toggle (Hide wand for standard 1)
              if (!isStandard1)
                Flexible(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildToolButton(Icons.edit_rounded, !isEraser, () {
                            setState(() => isEraser = false);
                          }),
                          _buildToolButton(Icons.auto_fix_high_rounded, isEraser, () {
                            setState(() => isEraser = true);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!isStandard1) const Spacer(),
              // Size Selection (Standard 1 only has thick sizes)
              Flexible(
                flex: isStandard1 ? 7 : 4,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: isStandard1 ? Alignment.center : Alignment.centerRight,
                  child: Row(
                    children: sizes.keys
                        .where((s) => !isStandard1 || (s == 'L' || s == 'XL'))
                        .map((s) => _buildSizeButton(s, standard))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Colors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableColors.map((c) => _buildColorButton(c, standard)).toList(),
            ),
          ),
          // Standard 3: Advanced Tools (Opacity)
          if (isStandard3) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.opacity_rounded, color: Colors.grey, size: 20),
                Expanded(
                  child: Slider(
                    value: opacity,
                    min: 0.1,
                    max: 1.0,
                    activeColor: selectedColor,
                    onChanged: (val) {
                      setState(() {
                        opacity = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFFF7A59) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSizeButton(String label, ChildStandard standard) {
    bool isSelected = selectedSize == label;
    bool isStandard1 = standard == ChildStandard.standard1;
    double size = isStandard1 ? 50.0 : 40.0; // Larger for standard 1

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = label;
          strokeWidth = sizes[label]!;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? const Color(0xFFFF7A59) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF7A59) : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: isStandard1 ? 18 : 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, ChildStandard standard) {
    bool isSelected = selectedColor == color && !isEraser;
    bool isStandard1 = standard == ChildStandard.standard1;
    bool isStandard3 = standard == ChildStandard.standard3;
    
    double size = isStandard1 ? 48.0 : (isStandard3 ? 32.0 : 38.0); // Adjust sizes

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          isEraser = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.black.withValues(alpha: 0.2) : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> pointsList;

  DrawingPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i]!.offset,
          pointsList[i + 1]!.offset,
          pointsList[i]!.paint,
        );
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        canvas.drawPoints(
          PointMode.points,
          [pointsList[i]!.offset],
          pointsList[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
