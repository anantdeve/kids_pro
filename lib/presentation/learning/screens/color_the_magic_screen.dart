import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ColorTheMagicScreen extends StatefulWidget {
  const ColorTheMagicScreen({super.key});

  @override
  State<ColorTheMagicScreen> createState() => _ColorTheMagicScreenState();
}

class _ColorTheMagicScreenState extends State<ColorTheMagicScreen> {
  List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  Color selectedColor = const Color(0xFFFF4848); // Initial Red
  double strokeWidth = 5.0;
  String currentTool = 'pencil'; // 'pencil' or 'crayon'

  final List<ColoringObject> objects = [
    ColoringObject(name: 'BANANA', colorName: 'YELLOW', color: const Color(0xFFFFE000), imagePath: 'assets/images/banana_outline.png'),
    ColoringObject(name: 'APPLE', colorName: 'RED', color: const Color(0xFFFF4848), imagePath: 'assets/images/apple_outline.png'),
    ColoringObject(name: 'GRAPES', colorName: 'PURPLE', color: const Color(0xFF9000D4), imagePath: 'assets/images/grapes_outline.png'),
    ColoringObject(name: 'LEAF', colorName: 'GREEN', color: const Color(0xFF00C34F), imagePath: 'assets/images/leaf_outline.png'),
    ColoringObject(name: 'ORANGE', colorName: 'ORANGE', color: const Color(0xFFFF8B66), imagePath: 'assets/images/orange_outline.png'),
  ];

  late ColoringObject currentObject;

  final List<Color> palette = [
    const Color(0xFFFF4848), // Red
    const Color(0xFF0091FF), // Blue
    const Color(0xFF00C34F), // Green
    const Color(0xFFFFE000), // Yellow
    const Color(0xFF9000D4), // Purple
    const Color(0xFFFF007A), // Pink
  ];

  @override
  void initState() {
    super.initState();
    currentObject = objects[0];
  }

  void _generateNewObject() {
    setState(() {
      lines.clear();
      final currentIndex = objects.indexOf(currentObject);
      int nextIndex;
      do {
        nextIndex = (currentIndex + 1 + (DateTime.now().millisecond % (objects.length - 1))) % objects.length;
      } while (nextIndex == currentIndex);
      currentObject = objects[nextIndex];
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      currentLine = DrawnLine(
        path: [details.localPosition],
        color: selectedColor,
        width: currentTool == 'pencil' ? 5.0 : 15.0,
        opacity: currentTool == 'pencil' ? 1.0 : 0.6,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (currentLine == null) return;
    setState(() {
      currentLine!.path.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (currentLine == null) return;
    setState(() {
      lines.add(currentLine!);
      currentLine = null;
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
                            const Text(
                              'Draw and Color!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF8B66),
                                  Color(0xFFFFB6C1),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'COLOR THE MAGIC',
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
                      IconButton(
                        onPressed: () {
                          if (lines.isNotEmpty) {
                            setState(() => lines.removeLast());
                          }
                        },
                        icon: const Icon(Icons.undo, color: Color(0xFFFF8B66)),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => lines.clear());
                        },
                        icon: const Icon(Icons.delete_sweep, color: Color(0xFFFF4848)),
                      ),
                    ],
                  ),
                ),

                // Subtitle Tooltip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      children: [
                        const TextSpan(text: 'Color the ', style: TextStyle(color: Color(0xFFBBBBBB))),
                        TextSpan(text: '${currentObject.name} ', style: TextStyle(color: currentObject.color)),
                        const TextSpan(text: 'with ', style: TextStyle(color: Color(0xFFBBBBBB))),
                        TextSpan(text: '${currentObject.colorName}!', style: TextStyle(color: currentObject.color)),
                      ],
                    ),
                  ),
                ),

                // Canvas Area
                Expanded(
                  child: Stack(
                    children: [
                      // Outline
                      Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Image.asset(
                            currentObject.imagePath,
                            width: 300,
                            fit: BoxFit.contain,
                            key: ValueKey(currentObject.imagePath),
                            errorBuilder: (c, e, s) => const Icon(Icons.bakery_dining_outlined, size: 200),
                          ),
                        ),
                      ),
                      
                      // Drawing Canvas
                      Positioned.fill(
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            painter: DrawingPainter(lines: lines, currentLine: currentLine),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _buildToolButton('Pencil', Icons.edit_note, 'pencil'),
                          const SizedBox(width: 20),
                          _buildToolButton('Crayon', Icons.brush, 'crayon'),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _generateNewObject,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('New Object'),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE8E0),
                              foregroundColor: const Color(0xFFFF8B66),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: palette.length,
                          separatorBuilder: (c, i) => const SizedBox(width: 16),
                          itemBuilder: (c, i) {
                            final color = palette[i];
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: isSelected 
                                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                                  : null,
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
        ],
      ),
    );
  }

  Widget _buildToolButton(String label, IconData icon, String toolId) {
    final isSelected = currentTool == toolId;
    return GestureDetector(
      onTap: () => setState(() => currentTool = toolId),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF8B66) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isSelected ? Colors.white : Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFFF8B66) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class ColoringObject {
  final String name;
  final String colorName;
  final Color color;
  final String imagePath;

  ColoringObject({
    required this.name,
    required this.colorName,
    required this.color,
    required this.imagePath,
  });
}

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;
  final double opacity;

  DrawnLine({
    required this.path,
    required this.color,
    required this.width,
    required this.opacity,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DrawingPainter({required this.lines, this.currentLine});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      _drawLine(canvas, line);
    }
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    if (line.path.isEmpty) return;
    final paint = Paint()
      ..color = line.color.withValues(alpha: line.opacity)
      ..strokeWidth = line.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(line.path[0].dx, line.path[0].dy);
    for (var i = 1; i < line.path.length; i++) {
      path.lineTo(line.path[i].dx, line.path[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
