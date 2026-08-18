import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../services/learning_tts_service.dart';
import '../widgets/tts_animated_speaker.dart';
import '../../../core/providers/user_provider.dart';

class NumberMatchingGameScreen extends ConsumerStatefulWidget {
  final String bgmPath;
  const NumberMatchingGameScreen({super.key, this.bgmPath = 'audio/Sounds/feature bk sound.mp3'});

  @override
  ConsumerState<NumberMatchingGameScreen> createState() => _NumberMatchingGameScreenState();
}

class _NumberMatchingGameScreenState extends ConsumerState<NumberMatchingGameScreen> {
  late final LearningTtsNotifier _ttsNotifier;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;
  bool _isFirstLoad = true;
  final Random random = Random();
  late int targetNumber;
  late List<int> options;
  bool _isSuccess = false;
  int _points = 0;
  final List<String> icons = ['❤️', '🚀', '⭐', '🍎', '🐱', '🦋'];
  final List<Color> iconColors = [
    const Color(0xFFFF7B9C), // Pink
    const Color(0xFFB497FF), // Purple
    const Color(0xFFFFD166), // Yellow
    const Color(0xFFFF8B66), // Orange
    const Color(0xFF67E1F5), // Blue
    const Color(0xFF5CD6A1), // Green
  ];

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(learningTtsServiceProvider.notifier);
    _initBgm();
    _generateLevel();
  }

  Future<void> _initBgm() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource(widget.bgmPath));
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _ttsNotifier.stop();
    super.dispose();
  }

  void _generateLevel() {
    setState(() {
      targetNumber = random.nextInt(9) + 1; // 1 to 9
      options = [targetNumber];
      while (options.length < 3) {
        int next = random.nextInt(9) + 1;
        if (!options.contains(next)) {
          options.add(next);
        }
      }
      options.shuffle();
    });

    if (!_isMuted && _isFirstLoad) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Drag the number to match');
      _isFirstLoad = false;
    }
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
                // Header
                Padding(
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
                      TtsAnimatedSpeaker(
                        isMuted: _isMuted,
                        onTap: () {
                          setState(() {
                            _isMuted = !_isMuted;
                            if (_isMuted) {
                              _ttsNotifier.stop();
                              _bgmPlayer.pause();
                            } else {
                              _bgmPlayer.resume();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFF67E1F5),
                                    Color(0xFFB497FF),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Matching Fun',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Target Number Card (Draggable)
                Draggable<int>(
                  data: targetNumber,
                  feedback: _buildTargetCard(targetNumber, isFeedback: true),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildTargetCard(targetNumber),
                  ),
                  child: _buildTargetCard(targetNumber),
                ),

                const Spacer(flex: 2),

                // Set Cards (DragTargets)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: options.map((num) => _buildSetCard(num)).toList(),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),

          // Success Overlay
          SuccessOverlay(
            isVisible: _isSuccess,
            lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json', // Trophy Cup
            lottieSize: 350,
            onFinished: () {
              setState(() {
                _isSuccess = false;
              });
              _generateLevel();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(int number, {bool isFeedback = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFFF8B66), // Orange
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8B66).withValues(alpha: isFeedback ? 0.4 : 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSetCard(int number) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data == number,
      onAcceptWithDetails: (details) {
        if (details.data == number) {
          _showSuccessEffect();
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty; // True when the correct number is dragged over this target
        return Container(
          width: 100,
          height: 140,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHovered ? const Color(0xFF4CAF50) : Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildIconGrid(number),
        );
      },
    );
  }

  Widget _buildIconGrid(int count) {
    final String icon = icons[count % icons.length];
    final Color color = iconColors[count % iconColors.length];

    // Adjust font size based on count to help fit
    double fontSize = 28;
    if (count > 4) fontSize = 22;
    if (count > 6) fontSize = 18;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 90, maxHeight: 120),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: List.generate(count, (index) {
              return Text(
                icon,
                style: TextStyle(fontSize: fontSize, color: color),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showSuccessEffect() {
    if (!_isMuted) {
      ref.read(learningTtsServiceProvider.notifier).playFeedback(targetNumber.toString());
    }
    setState(() {
      _isSuccess = true;
      _points += 50;
    });
    ref.read(userProvider.notifier).addPoints('Learning', 50);
  }
}
