import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/widgets/magical_blob.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning/widgets/success_overlay.dart';

enum ArrowDirection { up, down, left, right }
enum ArrowDifficulty { easy, medium, hard }

class BlockWidgetData {
  final int id;
  int r;
  int c;
  final ArrowDirection dir;
  final Color color;
  bool isEscaping = false;
  bool isBumping = false;

  BlockWidgetData({
    required this.id,
    required this.r,
    required this.c,
    required this.dir,
    required this.color,
  });
}

class ArrowEscapeScreen extends StatefulWidget {
  final ArrowDifficulty difficulty;
  final int startLevel;
  
  const ArrowEscapeScreen({super.key, required this.difficulty, required this.startLevel});

  @override
  State<ArrowEscapeScreen> createState() => _ArrowEscapeScreenState();
}

class _ArrowEscapeScreenState extends State<ArrowEscapeScreen> {
  late int _gridSize;
  final Random _random = Random();
  int _idCounter = 0;
  
  late List<List<BlockWidgetData?>> _grid;
  final List<BlockWidgetData> _activeBlocks = [];
  int _score = 0;
  late int _level;
  bool _isGenerating = false;
  bool _isLevelComplete = false;

  final List<Color> _blockColors = [
    const Color(0xFFFF7B9C),
    const Color(0xFF5CD6A1),
    const Color(0xFF67E1F5),
    const Color(0xFFFFB347),
    const Color(0xFFB497FF),
    const Color(0xFF6A8EAE),
  ];

  @override
  void initState() {
    super.initState();
    _level = widget.startLevel;
    
    if (widget.difficulty == ArrowDifficulty.easy) {
      _gridSize = 5;
    } else if (widget.difficulty == ArrowDifficulty.medium) {
      _gridSize = 6;
    } else {
      _gridSize = 7;
    }
    
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      _isGenerating = true;
      _activeBlocks.clear();
      _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, null));
    });

    // Start placing blocks in reverse order
    int blocksToPlace;
    if (widget.difficulty == ArrowDifficulty.easy) {
      blocksToPlace = 5 + (_level * 1);
    } else if (widget.difficulty == ArrowDifficulty.medium) {
      blocksToPlace = 10 + (_level * 2);
    } else {
      blocksToPlace = 15 + (_level * 3);
    }
    
    if (blocksToPlace > _gridSize * _gridSize) blocksToPlace = _gridSize * _gridSize;
    
    int placed = 0;
    int attempts = 0;
    
    while (placed < blocksToPlace && attempts < 200) {
      List<Point<int>> emptyCells = [];
      for (int r = 0; r < _gridSize; r++) {
        for (int c = 0; c < _gridSize; c++) {
          if (_grid[r][c] == null) {
            emptyCells.add(Point(r, c));
          }
        }
      }
      
      emptyCells.shuffle(_random);
      bool placedThisTurn = false;
      
      for (var cell in emptyCells) {
        List<ArrowDirection> clearDirs = [];
        for (var dir in ArrowDirection.values) {
          if (_isPathClear(cell.x, cell.y, dir)) {
            clearDirs.add(dir);
          }
        }
        
        if (clearDirs.isNotEmpty) {
          final dir = clearDirs[_random.nextInt(clearDirs.length)];
          final color = _blockColors[_random.nextInt(_blockColors.length)];
          final newBlock = BlockWidgetData(
            id: ++_idCounter,
            r: cell.x,
            c: cell.y,
            dir: dir,
            color: color,
          );
          _grid[cell.x][cell.y] = newBlock;
          _activeBlocks.add(newBlock);
          placed++;
          placedThisTurn = true;
          break;
        }
      }
      
      if (!placedThisTurn) break; // board is too full to guarantee solve
      attempts++;
    }

    setState(() {
      _isGenerating = false;
    });
  }

  bool _isPathClear(int r, int c, ArrowDirection dir) {
    if (dir == ArrowDirection.up) {
      for (int i = r - 1; i >= 0; i--) {
        if (_grid[i][c] != null) return false;
      }
    } else if (dir == ArrowDirection.down) {
      for (int i = r + 1; i < _gridSize; i++) {
        if (_grid[i][c] != null) return false;
      }
    } else if (dir == ArrowDirection.left) {
      for (int i = c - 1; i >= 0; i--) {
        if (_grid[r][i] != null) return false;
      }
    } else if (dir == ArrowDirection.right) {
      for (int i = c + 1; i < _gridSize; i++) {
        if (_grid[r][i] != null) return false;
      }
    }
    return true;
  }

  void _handleTap(BlockWidgetData block) async {
    if (block.isEscaping || block.isBumping) return; // Prevent double tap

    bool canEscape = _isPathClear(block.r, block.c, block.dir);

    if (canEscape) {
      setState(() {
        block.isEscaping = true;
        _grid[block.r][block.c] = null; 
        _score += 10;
      });
      
      // Clean up the block from the widget tree after the animation finishes
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _activeBlocks.remove(block);
          });
        }
      });

      // Check win condition
      if (_grid.every((row) => row.every((cell) => cell == null))) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _showLevelComplete();
        });
      }
    } else {
      // Bump animation
      setState(() {
        block.isBumping = true;
      });
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          block.isBumping = false;
        });
      }
    }
  }

  void _showLevelComplete() {
    setState(() {
      _isLevelComplete = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBoardWidth = min(screenWidth * 0.9, 400.0);
    final cellSize = maxBoardWidth / _gridSize;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF5F8), Color(0xFFF0F7FF), Color(0xFFFFF9E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(top: -50, left: -50, child: MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withValues(alpha: 0.6))),
          Positioned(bottom: -50, right: -50, child: MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withValues(alpha: 0.7))),
          Positioned(top: 200, right: -100, child: MagicalBlob(size: 250, color: const Color(0xFFE8DDFF).withValues(alpha: 0.5))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildScoreCard(),
                const Spacer(),
                if (_isGenerating) 
                   const CircularProgressIndicator() 
                else 
                   _buildBoard(maxBoardWidth, cellSize),
                const Spacer(flex: 2),
              ],
            ),
          ),
          SuccessOverlay(
            isVisible: _isLevelComplete,
            onFinished: () {
              setState(() {
                _isLevelComplete = false;
                _level++;
                _generateLevel();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF67E1F5).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF67E1F5).withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Level $_level',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF334E68), fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Arrow Escape',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900, 
                    color: const Color(0xFF334E68),
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB497FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB347), size: 32),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '$_score',
              key: ValueKey<int>(_score),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5C677D),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(double boardSize, double cellSize) {
    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6A8EAE).withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
        ]
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: _activeBlocks.map((block) => _buildBlockWidget(block, cellSize)).toList(),
      ),
    );
  }

  Widget _buildBlockWidget(BlockWidgetData block, double cellSize) {
    double top = block.r * cellSize;
    double left = block.c * cellSize;

    if (block.isEscaping) {
      if (block.dir == ArrowDirection.up) top -= 1000;
      if (block.dir == ArrowDirection.down) top += 1000;
      if (block.dir == ArrowDirection.left) left -= 1000;
      if (block.dir == ArrowDirection.right) left += 1000;
    } else if (block.isBumping) {
      double bumpOffset = cellSize * 0.25;
      if (block.dir == ArrowDirection.up) top -= bumpOffset;
      if (block.dir == ArrowDirection.down) top += bumpOffset;
      if (block.dir == ArrowDirection.left) left -= bumpOffset;
      if (block.dir == ArrowDirection.right) left += bumpOffset;
    }

    return AnimatedPositioned(
      key: ValueKey(block.id),
      duration: block.isEscaping ? const Duration(milliseconds: 600) : const Duration(milliseconds: 150),
      curve: block.isEscaping ? Curves.easeInQuad : Curves.easeInOut,
      top: top,
      left: left,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: block.isEscaping ? 0.0 : 1.0,
        child: GestureDetector(
          onTap: () => _handleTap(block),
          child: SizedBox(
            width: cellSize,
            height: cellSize,
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: block.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(color: block.color.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(1, 3))
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: _buildArrowIcon(block.dir, cellSize),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowIcon(ArrowDirection dir, double cellSize) {
    IconData icon;
    switch (dir) {
      case ArrowDirection.up: icon = Icons.keyboard_arrow_up_rounded; break;
      case ArrowDirection.down: icon = Icons.keyboard_arrow_down_rounded; break;
      case ArrowDirection.left: icon = Icons.keyboard_arrow_left_rounded; break;
      case ArrowDirection.right: icon = Icons.keyboard_arrow_right_rounded; break;
    }
    return Icon(icon, color: Colors.white, size: cellSize * 0.6, shadows: [
      Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(1, 2))
    ]);
  }
}
