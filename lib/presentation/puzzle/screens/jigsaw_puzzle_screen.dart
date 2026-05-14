import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class JigsawPuzzleScreen extends StatefulWidget {
  final String initialAnimalTag;
  final String animalName;
  final int animalIndex;
  
  const JigsawPuzzleScreen({
    super.key, 
    this.initialAnimalTag = 'animal',
    this.animalName = 'Animal Jigsaw',
    this.animalIndex = 0,
  });

  @override
  State<JigsawPuzzleScreen> createState() => _JigsawPuzzleScreenState();
}

class _JigsawPuzzleScreenState extends State<JigsawPuzzleScreen> {
  int _gridSize = 2; // Default 2x2
  final List<int> _difficultyOptions = [2, 3, 4];
  
  late List<int?> _placedPieces;
  late List<int> _availablePieces;
  bool _isCompleted = false;
  
  String _currentImageUrl = '';
  int _unlockedLevel = 2; // 2, 3, or 4
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedLevel = prefs.getInt('jigsaw_unlocked_level') ?? 2;
    });
    _startNewGame();
  }

  Future<void> _saveProgress(int level) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save level difficulty progress (existing logic)
    int currentUnlockedLevel = prefs.getInt('jigsaw_unlocked_level') ?? 2;
    if (level > currentUnlockedLevel) {
      await prefs.setInt('jigsaw_unlocked_level', level);
      setState(() => _unlockedLevel = level);
    }
  }

  Future<void> _unlockNextAnimal() async {
    final prefs = await SharedPreferences.getInstance();
    int currentUnlockedAnimal = prefs.getInt('jigsaw_unlocked_animal_index') ?? 0;
    if (widget.animalIndex >= currentUnlockedAnimal) {
      await prefs.setInt('jigsaw_unlocked_animal_index', widget.animalIndex + 1);
    }
  }

  void _startNewGame() {
    int totalPieces = _gridSize * _gridSize;
    // Use the specific animal tag chosen by the user
    _currentImageUrl = 'https://loremflickr.com/800/800/${widget.initialAnimalTag},cartoon,illustration?random=${math.Random().nextInt(1000)}';
    
    setState(() {
      _isLoadingImage = true;
      _placedPieces = List.filled(totalPieces, null);
      _availablePieces = List.generate(totalPieces, (index) => index)..shuffle();
      _isCompleted = false;
    });
    
    // Prefetch image to ensure all pieces use the SAME redirected URL
    precacheImage(NetworkImage(_currentImageUrl), context).then((_) {
      if (mounted) setState(() => _isLoadingImage = false);
    }).catchError((_) {
      if (mounted) setState(() => _isLoadingImage = false);
    });
  }

  void _onPiecePlaced(int pieceIndex, int targetSlot) {
    if (pieceIndex == targetSlot) {
      setState(() {
        _placedPieces[targetSlot] = pieceIndex;
        _availablePieces.remove(pieceIndex);
        
        if (_availablePieces.isEmpty) {
          _isCompleted = true;
          // Unlock next difficulty level
          if (_gridSize == 2) _saveProgress(3);
          else if (_gridSize == 3) _saveProgress(4);
          
          // Unlock the next animal in the selection list
          _unlockNextAnimal();
          
          _celebrateSuccess();
        }
      });
    }
  }

  void _celebrateSuccess() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _startNewGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final puzzleSize = screenWidth * 0.85;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0F7FA), Color(0xFFE1F5FE)],
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
                
                // Difficulty Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _difficultyOptions.map((size) {
                      bool isSelected = _gridSize == size;
                      bool isLocked = size > _unlockedLevel;
                      
                      return _buildDifficultyButton(size, isSelected, isLocked);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Puzzle Board
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: puzzleSize,
                      height: puzzleSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridSize,
                        ),
                        itemCount: _gridSize * _gridSize,
                        itemBuilder: (context, index) {
                          return _buildTargetSlot(index, puzzleSize / _gridSize);
                        },
                      ),
                    ),
                    if (_isLoadingImage)
                      const CircularProgressIndicator(color: Colors.lightBlueAccent),
                  ],
                ),

                const Spacer(),

                // Pieces Tray
                if (!_isCompleted)
                  Container(
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _availablePieces.length,
                      itemBuilder: (context, index) {
                        int pieceIndex = _availablePieces[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Draggable<int>(
                            data: pieceIndex,
                            feedback: _buildPuzzlePiece(pieceIndex, puzzleSize / _gridSize, true),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildPuzzlePiece(pieceIndex, puzzleSize / _gridSize, false),
                            ),
                            child: _buildPuzzlePiece(pieceIndex, puzzleSize / _gridSize, false),
                          ),
                        );
                      },
                    ),
                  ),

                if (_isCompleted)
                  const Column(
                    children: [
                      Icon(Icons.auto_awesome, size: 60, color: Colors.orangeAccent),
                      Text(
                        'Fantastic! 🎉',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.orangeAccent),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSlot(int index, double pieceSize) {
    bool isFilled = _placedPieces[index] != null;
    
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data == index && !isFilled,
      onAcceptWithDetails: (details) => _onPiecePlaced(details.data, index),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
          ),
          child: isFilled
              ? _buildPuzzlePiece(index, pieceSize, false)
              : candidateData.isNotEmpty
                  ? Container(color: Colors.lightBlueAccent.withOpacity(0.2))
                  : null,
        );
      },
    );
  }

  Widget _buildPuzzlePiece(int index, double size, bool isDragging) {
    // Calculate which part of the image to show
    int row = index ~/ _gridSize;
    int col = index % _gridSize;
    
    // Offset for the image alignment
    double offsetX = -col * size;
    double offsetY = -row * size;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          boxShadow: isDragging ? [BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 10, offset: const Offset(0, 5))] : null,
        ),
        child: ClipPath(
          clipper: _PuzzlePieceClipper(row: row, col: col, gridSize: _gridSize),
          child: OverflowBox(
            maxWidth: size * _gridSize,
            maxHeight: size * _gridSize,
            alignment: Alignment(
              -1.0 + (col * 2 / (_gridSize - 1)), 
              -1.0 + (row * 2 / (_gridSize - 1))
            ),
            child: Image.network(
              _currentImageUrl,
              width: size * _gridSize,
              height: size * _gridSize,
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
              },
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/learning_world.png',
                width: size * _gridSize,
                height: size * _gridSize,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(int size, bool isSelected, bool isLocked) {
    String label = '';
    IconData icon;
    Color color;

    switch (size) {
      case 2: label = 'Baby'; icon = Icons.child_care; color = Colors.greenAccent; break;
      case 3: label = 'Toddler'; icon = Icons.face; color = Colors.orangeAccent; break;
      case 4: label = 'Expert'; icon = Icons.school; color = Colors.purpleAccent; break;
      default: label = 'Easy'; icon = Icons.star; color = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: isLocked ? null : () {
        setState(() {
          _gridSize = size;
          _startNewGame();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade200 : (isSelected ? color : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isLocked ? Icons.lock : icon, size: 18, color: isLocked ? Colors.grey : (isSelected ? Colors.white : color)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isLocked ? Colors.grey : (isSelected ? Colors.white : Colors.black87),
              ),
            ),
          ],
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
          Expanded(
            child: Text(
              widget.animalName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF334E68)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzlePieceClipper extends CustomClipper<Path> {
  final int row;
  final int col;
  final int gridSize;

  _PuzzlePieceClipper({required this.row, required this.col, required this.gridSize});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;
    double tabSize = w * 0.2;

    path.moveTo(0, 0);

    // Top edge
    if (row > 0) {
      path.lineTo(w * 0.35, 0);
      path.arcToPoint(Offset(w * 0.65, 0), radius: Radius.circular(tabSize), clockwise: false);
    }
    path.lineTo(w, 0);

    // Right edge
    if (col < gridSize - 1) {
      path.lineTo(w, h * 0.35);
      path.arcToPoint(Offset(w, h * 0.65), radius: Radius.circular(tabSize), clockwise: true);
    }
    path.lineTo(w, h);

    // Bottom edge
    if (row < gridSize - 1) {
      path.lineTo(w * 0.65, h);
      path.arcToPoint(Offset(w * 0.35, h), radius: Radius.circular(tabSize), clockwise: true);
    }
    path.lineTo(0, h);

    // Left edge
    if (col > 0) {
      path.lineTo(0, h * 0.65);
      path.arcToPoint(Offset(0, h * 0.35), radius: Radius.circular(tabSize), clockwise: false);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
