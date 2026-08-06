import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';

class NutModel {
  final int id;
  final Color color;
  int boltIndex;
  int positionIndex;
  bool isFlying;
  double? flyingX;
  double? flyingY;
  
  NutModel({
    required this.id,
    required this.color,
    required this.boltIndex,
    required this.positionIndex,
    this.isFlying = false,
    this.flyingX,
    this.flyingY,
  });
}

class NutsSortPuzzleScreen extends ConsumerStatefulWidget {
  const NutsSortPuzzleScreen({super.key});

  @override
  ConsumerState<NutsSortPuzzleScreen> createState() => _NutsSortPuzzleScreenState();
}

class _NutsSortPuzzleScreenState extends ConsumerState<NutsSortPuzzleScreen> {
  final int maxCapacity = 4;
  
  List<NutModel> allNuts = [];
  List<List<int>> boltStacks = []; // Stores nut IDs
  List<GlobalKey> boltKeys = [];
  Map<int, Offset> boltPositions = {}; // Map boltIndex to Offset

  int? selectedBoltIndex;
  bool hasWon = false;
  
  final GlobalKey _stackKey = GlobalKey();

  final List<Color> gameColors = [
    const Color(0xFFEF5350), // Red
    const Color(0xFF66BB6A), // Green
    const Color(0xFF42A5F5), // Blue
    const Color(0xFFFFCA28), // Yellow
    const Color(0xFFAB47BC), // Purple
    const Color(0xFF26A69A), // Teal
    const Color(0xFFFF7043), // Orange
    const Color(0xFF8D6E63), // Brown
    const Color(0xFF78909C), // Blue Grey
    const Color(0xFFEC407A), // Pink
  ];

  int level = 1;
  int nextNutId = 0;
  
  Timer? _levelTimer;
  int _timeLeft = 0;
  bool isGameOver = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }
  
  @override
  void dispose() {
    _levelTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recalculate positions if screen size changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateBoltPositions();
    });
  }

  void _startNewLevel() {
    int numColors = min(2 + (level ~/ 2), gameColors.length);
    int numEmptyBolts = level > 5 ? 1 : 2; // Harder after level 5
    int totalBolts = numColors + numEmptyBolts;
    
    boltKeys = List.generate(totalBolts, (_) => GlobalKey());
    boltStacks = List.generate(totalBolts, (_) => []);
    allNuts.clear();
    nextNutId = 0;
    
    List<Color> colorPool = [];
    for (int i = 0; i < numColors; i++) {
      for (int j = 0; j < maxCapacity; j++) {
        colorPool.add(gameColors[i]);
      }
    }
    colorPool.shuffle(Random());
    
    int poolIndex = 0;
    for (int i = 0; i < numColors; i++) {
      for (int j = 0; j < maxCapacity; j++) {
        Color c = colorPool[poolIndex++];
        NutModel nut = NutModel(
          id: nextNutId++,
          color: c,
          boltIndex: i,
          positionIndex: j,
        );
        allNuts.add(nut);
        boltStacks[i].add(nut.id);
      }
    }
    
    _levelTimer?.cancel();
    int initialTime = 60 + (level * 10); // More time for higher levels
    
    setState(() {
      selectedBoltIndex = null;
      hasWon = false;
      isGameOver = false;
      isPlaying = false;
      _timeLeft = initialTime;
      boltPositions.clear(); // Reset positions until layout completes
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateBoltPositions();
    });
  }

  void _startGame() {
    setState(() {
      isPlaying = true;
    });
    
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && !hasWon && !isGameOver) {
        setState(() {
          _timeLeft--;
        });
      } else if (_timeLeft == 0 && !hasWon) {
        timer.cancel();
        setState(() {
          isGameOver = true;
          selectedBoltIndex = null;
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _calculateBoltPositions() {
    if (!mounted) return;
    
    final RenderBox? stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    Map<int, Offset> newPositions = {};
    for (int i = 0; i < boltKeys.length; i++) {
      final RenderBox? boltBox = boltKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (boltBox != null) {
        // Get position of bolt relative to the stack
        final Offset position = boltBox.localToGlobal(Offset.zero, ancestor: stackBox);
        newPositions[i] = position;
      }
    }
    
    if (newPositions.length == boltKeys.length) {
      setState(() {
        boltPositions = newPositions;
      });
    }
  }

  NutModel? _getNutById(int id) {
    try {
      return allNuts.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  void _onBoltTap(int index) {
    if (hasWon || isGameOver || !isPlaying) return;
    
    // Ensure positions are calculated before moving to avoid layout jumps
    if (boltPositions.isEmpty || boltPositions.length != boltKeys.length) {
      _calculateBoltPositions();
      return;
    }

    setState(() {
      if (selectedBoltIndex == null) {
        if (boltStacks[index].isNotEmpty) {
          selectedBoltIndex = index;
          HapticFeedback.lightImpact();
        }
      } else if (selectedBoltIndex == index) {
        selectedBoltIndex = null;
      } else {
        int srcIndex = selectedBoltIndex!;
        int destIndex = index;

        if (_canMove(srcIndex, destIndex)) {
          int nutId = boltStacks[srcIndex].removeLast();
          boltStacks[destIndex].add(nutId);
          
          NutModel? nut = _getNutById(nutId);
          if (nut != null) {
            nut.boltIndex = destIndex;
            nut.positionIndex = boltStacks[destIndex].length - 1;
            
            // Crane animation: Lift, Translate, Drop
            nut.isFlying = true;
            nut.flyingX = boltPositions[srcIndex]!.dx + 5.0; // 5.0 is (baseWidth - nutWidth) / 2
            nut.flyingY = boltPositions[srcIndex]!.dy + 10.0; // High above the bolt
            
            selectedBoltIndex = null;
            
            Future.delayed(const Duration(milliseconds: 150), () {
              if (!mounted) return;
              setState(() {
                nut.flyingX = boltPositions[destIndex]!.dx + 5.0;
              });
              
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!mounted) return;
                setState(() {
                  nut.isFlying = false;
                });
                
                HapticFeedback.mediumImpact();
                _checkWinCondition();
              });
            });
          }
        } else {
          selectedBoltIndex = null;
          HapticFeedback.vibrate();
        }
      }
    });
  }

  bool _canMove(int srcIndex, int destIndex) {
    if (boltStacks[destIndex].length >= maxCapacity) return false;
    if (boltStacks[destIndex].isEmpty) return true;
    
    int srcTopNutId = boltStacks[srcIndex].last;
    int destTopNutId = boltStacks[destIndex].last;
    
    Color srcColor = _getNutById(srcTopNutId)!.color;
    Color destColor = _getNutById(destTopNutId)!.color;
    
    return srcColor == destColor;
  }

  void _checkWinCondition() {
    bool won = true;
    for (var stack in boltStacks) {
      if (stack.isNotEmpty) {
        if (stack.length != maxCapacity) {
          won = false;
          break;
        }
        Color firstColor = _getNutById(stack.first)!.color;
        for (var nutId in stack) {
          if (_getNutById(nutId)!.color != firstColor) {
            won = false;
            break;
          }
        }
      }
    }

    if (won) {
      _levelTimer?.cancel();
      setState(() {
        hasWon = true;
      });
      HapticFeedback.heavyImpact();
      // Award points when level completed
      ref.read(userProvider.notifier).addPoints('games', 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double nutWidth = 50.0;
    const double nutHeight = 22.0;
    const double baseHeight = 14.0;
    const double baseWidth = 60.0;
    final double boltHeight = (maxCapacity + 1) * nutHeight; 
    final double totalBoltHeight = boltHeight + baseHeight + 25; // 25 for selection jump

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Level $level',
          style: const TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.w900,
            fontSize: 26,
            shadows: [
              Shadow(color: Colors.white, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3E2723)),
            onPressed: () {
              setState(() {
                 _startNewLevel();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE1F5FE), 
              Color(0xFFF3E5F5), 
              Color(0xFFFFF3E0), 
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Timer Display
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 10 ? Colors.red.shade100 : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _timeLeft <= 10 ? Colors.red : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined, 
                        color: _timeLeft <= 10 ? Colors.red : const Color(0xFF5D4037),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 10 ? Colors.red : const Color(0xFF5D4037),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                    // Re-calculate layout if constraints change (e.g., orientation change)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                       if (mounted) _calculateBoltPositions();
                    });
                    
                    return Stack(
                      key: _stackKey,
                      children: [
                        // The Bolts Layer
                        Center(
                          child: Wrap(
                            spacing: 24,
                            runSpacing: 40,
                            alignment: WrapAlignment.center,
                            children: List.generate(boltKeys.length, (index) {
                              return GestureDetector(
                                onTap: () => _onBoltTap(index),
                                child: Container(
                                  key: boltKeys[index],
                                  child: BoltBaseWidget(
                                    maxCapacity: maxCapacity,
                                    width: baseWidth,
                                    height: totalBoltHeight,
                                    baseHeight: baseHeight,
                                    boltHeight: boltHeight,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        // The Nuts Layer (Overlay)
                        if (boltPositions.length == boltKeys.length)
                          ...allNuts.map((nut) {
                            Offset? boltPos = boltPositions[nut.boltIndex];
                            if (boltPos == null) return const SizedBox.shrink();
                            
                            bool isSelected = selectedBoltIndex == nut.boltIndex && 
                                              nut.positionIndex == boltStacks[nut.boltIndex].length - 1;
                                              
                            // Calculate position from bottom of the bolt
                            double yOffset = nut.isFlying 
                                ? nut.flyingY! 
                                : boltPos.dy + totalBoltHeight - baseHeight - (nut.positionIndex * nutHeight) - nutHeight;
                            
                            if (isSelected && !nut.isFlying) {
                              yOffset -= 25.0; // Selection jump
                            }
                            
                            double xOffset = nut.isFlying 
                                ? nut.flyingX! 
                                : boltPos.dx + (baseWidth - nutWidth) / 2; // Center horizontally on bolt

                            return AnimatedPositioned(
                              key: ValueKey(nut.id),
                              duration: Duration(milliseconds: nut.isFlying ? 150 : 300),
                              curve: nut.isFlying ? Curves.easeInOut : Curves.bounceOut,
                              left: xOffset,
                              top: yOffset,
                              child: IgnorePointer( // Let taps pass through to the bolt layer
                                child: NutWidget(
                                  color: nut.color,
                                  width: nutWidth,
                                  height: nutHeight,
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                      }
                    ),
                    if (!isPlaying && !isGameOver && !hasWon)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.5),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Play',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isGameOver)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _startNewLevel();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Time\'s Up! Try Again',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else if (hasWon)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              level++;
                              _startNewLevel();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Next Level!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class BoltBaseWidget extends StatelessWidget {
  final int maxCapacity;
  final double width;
  final double height;
  final double baseHeight;
  final double boltHeight;

  const BoltBaseWidget({
    super.key,
    required this.maxCapacity,
    required this.width,
    required this.height,
    required this.baseHeight,
    required this.boltHeight,
  });

  @override
  Widget build(BuildContext context) {
    const double boltWidth = 20.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The Bolt Cylinder
          Positioned(
            bottom: baseHeight,
            child: Container(
              width: boltWidth,
              height: boltHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF90A4AE),
                    Color(0xFFECEFF1),
                    Color(0xFFCFD8DC),
                    Color(0xFF78909C),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                border: Border.all(color: const Color(0xFF90A4AE), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  12,
                  (index) => Container(
                    height: 2,
                    color: const Color(0xFF90A4AE),
                  ),
                ),
              ),
            ),
          ),
          
          // The Base
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: baseHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF78909C),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF546E7A), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutWidget extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const NutWidget({
    super.key,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.25),
            offset: const Offset(0, -2),
            blurRadius: 1,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width * 0.75,
          height: height,
          decoration: BoxDecoration(
            border: Border.symmetric(
               vertical: BorderSide(color: Colors.black.withValues(alpha: 0.25), width: 2),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
