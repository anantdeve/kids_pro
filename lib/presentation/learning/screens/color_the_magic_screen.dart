import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double strokeWidth = 8.0;
  String currentTool = 'pencil'; // 'pencil', 'crayon', or 'move'
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _canvasKey = GlobalKey();
  ui.Image? _maskImage;
  bool _isLoadingMask = false;

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
    _loadMaskImage(currentObject.imagePath);
  }

  Future<void> _loadMaskImage(String assetPath) async {
    setState(() => _isLoadingMask = true);
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      setState(() {
        _maskImage = fi.image;
        _isLoadingMask = false;
      });
    } catch (e) {
      setState(() => _isLoadingMask = false);
    }
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
      _loadMaskImage(currentObject.imagePath);
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (currentTool == 'move' || _isLoadingMask) return;
    
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localPoint = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      currentLine = DrawnLine(
        path: [localPoint],
        color: selectedColor,
        width: strokeWidth,
        opacity: currentTool == 'pencil' ? 1.0 : 0.6,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (currentLine == null || currentTool == 'move' || _isLoadingMask) return;
    
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localPoint = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      currentLine!.path.add(localPoint);
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
                                  Color(0xFFFF8B66),
                                  Color(0xFFFFB6C1),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'COLOR THE OBJECT',
                                style: TextStyle(
                                  fontSize: 18, // Matching other screens
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5, // Matching other screens
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

                const SizedBox(height: 10),

                // Canvas Area (Masked Drawing Engine)
                Expanded(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    maxScale: 4.0,
                    minScale: 1.0,
                    panEnabled: currentTool == 'move',
                    scaleEnabled: currentTool == 'move',
                    boundaryMargin: const EdgeInsets.all(200),
                    child: IgnorePointer(
                      ignoring: currentTool == 'move',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Stack(
                          key: _canvasKey,
                          alignment: Alignment.center,
                          children: [
                            // 1. Outline (Background)
                            Opacity(
                              opacity: 0.1,
                              child: Image.asset(
                                currentObject.imagePath,
                                width: 300,
                                fit: BoxFit.contain,
                                key: ValueKey(currentObject.imagePath),
                              ),
                            ),
                            
                            // 2. Drawing Canvas (With Masking)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DrawingPainter(
                                  lines: lines, 
                                  currentLine: currentLine,
                                  maskImage: _maskImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: const [
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
                          const SizedBox(width: 12),
                          _buildToolButton('Crayon', Icons.brush, 'crayon'),
                          const SizedBox(width: 12),
                          _buildToolButton('Move', Icons.back_hand, 'move'),
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
                      const SizedBox(height: 20),
                      // Brush Size Slider
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.grey[400]),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                activeTrackColor: const Color(0xFFFF8B66),
                                inactiveTrackColor: const Color(0xFFEEEEEE),
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
                                overlayColor: const Color(0xFFFF8B66).withValues(alpha: 0.1),
                              ),
                              child: Slider(
                                value: strokeWidth,
                                min: 2.0,
                                max: 30.0,
                                onChanged: (value) => setState(() => strokeWidth = value),
                              ),
                            ),
                          ),
                          Icon(Icons.circle, size: 24, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 20),
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
              color: isSelected ? const Color(0xFFFF8B66) : (Theme.of(context).scaffoldBackgroundColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: isSelected ? Colors.white : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFFF8B66) : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54),
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
  final ui.Image? maskImage;

  DrawingPainter({
    required this.lines, 
    this.currentLine,
    this.maskImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (maskImage == null) return;

    // Create a layer for masking
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Draw all coloring lines
    for (var line in lines) {
      _drawLine(canvas, line);
    }
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }

    // Apply the mask (Object boundary)
    // This will keep only the parts of the lines that overlap the opaque object
    final paint = Paint()..blendMode = ui.BlendMode.dstIn;
    
    // Calculate scaling to fit image in the 300x300 center area
    const double targetDim = 300;
    final double scale = targetDim / (maskImage!.width > maskImage!.height ? maskImage!.width : maskImage!.height);
    final double dx = (size.width - maskImage!.width * scale) / 2;
    final double dy = (size.height - maskImage!.height * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawImage(maskImage!, Offset.zero, paint);
    canvas.restore();

    canvas.restore();
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
