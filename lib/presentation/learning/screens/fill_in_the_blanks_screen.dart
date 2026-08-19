import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';

class GrammarQuestion {
  final String part1;
  final String part2;
  final List<String> options;
  final int correctIndex;
  final String hint;

  GrammarQuestion({
    required this.part1,
    required this.part2,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  String get fullSentence => "$part1${options[correctIndex]}$part2";
}

final List<GrammarQuestion> _questions = [
  GrammarQuestion(
    part1: "The cat ",
    part2: " on the mat.",
    options: ["sit", "sits", "sitting"],
    correctIndex: 1,
    hint: "Think about singular nouns! The cat is just one cat.",
  ),
  GrammarQuestion(
    part1: "I ",
    part2: " a book every night.",
    options: ["read", "reads", "reading"],
    correctIndex: 0,
    hint: "With 'I', you don't need an 's' on the action word.",
  ),
  GrammarQuestion(
    part1: "They are ",
    part2: " in the park.",
    options: ["play", "plays", "playing"],
    correctIndex: 2,
    hint: "Look at the word 'are'. It tells you the action is happening right now! (-ing)",
  ),
];

class FillInTheBlanksScreen extends ConsumerStatefulWidget {
  const FillInTheBlanksScreen({super.key});

  @override
  ConsumerState<FillInTheBlanksScreen> createState() => _FillInTheBlanksScreenState();
}

class _FillInTheBlanksScreenState extends ConsumerState<FillInTheBlanksScreen> {
  late ConfettiController _confettiController;
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Play initial sentence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakSentence();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _speakSentence() {
    final tts = ref.read(learningTtsServiceProvider.notifier);
    tts.playInstruction(_questions[_currentIndex].fullSentence);
  }

  void _checkAnswer(int index) {
    if (_selectedIndex != null) return; // Already answered

    setState(() {
      _selectedIndex = index;
    });

    final currentQuestion = _questions[_currentIndex];
    final tts = ref.read(learningTtsServiceProvider.notifier);

    if (index == currentQuestion.correctIndex) {
      // Correct!
      ref.read(userProvider.notifier).addPoints('Grammar', 10);
      tts.playFeedback("Great job! ${currentQuestion.fullSentence}");
      _confettiController.play();
      setState(() {
        _showSuccessAnimation = true;
      });
      
      // Move to next question after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessAnimation = false;
            if (_currentIndex < _questions.length - 1) {
              _currentIndex++;
              _selectedIndex = null;
              _speakSentence();
            } else {
              // Game over, return to hub
              context.popWithSound();
            }
          });
        }
      });
    } else {
      // Incorrect
      tts.playFeedback("Oops! Try again.");
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _selectedIndex = null;
          });
        }
      });
    }
  }

  void _showHint() {
    final currentQuestion = _questions[_currentIndex];
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.yellow),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currentQuestion.hint,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];
    
    // Build the display sentence based on selection
    String displaySentence;
    if (_selectedIndex != null && _selectedIndex == currentQuestion.correctIndex) {
      displaySentence = "${currentQuestion.part1}${currentQuestion.options[_selectedIndex!]}${currentQuestion.part2}";
    } else {
      displaySentence = "${currentQuestion.part1}___${currentQuestion.part2}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text(
                        'Question ${_currentIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showHint,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD166), // Yellow
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.lightbulb, color: Colors.white, size: 20),
                              SizedBox(width: 4),
                              Text('Hint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sentence Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF118AB2).withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF118AB2).withValues(alpha: 0.2), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _speakSentence,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06D6A0).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.volume_up_rounded, color: Color(0xFF06D6A0), size: 28),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          displaySentence,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF073B4C),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Options
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final option = currentQuestion.options[index];
                      final isSelected = _selectedIndex == index;
                      final isCorrect = index == currentQuestion.correctIndex;
                      
                      Color cardColor = Colors.white;
                      Color borderColor = Colors.black12;
                      Color textColor = const Color(0xFF073B4C);
                      IconData radioIcon = Icons.radio_button_unchecked_rounded;
                      Color radioColor = Colors.black26;

                      if (isSelected) {
                        if (isCorrect) {
                          cardColor = const Color(0xFF06D6A0);
                          borderColor = const Color(0xFF06D6A0);
                          textColor = Colors.white;
                          radioIcon = Icons.check_circle_rounded;
                          radioColor = Colors.white;
                        } else {
                          cardColor = const Color(0xFFEF476F);
                          borderColor = const Color(0xFFEF476F);
                          textColor = Colors.white;
                          radioIcon = Icons.cancel_rounded;
                          radioColor = Colors.white;
                        }
                      } else if (_selectedIndex != null && isCorrect) {
                        // Highlight correct answer if they got it wrong
                        borderColor = const Color(0xFF06D6A0);
                        textColor = const Color(0xFF06D6A0);
                        radioIcon = Icons.check_circle_rounded;
                        radioColor = const Color(0xFF06D6A0);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _checkAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: borderColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(radioIcon, color: radioColor, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "${String.fromCharCode(65 + index)})  $option", // A), B), C)
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lottie Celebration Popup
          if (_showSuccessAnimation)
            Center(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/celebration.json',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // Fallback if missing
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
