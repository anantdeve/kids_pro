import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'dart:ui';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';

class JigsawPuzzleScreen extends ConsumerStatefulWidget {
  final String initialAnimalTag;
  final String animalName;
  final int animalIndex;
  final int initialGridSize;
  
  const JigsawPuzzleScreen({
    super.key, 
    this.initialAnimalTag = 'animal',
    this.animalName = 'Animal Jigsaw',
    this.animalIndex = 0,
    this.initialGridSize = 2,
  });

  @override
  ConsumerState<JigsawPuzzleScreen> createState() => _JigsawPuzzleScreenState();
}

class _JigsawPuzzleScreenState extends ConsumerState<JigsawPuzzleScreen> {
  late int _gridSize;
  
  late List<int?> _placedPieces;
  late List<int> _availablePieces;
  bool _isCompleted = false;
  
  String _currentImageUrl = '';
  bool _isLoadingImage = true;
  
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _gridSize = widget.initialGridSize;
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    _currentImageUrl = 'assets/images/jigsaw_${widget.initialAnimalTag}.png';
    
    setState(() {
      _isLoadingImage = false;
      _placedPieces = List.filled(totalPieces, null);
      _availablePieces = List.generate(totalPieces, (index) => index)..shuffle();
      _isCompleted = false;
      _elapsedSeconds = 0;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isCompleted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _onPiecePlaced(int pieceIndex, int targetSlot) {
    if (pieceIndex == targetSlot) {
      setState(() {
        _placedPieces[targetSlot] = pieceIndex;
        _availablePieces.remove(pieceIndex);
        
        if (_availablePieces.isEmpty) {
          _isCompleted = true;
          _timer?.cancel();
          
          // Calculate stars based on elapsed seconds
          int earnedStars = 0;
          int deduction = 0;
          if (_elapsedSeconds <= 10) {
            earnedStars = 3;
            // Optionally reward points for fast completion, but focusing on deduction per requirement.
          } else if (_elapsedSeconds <= 20) {
            earnedStars = 2;
          } else if (_elapsedSeconds <= 30) {
            earnedStars = 1;
          } else {
            // Deduct 2 points for every 10 seconds over 30s
            int additionalSeconds = _elapsedSeconds - 30;
            int penaltyBlocks = (additionalSeconds / 10).ceil();
            deduction = penaltyBlocks * 2;
            ref.read(userProvider.notifier).addPoints('Puzzle', -deduction);
          }
          
          // Unlock the next animal in the selection list
          _unlockNextAnimal();
          
          _showSuccessCard(earnedStars, _elapsedSeconds, deduction);
        }
      });
    }
  }

  void _showSuccessCard(int earnedStars, int timeTaken, int deduction) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            elevation: 0,
            content: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 290, 
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20), 
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          bool isEarned = index < earnedStars;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == 1 ? 16.0 : 0.0,
                              left: 6.0,
                              right: 6.0,
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              size: index == 1 ? 70 : 55, 
                              color: isEarned ? Colors.amberAccent : Colors.white.withValues(alpha: 0.3),
                              shadows: isEarned 
                                  ? [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(2, 3))] 
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    deduction > 0 ? 'GOOD TRY!' : 'AMAZING!',
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deduction > 0
                      ? 'Time: ${timeTaken}s\nYou finished, but lost $deduction points! 📉'
                      : 'Time: ${timeTaken}s\nYou solved it! 🎉',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22), 
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF8F00),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        context.popWithSound(); // close dialog
                        context.popWithSound(); // go back to list
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
        ),
      ),
    );
  },
);
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
                
                const SizedBox(height: 20),

                // Puzzle Board
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: puzzleSize,
                      height: puzzleSize,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(_gridSize * _gridSize, (index) {
                          int row = index ~/ _gridSize;
                          int col = index % _gridSize;
                          double pSize = puzzleSize / _gridSize;
                          return Positioned(
                            left: col * pSize,
                            top: row * pSize,
                            width: pSize,
                            height: pSize,
                            child: _buildTargetSlot(index, pSize, row, col),
                          );
                        }),
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
                          padding: const EdgeInsets.all(24.0),
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
                  const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSlot(int index, double pieceSize, int row, int col) {
    bool isFilled = _placedPieces[index] != null;
    Color borderColor = isFilled ? Colors.transparent : Colors.grey.withValues(alpha: 0.6);
    
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data == index && !isFilled,
      onAcceptWithDetails: (details) => _onPiecePlaced(details.data, index),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: isFilled ? Colors.transparent : Colors.white.withValues(alpha: 0.4),
            border: Border(
              top: row == 0 ? BorderSide.none : BorderSide(color: borderColor, width: 1.5),
              left: col == 0 ? BorderSide.none : BorderSide(color: borderColor, width: 1.5),
              bottom: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          child: isFilled
              ? _buildPuzzlePiece(index, pieceSize, false)
              : candidateData.isNotEmpty
                  ? Container(color: Colors.lightBlueAccent.withValues(alpha: 0.5))
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
          boxShadow: isDragging ? [BoxShadow(color: Colors.black.withValues(alpha: 0.24), blurRadius: 10, offset: const Offset(0, 5))] : null,
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
            child: Image.asset(
              _currentImageUrl,
              width: size * _gridSize,
              height: size * _gridSize,
              fit: BoxFit.fill,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.popWithSound(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: Colors.orangeAccent, size: 24),
                const SizedBox(width: 6),
                Text(
                  '${_elapsedSeconds}s',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF334E68)),
                ),
              ],
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
