import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';

class MistakeQuestion {
  final String wrongSentence;
  final String wrongWord;
  final String correctWord;

  MistakeQuestion({
    required this.wrongSentence,
    required this.wrongWord,
    required this.correctWord,
  });

  List<String> get words => wrongSentence.split(' ');
  String get correctSentence => wrongSentence.replaceFirst(wrongWord, correctWord);
}

class FindMistakeScreen extends ConsumerStatefulWidget {
  const FindMistakeScreen({super.key});

  @override
  ConsumerState<FindMistakeScreen> createState() => _FindMistakeScreenState();
}

class _FindMistakeScreenState extends ConsumerState<FindMistakeScreen> {
  late ConfettiController _confettiController;
  late MistakeQuestion _currentQuestion;
  bool _showSuccessAnimation = false;
  int _fixedWordIndex = -1; // -1 means not fixed yet
  int? _jigglingIndex;

  final List<MistakeQuestion> _questions = [
    MistakeQuestion(wrongSentence: "She go to school.", wrongWord: "go", correctWord: "goes"),
    MistakeQuestion(wrongSentence: "They is playing outside.", wrongWord: "is", correctWord: "are"),
    MistakeQuestion(wrongSentence: "I has a blue car.", wrongWord: "has", correctWord: "have"),
    MistakeQuestion(wrongSentence: "He don't like apples.", wrongWord: "don't", correctWord: "doesn't"),
    MistakeQuestion(wrongSentence: "We was very happy.", wrongWord: "was", correctWord: "were"),
    MistakeQuestion(wrongSentence: "The dogs barks loudly.", wrongWord: "barks", correctWord: "bark"),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadNextQuestion() {
    final available = List<MistakeQuestion>.from(_questions);
    available.shuffle();
    _currentQuestion = available.first;
    _fixedWordIndex = -1;
    _jigglingIndex = null;
    _showSuccessAnimation = false;
  }

  void _onWordTapped(int index, String word) {
    if (_showSuccessAnimation) return;

    final tts = ref.read(learningTtsServiceProvider.notifier);

    if (word.replaceAll(RegExp(r'[^\w\s]'), '') == _currentQuestion.wrongWord.replaceAll(RegExp(r'[^\w\s]'), '')) {
      // Correct! They found the mistake.
      setState(() {
        _fixedWordIndex = index;
      });
      
      ref.read(userProvider.notifier).addPoints('Grammar', 10);
      tts.playFeedback("Great job! ${_currentQuestion.correctSentence}");
      _confettiController.play();
      
      setState(() {
        _showSuccessAnimation = true;
      });
      
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _loadNextQuestion();
          });
        }
      });
    } else {
      // Wrong word tapped
      tts.playFeedback("Oops! That's not the mistake.");
    }
  }

  void _showHint() {
    if (_showSuccessAnimation) return;
    
    // Find the index of the wrong word
    final words = _currentQuestion.words;
    int targetIndex = -1;
    for (int i = 0; i < words.length; i++) {
      if (words[i].replaceAll(RegExp(r'[^\w\s]'), '') == _currentQuestion.wrongWord.replaceAll(RegExp(r'[^\w\s]'), '')) {
        targetIndex = i;
        break;
      }
    }
    
    if (targetIndex != -1) {
      setState(() {
        _jigglingIndex = targetIndex;
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _jigglingIndex = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _currentQuestion.words;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Alice Blue
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
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const Text(
                        'Find the Mistake',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF073B4C),
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

                const SizedBox(height: 40),

                // Instruction
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Tap the wrong word in the sentence!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF118AB2),
                    ),
                  ),
                ),

                const Spacer(),

                // The Sentence
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: List.generate(words.length, (index) {
                      final word = words[index];
                      final isFixed = index == _fixedWordIndex;
                      final isJiggling = index == _jigglingIndex;
                      
                      // Handle punctuation gracefully
                      String cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
                      String punctuation = word.substring(cleanWord.length);
                      
                      String displayWord = isFixed ? _currentQuestion.correctWord + punctuation : word;
                      Color bubbleColor = isFixed ? const Color(0xFF06D6A0) : Colors.white;
                      Color textColor = isFixed ? Colors.white : const Color(0xFF073B4C);

                      return GestureDetector(
                        onTap: () => _onWordTapped(index, word),
                        child: _AnimatedWordBubble(
                          word: displayWord,
                          color: bubbleColor,
                          textColor: textColor,
                          isJiggling: isJiggling,
                          isFixed: isFixed,
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(flex: 2),
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

class _AnimatedWordBubble extends StatefulWidget {
  final String word;
  final Color color;
  final Color textColor;
  final bool isJiggling;
  final bool isFixed;

  const _AnimatedWordBubble({
    required this.word,
    required this.color,
    required this.textColor,
    required this.isJiggling,
    required this.isFixed,
  });

  @override
  State<_AnimatedWordBubble> createState() => _AnimatedWordBubbleState();
}

class _AnimatedWordBubbleState extends State<_AnimatedWordBubble> with TickerProviderStateMixin {
  late AnimationController _jiggleController;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }
  
  @override
  void didUpdateWidget(_AnimatedWordBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isJiggling && !oldWidget.isJiggling) {
      _jiggleController.forward(from: 0).then((_) => _jiggleController.reset());
    }
    
    if (widget.isFixed && !oldWidget.isFixed) {
      _flipController.forward(from: 0);
    } else if (!widget.isFixed && oldWidget.isFixed) {
      _flipController.reset();
    }
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_jiggleController, _flipController]),
      builder: (context, child) {
        // Jiggle transformation (rotation)
        final jiggleValue = math.sin(_jiggleController.value * math.pi * 4) * 0.1;
        
        // Flip transformation
        final flipValue = _flipController.value;
        final rotation = flipValue * math.pi;
        final isFlipped = flipValue > 0.5;
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(rotation)
            ..rotateZ(jiggleValue),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: isFlipped ? widget.color : const Color(0xFF118AB2).withValues(alpha: 0.3), width: 2),
            ),
            child: isFlipped
                ? Transform(
                    transform: Matrix4.rotationY(math.pi),
                    alignment: Alignment.center,
                    child: Text(
                      widget.word,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: widget.textColor,
                      ),
                    ),
                  )
                : Text(
                    widget.word,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: widget.textColor,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
