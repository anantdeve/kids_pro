import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';

enum Difficulty { easy, medium, hard }

class TargetSentence {
  final String text;
  final Difficulty difficulty;

  TargetSentence(this.text, this.difficulty);

  List<String> get words => text.split(' ');
}

class SentenceBuilderScreen extends ConsumerStatefulWidget {
  const SentenceBuilderScreen({super.key});

  @override
  ConsumerState<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends ConsumerState<SentenceBuilderScreen> {
  late ConfettiController _confettiController;
  Difficulty _currentDifficulty = Difficulty.easy;
  late TargetSentence _currentSentence;
  
  List<String> _wordBank = [];
  List<String> _builtSentence = [];
  bool _showSuccessAnimation = false;

  final List<TargetSentence> _allSentences = [
    // Easy (3-4 words)
    TargetSentence("The dog runs.", Difficulty.easy),
    TargetSentence("I like apples.", Difficulty.easy),
    TargetSentence("She is happy.", Difficulty.easy),
    TargetSentence("He can jump.", Difficulty.easy),
    TargetSentence("Cats are cute.", Difficulty.easy),
    
    // Medium (5-6 words)
    TargetSentence("The dog runs very fast.", Difficulty.medium),
    TargetSentence("I like eating red apples.", Difficulty.medium),
    TargetSentence("She is a happy girl.", Difficulty.medium),
    TargetSentence("He can jump really high.", Difficulty.medium),
    TargetSentence("My little cat is cute.", Difficulty.medium),
    
    // Hard (7-8 words)
    TargetSentence("The small dog runs very fast today.", Difficulty.hard),
    TargetSentence("I really like eating sweet red apples.", Difficulty.hard),
    TargetSentence("She is always a very happy girl.", Difficulty.hard),
    TargetSentence("The brave boy can jump really high.", Difficulty.hard),
    TargetSentence("My little orange cat is so cute.", Difficulty.hard),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadRandomSentence();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadRandomSentence() {
    final available = _allSentences.where((s) => s.difficulty == _currentDifficulty).toList();
    available.shuffle();
    _currentSentence = available.first;
    
    _wordBank = List.from(_currentSentence.words);
    _wordBank.shuffle();
    
    // Ensure it's actually scrambled
    while (_wordBank.join(' ') == _currentSentence.text && _wordBank.length > 1) {
      _wordBank.shuffle();
    }
    
    _builtSentence = [];
  }

  void _setDifficulty(Difficulty difficulty) {
    setState(() {
      _currentDifficulty = difficulty;
      _loadRandomSentence();
      _showSuccessAnimation = false;
    });
  }

  void _checkAnswer() {
    // Only check if all words are placed
    if (_wordBank.isEmpty) {
      if (_builtSentence.join(' ') == _currentSentence.text) {
        // Correct!
        ref.read(userProvider.notifier).addPoints('Grammar', 15);
        final tts = ref.read(learningTtsServiceProvider.notifier);
        tts.playFeedback("Great job! ${_currentSentence.text}");
        
        _confettiController.play();
        setState(() {
          _showSuccessAnimation = true;
        });
        
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showSuccessAnimation = false;
              _loadRandomSentence();
            });
          }
        });
      } else {
        // Incorrect, just play oops
        final tts = ref.read(learningTtsServiceProvider.notifier);
        tts.playFeedback("Oops! Try again.");
      }
    }
  }

  void _onWordBankTap(String word) {
    if (_showSuccessAnimation) return;
    
    _speakWord(word);
    setState(() {
      _wordBank.remove(word);
      _builtSentence.add(word);
    });
    
    _checkAnswer();
  }

  void _onBuiltWordTap(String word) {
    if (_showSuccessAnimation) return;
    
    _speakWord(word);
    setState(() {
      _builtSentence.remove(word);
      _wordBank.add(word);
    });
  }

  void _speakWord(String word) {
    final tts = ref.read(learningTtsServiceProvider.notifier);
    tts.playInstruction(word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Neutral background
      body: Stack(
        children: [
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
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1), 
                              blurRadius: 8, 
                              offset: const Offset(0, 3)
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                          onPressed: () => context.popWithSound(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Sentence Builder',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF073B4C),
                        ),
                      ),
                    ],
                  ),
                ),

                // Difficulty Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDifficultyTab("Easy", Difficulty.easy, const Color(0xFF06D6A0)),
                      const SizedBox(width: 10),
                      _buildDifficultyTab("Medium", Difficulty.medium, const Color(0xFFFFD166)),
                      const SizedBox(width: 10),
                      _buildDifficultyTab("Hard", Difficulty.hard, const Color(0xFFEF476F)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Instruction
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Tap words to build the sentence!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF118AB2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Sentence Area (Top)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(minHeight: 120), // Give it some minimum height
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
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (_builtSentence.isEmpty)
                        const Text(
                          "Your sentence goes here...",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black26,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ..._builtSentence.map((word) => GestureDetector(
                        onTap: () => _onBuiltWordTap(word),
                        child: _buildWordBubble(word, color: const Color(0xFF06D6A0)),
                      )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // Word Bank (Bottom)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text(
                          "Word Bank",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: _wordBank.map((word) => GestureDetector(
                                onTap: () => _onWordBankTap(word),
                                child: _buildWordBubble(word, color: const Color(0xFFFFD166)),
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildDifficultyTab(String label, Difficulty diff, Color color) {
    final isSelected = _currentDifficulty == diff;
    return GestureDetector(
      onTap: () => _setDifficulty(diff),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildWordBubble(String word, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        word,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF073B4C),
        ),
      ),
    );
  }
}
