import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/success_overlay.dart';

class GameObject {
  final int id;
  final String icon;
  final String category;
  final Offset position;
  final bool isTarget;
  bool isTapped;

  GameObject({
    required this.id,
    required this.icon,
    required this.category,
    required this.position,
    required this.isTarget,
    this.isTapped = false,
  });
}

class CountAndTapGameScreen extends StatefulWidget {
  const CountAndTapGameScreen({super.key});

  @override
  State<CountAndTapGameScreen> createState() => _CountAndTapGameScreenState();
}

class _CountAndTapGameScreenState extends State<CountAndTapGameScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool _isMuted = false;
  final Random random = Random();
  
  // Game State
  int level = 1;
  late int targetNumber;
  int currentCount = 0;
  List<GameObject> gameObjects = [];
  bool _isSuccess = false;
  
  late String targetCategory;
  late String targetIcon;

  final Map<String, List<String>> _objectCategories = {
    'STARS': ['⭐', '✨', '💫'],
    'FRUITS': ['🍎', '🍌', '🍓', '🍊', '🍇', '🍐'],
    'ANIMALS': ['🐶', '🐱', '🦁', '🐼', '🐰', '🐯'],
    'BIRDS': ['🐥', '🐦', '🦉', '🦆', '🦢', '🦩'],
    'OCEAN': ['🐙', '🐳', '🦀', '🐬', '🐢', '🐠'],
    'VEHICLES': ['🚗', '🚀', '🚁', '🚂', '🚲', '🚜'],
  };

  @override
  void initState() {
    super.initState();
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      _isSuccess = false;
      currentCount = 0;
      
      // 1. Pick target category and icon
      final categories = _objectCategories.keys.toList();
      targetCategory = categories[random.nextInt(categories.length)];
      final icons = _objectCategories[targetCategory]!;
      targetIcon = icons[random.nextInt(icons.length)];

      // 2. Set difficulty based on level
      targetNumber = min(3 + (level ~/ 2), 10);
      int distractorCount = min(2 + level, 12);
      
      // 3. Generate positions and objects
      gameObjects = [];
      List<Offset> positions = [];
      int totalObjects = targetNumber + distractorCount;
      
      int attempts = 0;
      while (positions.length < totalObjects && attempts < 200) {
        final newPos = Offset(
          0.1 + random.nextDouble() * 0.8,
          0.1 + random.nextDouble() * 0.75,
        );
        
        bool tooClose = false;
        for (var p in positions) {
          if ((p - newPos).distance < 0.18) {
            tooClose = true;
            break;
          }
        }
        
        if (!tooClose) {
          positions.add(newPos);
        }
        attempts++;
      }

      // 4. Create target objects
      for (int i = 0; i < targetNumber; i++) {
        if (i < positions.length) {
          gameObjects.add(GameObject(
            id: i,
            icon: targetIcon,
            category: targetCategory,
            position: positions[i],
            isTarget: true,
          ));
        }
      }

      // 5. Create distractor objects
      for (int i = targetNumber; i < positions.length; i++) {
        String otherCat;
        do {
          otherCat = categories[random.nextInt(categories.length)];
        } while (otherCat == targetCategory);
        
        final otherIcons = _objectCategories[otherCat]!;
        gameObjects.add(GameObject(
          id: i,
          icon: otherIcons[random.nextInt(otherIcons.length)],
          category: otherCat,
          position: positions[i],
          isTarget: false,
        ));
      }
      
      gameObjects.shuffle();
    });
  }

  void _onObjectTap(GameObject obj) {
    if (obj.isTapped || _isSuccess) return;

    if (obj.isTarget) {
      setState(() {
        obj.isTapped = true;
        currentCount++;
      });
      
      if (!_isMuted) {
        flutterTts.speak(currentCount.toString());
      }

      if (currentCount == targetNumber) {
        _showSuccessEffect();
      }
    } else {
      // Wrong tap handled by widget's shake
    }
  }

  void _showSuccessEffect() {
    setState(() {
      _isSuccess = true;
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
                _buildHeader(),
                
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: _buildProgressBar(),
                ),

                // Game Field
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: gameObjects.map((obj) {
                          return Positioned(
                            left: obj.position.dx * constraints.maxWidth - 45,
                            top: obj.position.dy * constraints.maxHeight - 45,
                            child: _GameObjectWidget(
                              key: ValueKey('obj_${obj.id}_${level}'),
                              object: obj,
                              onTap: () => _onObjectTap(obj),
                              tappedIndex: obj.isTarget && obj.isTapped 
                                  ? gameObjects.where((o) => o.isTarget && o.isTapped).toList().indexOf(obj) + 1 
                                  : null,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Success Overlay
          SuccessOverlay(
            isVisible: _isSuccess,
            onFinished: () {
              setState(() {
                level++;
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
          const SizedBox(width: 8),
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
              onPressed: () {
                setState(() {
                  _isMuted = !_isMuted;
                  if (_isMuted) {
                    flutterTts.stop();
                  }
                });
              },
              icon: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $level',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Tap $targetNumber $targetCategory!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3142),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$targetIcon',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: (currentCount / targetNumber) * 200, // Roughly scaled
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF67E1F5), Color(0xFFB497FF)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$currentCount / $targetNumber',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFB497FF),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameObjectWidget extends StatefulWidget {
  final GameObject object;
  final VoidCallback onTap;
  final int? tappedIndex;

  const _GameObjectWidget({
    super.key,
    required this.object,
    required this.onTap,
    this.tappedIndex,
  });

  @override
  State<_GameObjectWidget> createState() => _GameObjectWidgetState();
}

class _GameObjectWidgetState extends State<_GameObjectWidget> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _shakeController;
  late Animation<double> _floatY;
  late Animation<double> _shakeX;

  @override
  void initState() {
    super.initState();
    
    // Floating Animation
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + Random().nextInt(1000)),
    )..repeat(reverse: true);
    
    _floatY = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Shake Animation (for wrong taps)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 25),
    ]).animate(_shakeController);
  }

  void _handleTap() {
    if (widget.object.isTarget) {
      widget.onTap();
    } else {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _shakeController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeX.value, _floatY.value),
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              width: widget.object.isTapped ? 100 : 90,
              height: widget.object.isTapped ? 100 : 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.object.isTapped 
                    ? const Color(0xFFFFD166) 
                    : Colors.white.withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: (widget.object.isTapped ? const Color(0xFFFFD166) : Colors.white)
                        .withValues(alpha: 0.2),
                    blurRadius: 15,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.object.icon,
                    style: TextStyle(
                      fontSize: widget.object.isTapped ? 55 : 45,
                    ),
                  ),
                  if (widget.object.isTapped)
                    Text(
                      '${widget.tappedIndex}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
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
}
