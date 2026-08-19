import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';
import 'dart:math' as math;

class PictureQuestion {
  final String emoji;
  final String question;
  final List<String> options;
  final int correctIndex;

  PictureQuestion({
    required this.emoji,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class PictureGrammarScreen extends ConsumerStatefulWidget {
  const PictureGrammarScreen({super.key});

  @override
  ConsumerState<PictureGrammarScreen> createState() => _PictureGrammarScreenState();
}

class _PictureGrammarScreenState extends ConsumerState<PictureGrammarScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late PictureQuestion _currentQuestion;
  bool _showSuccessAnimation = false;
  int? _selectedIndex;
  int? _wrongSelectedIndex;
  
  late AnimationController _shakeController;

  final List<PictureQuestion> _questions = [
    PictureQuestion(
      emoji: "👧📖",
      question: "What is happening?",
      options: ["She read.", "She is reading.", "She reading."],
      correctIndex: 1,
    ),
    PictureQuestion(
      emoji: "👦🍎",
      question: "What is he doing?",
      options: ["He eat an apple.", "He eats an apples.", "He is eating an apple."],
      correctIndex: 2,
    ),
    PictureQuestion(
      emoji: "🐶🏃‍♂️",
      question: "Look at the dog!",
      options: ["The dog is running.", "The dog run.", "The dog running."],
      correctIndex: 0,
    ),
    PictureQuestion(
      emoji: "🌧️🌂",
      question: "What is the weather?",
      options: ["It are raining.", "It is raining.", "It raining."],
      correctIndex: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _loadNextQuestion() {
    final available = List<PictureQuestion>.from(_questions);
    available.shuffle();
    _currentQuestion = available.first;
    _selectedIndex = null;
    _wrongSelectedIndex = null;
    _showSuccessAnimation = false;
  }

  void _onOptionTapped(int index) {
    if (_showSuccessAnimation) return;

    final tts = ref.read(learningTtsServiceProvider.notifier);

    setState(() {
      _selectedIndex = index;
    });

    if (index == _currentQuestion.correctIndex) {
      // Correct answer
      ref.read(userProvider.notifier).addPoints('Grammar', 10);
      tts.playFeedback("Great job! ${_currentQuestion.options[index]}");
      _confettiController.play();
      
      setState(() {
        _showSuccessAnimation = true;
        _wrongSelectedIndex = null;
      });
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _loadNextQuestion();
          });
        }
      });
    } else {
      // Wrong answer
      tts.playFeedback("Oops! Try again.");
      setState(() {
        _wrongSelectedIndex = index;
      });
      _shakeController.forward(from: 0).then((_) => _shakeController.reset());
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_showSuccessAnimation) {
          setState(() {
            _wrongSelectedIndex = null;
            _selectedIndex = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Light orange background
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCC80).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB74D).withValues(alpha: 0.2),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                          onPressed: () => context.popWithSound(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Picture Grammar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Question
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _currentQuestion.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Emoji / Picture
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentQuestion.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),

                const Spacer(),

                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: List.generate(_currentQuestion.options.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            // Shake only the wrong selected button
                            double offset = 0;
                            if (index == _wrongSelectedIndex) {
                              offset = math.sin(_shakeController.value * math.pi * 6) * 8;
                            }
                            
                            return Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            );
                          },
                          child: _OptionButton(
                            text: _currentQuestion.options[index],
                            isSelected: index == _selectedIndex,
                            isCorrect: index == _currentQuestion.correctIndex && _showSuccessAnimation,
                            isWrong: index == _wrongSelectedIndex,
                            onTap: () => _onOptionTapped(index),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Success Animation
          if (_showSuccessAnimation)
            Center(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/celebration.json',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              numberOfParticles: 50,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFFFB74D);
    Color textColor = const Color(0xFFE65100);

    if (isCorrect) {
      backgroundColor = const Color(0xFF4CAF50); // Green
      borderColor = const Color(0xFF388E3C);
      textColor = Colors.white;
    } else if (isWrong) {
      backgroundColor = const Color(0xFFEF5350); // Red
      borderColor = const Color(0xFFD32F2F);
      textColor = Colors.white;
    } else if (isSelected) {
      backgroundColor = const Color(0xFFFFE0B2); // Selected state (before validation)
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
