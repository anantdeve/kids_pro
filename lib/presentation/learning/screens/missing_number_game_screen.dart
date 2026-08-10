import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../services/learning_tts_service.dart';
import '../widgets/tts_animated_speaker.dart';
import '../widgets/success_overlay.dart';
import '../../../core/providers/user_provider.dart';

class MissingNumberGameScreen extends ConsumerStatefulWidget {
  const MissingNumberGameScreen({super.key});

  @override
  ConsumerState<MissingNumberGameScreen> createState() => _MissingNumberGameScreenState();
}

class _MissingNumberGameScreenState extends ConsumerState<MissingNumberGameScreen> {
  late final LearningTtsNotifier _ttsNotifier;
  bool _isMuted = false;
  bool _isFirstLoad = true;
  final Random random = Random();
  late List<int> sequence;
  late int missingIndex;
  late List<int> options;
  bool isCorrect = false;
  bool _isSuccess = false;
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(learningTtsServiceProvider.notifier);
    _generateLevel();
  }

  @override
  void dispose() {
    _ttsNotifier.stop();
    super.dispose();
  }

  void _generateLevel() {
    setState(() {
      isCorrect = false;
      _isSuccess = false;
      int start = random.nextInt(15) + 1; // 1 to 15
      sequence = List.generate(5, (index) => start + index);
      missingIndex = random.nextInt(5);
      
      int correctAnswer = sequence[missingIndex];
      options = [correctAnswer];
      
      while (options.length < 3) {
        int distractor = correctAnswer + (random.nextBool() ? 1 : -1) * (random.nextInt(3) + 1);
        if (distractor > 0 && !options.contains(distractor)) {
          options.add(distractor);
        }
      }
      options.shuffle();
    });
    
    if (!_isMuted && _isFirstLoad) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Find the missing number');
      _isFirstLoad = false;
    }
  }

  void _onOptionTap(int value) {
    if (value == sequence[missingIndex]) {
      setState(() {
        isCorrect = true;
      });
      if (!_isMuted) {
        ref.read(learningTtsServiceProvider.notifier).playFeedback(value.toString());
      }
      _showSuccessEffect();
    } else {
      _showErrorEffect();
    }
  }

  void _showSuccessEffect() {
    setState(() {
      _isSuccess = true;
      _points += 50;
    });
    ref.read(userProvider.notifier).addPoints('Learning', 50);
  }

  void _showErrorEffect() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Try again! You can do it! 😊'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.redAccent,
      ),
    );
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
                                    Color(0xFFB497FF),
                                    Color(0xFFFFB6C1),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Missing Number',
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

                Text(
                  'Find the missing number!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 40),

                // Number Sequence
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      bool isMissing = index == missingIndex;
                      return _buildNumberCard(
                        isMissing ? (isCorrect ? '${sequence[index]}' : '?') : '${sequence[index]}',
                        isPlaceholder: isMissing && !isCorrect,
                        isCorrect: isCorrect && isMissing,
                      );
                    }),
                  ),
                ),

                const Spacer(flex: 2),

                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: options.map((val) => _buildOptionCard(val)).toList(),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),

          // Success Overlay
          SuccessOverlay(
            isVisible: _isSuccess,
            lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json', // Celebration Balloons
            onFinished: () {
              if (mounted) _generateLevel();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(String text, {bool isPlaceholder = false, bool isCorrect = false}) {
    return Container(
      width: 65,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPlaceholder 
              ? const Color(0xFFB497FF) 
              : (isCorrect ? const Color(0xFF5CD6A1) : Colors.transparent),
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
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: isPlaceholder ? const Color(0xFFB497FF).withValues(alpha: 0.4) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOptionCard(int value) {
    return GestureDetector(
      onTap: () => _onOptionTap(value),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFFB497FF),
          ),
        ),
      ),
    );
  }
}
