import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../services/learning_tts_service.dart';
import '../widgets/tts_animated_speaker.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class ColorQuestScreen extends ConsumerStatefulWidget {
  const ColorQuestScreen({super.key});

  @override
  ConsumerState<ColorQuestScreen> createState() => _ColorQuestScreenState();
}

class _ColorQuestScreenState extends ConsumerState<ColorQuestScreen> with TickerProviderStateMixin {
  late final LearningTtsNotifier _ttsNotifier;
  bool _isMuted = false;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final List<GameColor> allColors = [
    GameColor(name: 'YELLOW', color: const Color(0xFFFFD166)),
    GameColor(name: 'PINK', color: const Color(0xFFFF7B9C)),
    GameColor(name: 'GREEN', color: const Color(0xFF5CD6A1)),
    GameColor(name: 'ORANGE', color: const Color(0xFFFF8B66)),
    GameColor(name: 'BLUE', color: const Color(0xFF67E1F5)),
    GameColor(name: 'PURPLE', color: const Color(0xFFB497FF)),
  ];

  final Random random = Random();
  int level = 1;
  late GameColor targetColor;
  late List<GameColor> options;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? _lastTappedName;
  bool _isSuccess = false;
  GameColor? _lastTargetColor;
  int _points = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(learningTtsServiceProvider.notifier);
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _generateNewLevel(isFirstLoad: true);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _floatController.dispose();
    _ttsNotifier.stop();
    _bgmPlayer.dispose();
    super.dispose();
  }

  void _generateNewLevel({bool isFirstLoad = false}) {
    setState(() {
      // Pick a new color that is not the same as the last one
      final availableColors = allColors.where((c) => c.name != _lastTargetColor?.name).toList();
      targetColor = availableColors[random.nextInt(availableColors.length)];
      _lastTargetColor = targetColor;
      
      // Get 3 other unique colors for options
      final otherColors = allColors.where((c) => c.name != targetColor.name).toList();
      otherColors.shuffle();
      
      options = [targetColor, ...otherColors.take(3)];
      options.shuffle();
    });
    
    // Automatically speak the target color when a new level is generated
    if (isFirstLoad) {
      Future.microtask(() async {
        if (!_isMuted && mounted) {
          await ref.read(learningTtsServiceProvider.notifier).playInstruction('Tap the ${targetColor.name.toLowerCase()}');
        }
        if (mounted) {
          _bgmPlayer.setReleaseMode(ReleaseMode.loop);
          _bgmPlayer.play(AssetSource('audio/Sounds/feature bk sound.mp3'));
        }
      });
    } else {
      if (!_isMuted) {
        ref.read(learningTtsServiceProvider.notifier).playInstruction('Tap the ${targetColor.name.toLowerCase()}');
      }
    }
  }

  void _onColorTap(GameColor tappedColor) {
    setState(() => _lastTappedName = tappedColor.name);
    
    if (tappedColor.name == targetColor.name) {
      if (!_isMuted) {
        ref.read(learningTtsServiceProvider.notifier).playFeedback(tappedColor.name.toLowerCase());
      }
      setState(() => _points += 10);
      _showSuccessEffect();
    } else {
      _shakeController.forward(from: 0);
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

          // Animated Bubbles
          ...List.generate(5, (index) {
            return Positioned(
              left: random.nextDouble() * 300,
              top: random.nextDouble() * 600,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin((_floatController.value + index) * pi) * 20,
                      cos((_floatController.value + index) * pi) * 20,
                    ),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 100 + (index * 20),
                        height: 100 + (index * 20),
                        decoration: BoxDecoration(
                          color: allColors[index % allColors.length].color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              // Left: Back Button
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
                              
                              // Center: Title
                              Expanded(
                                child: Text(
                                  'COLOR QUEST',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF4A4A4A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),

                              // Right: Points and TTS
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD166),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD166).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                                        const SizedBox(width: 4),
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (Widget child, Animation<double> animation) {
                                            return ScaleTransition(scale: animation, child: child);
                                          },
                                          child: Text(
                                            '$_points',
                                            key: ValueKey<int>(_points),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TtsAnimatedSpeaker(
                                    isMuted: _isMuted,
                                    onTap: () {
                                      setState(() {
                                        _isMuted = !_isMuted;
                                        if (_isMuted) {
                                          ref.read(learningTtsServiceProvider.notifier).stop();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Rest of the content (Scrollable)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Target Card
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (!_isMuted) {
                                ref.read(learningTtsServiceProvider.notifier).playInstruction('Tap the ${targetColor.name.toLowerCase()}');
                              }
                            },
                            child: Consumer(
                              builder: (context, ref, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                                  margin: const EdgeInsets.symmetric(horizontal: 40),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: targetColor.color.withValues(alpha: 0.2),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Tap the',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey[600],
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          targetColor.name,
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            color: targetColor.color,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Color Options Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 30,
                                ),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final item = options[index];
                                  return GestureDetector(
                                    onTap: () => _onColorTap(item),
                                    child: AnimatedBuilder(
                                      animation: _shakeController,
                                      builder: (context, child) {
                                        double offset = 0;
                                        if (_lastTappedName == item.name && item.name != targetColor.name) {
                                          offset = sin(_shakeController.value * 4 * pi) * 10;
                                        }
                                        return Transform.translate(
                                          offset: Offset(offset, 0),
                                          child: child,
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: item.color,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Theme.of(context).cardTheme.color ?? Colors.white, width: 8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: item.color.withValues(alpha: 0.3),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_isSuccess && _lastTappedName == item.name)
                                            Positioned.fill(
                                              child: Transform.scale(
                                                scale: 2.5,
                                                child: Lottie.network(
                                                  'https://assets3.lottiefiles.com/packages/lf20_touohxv0.json',
                                                  repeat: false,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  SuccessOverlay(
            isVisible: _isSuccess,
            onFinished: () {
              setState(() {
                _isSuccess = false;
                _generateNewLevel();
              });
            },
          ),
        ],
      ),
    );
  }
}

class GameColor {
  final String name;
  final Color color;
  GameColor({required this.name, required this.color});
}
