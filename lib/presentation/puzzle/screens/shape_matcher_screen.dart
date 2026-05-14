import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class ShapeMatcherScreen extends StatefulWidget {
  const ShapeMatcherScreen({super.key});

  @override
  State<ShapeMatcherScreen> createState() => _ShapeMatcherScreenState();
}

class _ShapeMatcherScreenState extends State<ShapeMatcherScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  final List<Map<String, dynamic>> _allShapes = [
    {'icon': Icons.star_rounded, 'color': Colors.amber, 'label': 'Star'},
    {'icon': Icons.favorite_rounded, 'color': Colors.pinkAccent, 'label': 'Heart'},
    {'icon': Icons.circle_rounded, 'color': Colors.lightBlueAccent, 'label': 'Circle'},
    {'icon': Icons.square_rounded, 'color': Colors.orangeAccent, 'label': 'Square'},
    {'icon': Icons.change_history_rounded, 'color': Colors.lightGreenAccent, 'label': 'Triangle'},
  ];

  late List<Map<String, dynamic>> _currentLevelShapes;
  final Map<int, bool> _placedShapes = {};
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateLevel();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  void _generateLevel() {
    setState(() {
      _currentLevelShapes = List.from(_allShapes)..shuffle();
      _currentLevelShapes = _currentLevelShapes.take(3).toList();
      _placedShapes.clear();
      _isCompleted = false;
    });
  }

  void _onSuccess() async {
    // Play success sound
    // await _audioPlayer.play(AssetSource('audio/sparkle.mp3'));
    
    setState(() {
      _isCompleted = true;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _generateLevel();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                const Text(
                  'Match the magic shapes!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334E68),
                  ),
                ),
                const Spacer(),

                // Drag Targets (Holes)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_currentLevelShapes.length, (index) {
                    final shape = _currentLevelShapes[index];
                    final isPlaced = _placedShapes[index] ?? false;

                    return DragTarget<int>(
                      onWillAcceptWithDetails: (details) => details.data == index && !isPlaced,
                      onAcceptWithDetails: (details) {
                        setState(() {
                          _placedShapes[index] = true;
                        });
                        if (_placedShapes.length == _currentLevelShapes.length) {
                          _onSuccess();
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            color: isPlaced 
                                ? shape['color'].withOpacity(0.2) 
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: candidateData.isNotEmpty 
                                  ? shape['color'] 
                                  : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              shape['icon'],
                              size: screenWidth * 0.15,
                              color: isPlaced 
                                  ? shape['color'] 
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const Spacer(),

                // Draggable Pieces
                if (!_isCompleted)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_currentLevelShapes.length, (index) {
                      final shape = _currentLevelShapes[index];
                      if (_placedShapes[index] == true) return const SizedBox(width: 80);

                      return Draggable<int>(
                        data: index,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _buildShapePiece(shape, screenWidth * 0.22, true),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildShapePiece(shape, screenWidth * 0.22, false),
                        ),
                        child: _buildShapePiece(shape, screenWidth * 0.22, false),
                      );
                    })..shuffle(_random),
                  ),

                if (_isCompleted)
                  const Column(
                    children: [
                      Icon(Icons.auto_awesome, size: 80, color: Colors.amber),
                      Text(
                        'Amazing! ✨',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapePiece(Map<String, dynamic> shape, double size, bool isDragging) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shape['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shape['color'].withOpacity(0.4),
            blurRadius: isDragging ? 20 : 10,
            offset: Offset(0, isDragging ? 10 : 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          shape['icon'],
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Color(0xFF334E68), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Shape Matcher 🌟',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF334E68)),
            ),
          ),
        ],
      ),
    );
  }
}
