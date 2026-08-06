import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/providers/user_provider.dart';

class ColorTheMagicScreen extends ConsumerStatefulWidget {
  const ColorTheMagicScreen({super.key});

  @override
  ConsumerState<ColorTheMagicScreen> createState() => _ColorTheMagicScreenState();
}

class _ColorTheMagicScreenState extends ConsumerState<ColorTheMagicScreen> {
  List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  Color selectedColor = const Color(0xFFFF4848); // Initial Red
  double strokeWidth = 8.0;
  String currentTool = 'pencil'; // 'pencil', 'crayon', or 'move'
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _maskImage;
  bool _isLoadingMask = false;
  bool _isCompleted = false;

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
    const Color(0xFFFF8B66), // Orange
    const Color(0xFFFFE000), // Yellow
    const Color(0xFF00C34F), // Green
    const Color(0xFF00B4D8), // Cyan
    const Color(0xFF0091FF), // Blue
    const Color(0xFF9000D4), // Purple
    const Color(0xFFFF007A), // Pink
    const Color(0xFF8D6E63), // Brown
    const Color(0xFFE0E0E0), // Light Grey
    const Color(0xFF2D3142), // Dark/Black
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
      // Downscale to 300px for fast processing
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 300);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image rawImage = fi.image;
      
      final ByteData? rgbaData = await rawImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgbaData == null) {
        setState(() => _isLoadingMask = false);
        return;
      }
      final Uint8List pixels = rgbaData.buffer.asUint8List();
      
      final int width = rawImage.width;
      final int height = rawImage.height;
      
      final List<bool> visited = List.filled(width * height, false);
      final Int32List queueX = Int32List(width * height);
      final Int32List queueY = Int32List(width * height);
      int head = 0;
      int tail = 0;
      
      bool isBorder(int idx) {
        int offset = idx * 4;
        int r = pixels[offset];
        int g = pixels[offset + 1];
        int b = pixels[offset + 2];
        int a = pixels[offset + 3];
        if (a < 20) return false; // Transparent is not border
        if ((r + g + b) / 3 > 220) return false; // White is not border
        return true; // Dark lines
      }
      
      void tryEnqueue(int x, int y) {
        int idx = y * width + x;
        if (!visited[idx]) {
          if (!isBorder(idx)) {
            visited[idx] = true;
            queueX[tail] = x;
            queueY[tail] = y;
            tail++;
          }
        }
      }

      // Enqueue edges
      for (int x = 0; x < width; x++) {
        tryEnqueue(x, 0);
        tryEnqueue(x, height - 1);
      }
      for (int y = 0; y < height; y++) {
        tryEnqueue(0, y);
        tryEnqueue(width - 1, y);
      }
      
      // BFS
      final dx = [0, 0, -1, 1];
      final dy = [-1, 1, 0, 0];
      while (head < tail) {
        int cx = queueX[head];
        int cy = queueY[head];
        head++;
        for (int i = 0; i < 4; i++) {
          int nx = cx + dx[i];
          int ny = cy + dy[i];
          if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
            tryEnqueue(nx, ny);
          }
        }
      }
      
      // Build mask: transparent outside, opaque white inside
      final Uint8List maskPixels = Uint8List(width * height * 4);
      for (int i = 0; i < width * height; i++) {
        int offset = i * 4;
        if (visited[i]) {
          maskPixels[offset] = 0;
          maskPixels[offset + 1] = 0;
          maskPixels[offset + 2] = 0;
          maskPixels[offset + 3] = 0;
        } else {
          maskPixels[offset] = 255;
          maskPixels[offset + 1] = 255;
          maskPixels[offset + 2] = 255;
          maskPixels[offset + 3] = 255;
        }
      }
      
      ui.decodeImageFromPixels(maskPixels, width, height, ui.PixelFormat.rgba8888, (ui.Image mask) {
        if (mounted) {
          setState(() {
            _maskImage = mask;
            _isLoadingMask = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMask = false);
      }
    }
  }

  void _generateNewObject() {
    setState(() {
      lines.clear();
      _isCompleted = false;
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
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_isCompleted) return;
    
    int totalPoints = 0;
    for (var line in lines) {
      totalPoints += line.path.length;
    }
    
    // A decent scribble to fill an object usually takes > 400 points
    if (totalPoints > 400) {
      _isCompleted = true;
      _showSuccessEffect();
    }
  }

  void _showSuccessEffect() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            elevation: 0,
            content: Container(
              width: 340,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.6), blurRadius: 30, spreadRadius: 10, offset: const Offset(0, 15)),
                  BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2, offset: const Offset(-3, -3)),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 90, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 4))]),
                  const SizedBox(height: 20),
                  const Text(
                    'AMAZING!',
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white,
                      letterSpacing: 2.5,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 3))],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Beautiful Artwork! 🎉',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.deepOrange.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF8F00),
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _generateNewObject();
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 30),
                      label: const Text(
                        'NEXT LEVEL',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveArtwork() async {
    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Artwork?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Do you want to save this beautiful artwork to your gallery?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8B66),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      try {
        RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final directory = await getApplicationDocumentsDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filePath = '${directory.path}/artwork_$timestamp.png';
        final File imgFile = File(filePath);
        await imgFile.writeAsBytes(pngBytes);

        await ref.read(userProvider.notifier).addArtwork(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Artwork saved! Check your profile.', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to save artwork.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                      IconButton(
                        onPressed: _saveArtwork,
                        icon: const Icon(Icons.save_alt_rounded, color: Colors.green),
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
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: Container(
                            color: Colors.transparent, // Background for the captured image
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
                          ElevatedButton.icon(
                            onPressed: () {
                              if (!_isCompleted) {
                                setState(() => _isCompleted = true);
                                _showSuccessEffect();
                              }
                            },
                            icon: const Icon(Icons.star_rounded, size: 24),
                            label: const Text('I\'m Done!', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8B66),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
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
