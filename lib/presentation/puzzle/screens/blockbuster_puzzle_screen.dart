import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import '../../../core/widgets/magical_blob.dart';
import 'dart:math';
import '../../learning/widgets/success_overlay.dart';

class BlockShape {
  final List<List<bool>> shape;
  final Color color;
  BlockShape({required this.shape, required this.color});

  int get rows => shape.length;
  int get cols => shape[0].length;
}

final List<BlockShape> _allShapes = [
  // 1x1
  BlockShape(shape: [[true]], color: const Color(0xFFFF7B9C)),
  // 2x2
  BlockShape(shape: [[true, true], [true, true]], color: const Color(0xFF5CD6A1)),
  // 1xN
  BlockShape(shape: [[true, true]], color: const Color(0xFF67E1F5)),
  BlockShape(shape: [[true], [true]], color: const Color(0xFF67E1F5)),
  BlockShape(shape: [[true, true, true]], color: const Color(0xFFFFB347)),
  BlockShape(shape: [[true], [true], [true]], color: const Color(0xFFFFB347)),
  BlockShape(shape: [[true, true, true, true]], color: const Color(0xFFB497FF)),
  BlockShape(shape: [[true], [true], [true], [true]], color: const Color(0xFFB497FF)),
  // L-shapes
  BlockShape(shape: [[true, true, true], [true, false, false], [true, false, false]], color: const Color(0xFFFF924C)),
  BlockShape(shape: [[true, true, true], [false, false, true], [false, false, true]], color: const Color(0xFF6A8EAE)),
  BlockShape(shape: [[true, false], [true, true]], color: const Color(0xFFE08E36)),
  BlockShape(shape: [[false, true], [true, true]], color: const Color(0xFFE08E36)),
];

class BlockBusterPuzzleScreen extends StatefulWidget {
  const BlockBusterPuzzleScreen({super.key});

  @override
  State<BlockBusterPuzzleScreen> createState() => _BlockBusterPuzzleScreenState();
}

class _BlockBusterPuzzleScreenState extends State<BlockBusterPuzzleScreen> with TickerProviderStateMixin {
  final int _gridSize = 8;
  late List<List<Color?>> _grid;
  int _score = 0;
  List<BlockShape?> _availableBlocks = [];
  final GlobalKey _boardKey = GlobalKey();
  final Random _random = Random();
  int _generationId = 0; // used for keys to trigger animations
  bool _isGameOverState = false;
  
  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, null));
    _score = 0;
    _generateBlocks();
  }

  void _generateBlocks() {
    _generationId++;
    _availableBlocks = List.generate(3, (_) => _allShapes[_random.nextInt(_allShapes.length)]);
    if (_isGameOver()) {
       _showGameOverDialog();
    }
  }

  bool _isGameOver() {
    for (var block in _availableBlocks) {
      if (block != null && _canPlaceAnywhere(block)) {
        return false;
      }
    }
    return true; 
  }

  bool _canPlaceAnywhere(BlockShape block) {
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (_isValidPlacement(block, r, c)) return true;
      }
    }
    return false;
  }

  bool _isValidPlacement(BlockShape block, int row, int col) {
    if (row < 0 || col < 0) return false;
    if (row + block.rows > _gridSize || col + block.cols > _gridSize) return false;
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] && _grid[row + r][col + c] != null) {
          return false;
        }
      }
    }
    return true;
  }

  void _placeBlock(BlockShape block, int row, int col, int blockIndex) {
    setState(() {
      for (int r = 0; r < block.rows; r++) {
        for (int c = 0; c < block.cols; c++) {
          if (block.shape[r][c]) {
            _grid[row + r][col + c] = block.color;
          }
        }
      }
      _availableBlocks[blockIndex] = null;
      _score += block.rows * block.cols * 10;
      _checkAndClearLines();
      
      if (_availableBlocks.every((b) => b == null)) {
        _generateBlocks();
      } else if (_isGameOver()) {
        _showGameOverDialog();
      }
    });
  }

  void _checkAndClearLines() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    for (int r = 0; r < _gridSize; r++) {
      if (_grid[r].every((cell) => cell != null)) rowsToClear.add(r);
    }
    for (int c = 0; c < _gridSize; c++) {
      bool full = true;
      for (int r = 0; r < _gridSize; r++) {
        if (_grid[r][c] == null) full = false;
      }
      if (full) colsToClear.add(c);
    }

    for (int r in rowsToClear) {
      for (int c = 0; c < _gridSize; c++) {
        _grid[r][c] = null;
      }
      _score += 100;
    }
    for (int c in colsToClear) {
      for (int r = 0; r < _gridSize; r++) {
        _grid[r][c] = null;
      }
      _score += 100;
    }
  }

  void _showGameOverDialog() {
    setState(() {
      _isGameOverState = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Dynamic sizing to ensure no overflow
    final double maxBoardWidth = min(screenWidth * 0.9, 400.0);
    final double cellSize = (maxBoardWidth - 16) / _gridSize;
    // Scale the available blocks to be proportional
    final double availableBlockCellSize = cellSize * 0.6; 
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
          // Magical Blobs
          Positioned(top: -50, left: -50, child: MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withValues(alpha: 0.6))),
          Positioned(bottom: -50, right: -50, child: MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withValues(alpha: 0.7))),
          Positioned(top: 200, right: -100, child: MagicalBlob(size: 250, color: const Color(0xFFE8DDFF).withValues(alpha: 0.5))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildScoreCard(),
                const Spacer(flex: 1),
                _buildBoard(cellSize),
                const Spacer(flex: 2),
                _buildAvailableBlocks(availableBlockCellSize, cellSize),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SuccessOverlay(
            isVisible: _isGameOverState,
            onFinished: () {
              setState(() {
                _isGameOverState = false;
                _resetGame();
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
            onTap: () => context.popWithSound(),
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

                Text(
                  'BlockBuster',
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
            color: const Color(0xFF67E1F5).withValues(alpha: 0.3),
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

  Widget _buildBoard(double cellSize) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final renderBox = _boardKey.currentContext!.findRenderObject() as RenderBox;
        final localOffset = renderBox.globalToLocal(details.offset);
        
        int col = ((localOffset.dx + (cellSize * 0.25)) / cellSize).floor();
        int row = ((localOffset.dy + (cellSize * 0.25)) / cellSize).floor();
        
        final block = details.data['block'] as BlockShape;
        final index = details.data['index'] as int;

        if (_isValidPlacement(block, row, col)) {
          _placeBlock(block, row, col, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          key: _boardKey,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(color: const Color(0xFF6A8EAE).withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, 10))
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_gridSize, (r) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_gridSize, (c) => _buildCell(_grid[r][c], cellSize)),
            )),
          ),
        );
      },
    );
  }

  Widget _buildCell(Color? color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFF4F7FB).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6),
          boxShadow: color != null ? [
            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(1, 2))
          ] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(1, 1))
          ],
          border: Border.all(
            color: color != null ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.05), 
            width: 1.5
          ),
        ),
        child: color != null ? _buildBlockHighlight() : null,
      ),
    );
  }

  Widget _buildBlockHighlight() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildAvailableBlocks(double availableSize, double dragSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final block = _availableBlocks[index];
            if (block == null) return SizedBox(width: availableSize * 3, height: availableSize * 3);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Draggable<Map<String, dynamic>>(
                data: {'block': block, 'index': index},
                feedback: _buildShapeWidget(block, dragSize, true),
                childWhenDragging: Opacity(opacity: 0.2, child: _buildShapeWidget(block, availableSize, false)),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${_generationId}_$index'),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: _buildShapeWidget(block, availableSize, false),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShapeWidget(BlockShape block, double cellSize, bool isDragging) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(block.rows, (r) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(block.cols, (c) => 
            block.shape[r][c] ? SizedBox(
              width: cellSize,
              height: cellSize,
              child: Container(
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: block.color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: isDragging ? [
                    BoxShadow(color: block.color.withValues(alpha: 0.6), blurRadius: 10, offset: const Offset(0, 5))
                  ] : [
                    BoxShadow(color: block.color.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(1, 2))
                  ],
                ),
                child: _buildBlockHighlight(),
              ),
            ) : SizedBox(width: cellSize, height: cellSize),
          ),
        )),
      ),
    );
  }
}
