import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/widgets/magical_blob.dart';
import '../../../data/repositories/local_quiz_repository.dart';
import '../../../domain/entities/visual_question.dart';
import '../../learning/widgets/success_overlay.dart';
import '../../learning/services/learning_tts_service.dart';
import '../../learning/widgets/tts_animated_speaker.dart';

class MagicQuizScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String difficulty;
  
  const MagicQuizScreen({super.key, required this.categoryId, required this.difficulty});

  @override
  ConsumerState<MagicQuizScreen> createState() => _MagicQuizScreenState();
}

class _MagicQuizScreenState extends ConsumerState<MagicQuizScreen> {
  bool _isMuted = false;
  final LocalQuizRepository _repository = LocalQuizRepository();
  late List<VisualQuestion> questions;
  
  int currentQuestionIndex = 0;
  int score = 0;
  bool? isCorrect;
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    ref.read(learningTtsServiceProvider.notifier).stop();
    super.dispose();
  }

  void _loadQuestions() {
    setState(() {
      questions = _repository.getQuestionsForCategory(widget.categoryId);
    });
    _speakQuestion();
  }

  void _speakQuestion() {
    if (!_isMuted && questions.isNotEmpty) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction(questions[currentQuestionIndex].text);
    }
  }

  void _checkAnswer(int index) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswerIndex = index;
      hasAnswered = true;
      if (questions[currentQuestionIndex].options[index] == questions[currentQuestionIndex].correctEmoji) {
        isCorrect = true;
        score++;
      } else {
        isCorrect = false;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswerIndex = null;
          isCorrect = null;
          hasAnswered = false;
        });
        _speakQuestion();
      } else {
        _onQuizFinished();
      }
    });
  }

  void _onQuizFinished() {
    final earnedPoints = score * 20;
    ref.read(userProvider.notifier).addPoints('Quiz', earnedPoints);
    _showResult(earnedPoints);
  }

  void _showResult(int earnedPoints) {
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
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
              child: Container(color: const Color(0xFFFFF9F5)),
            ),
          MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withValues(alpha: 0.4), top: 100, left: -50),
          MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withValues(alpha: 0.5), top: -50, right: -50),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildQuizBody()),
              ],
            ),
          ),
          SuccessOverlay(
            isVisible: _isSuccess,
            onFinished: () {
              if (mounted) {
                setState(() {
                  _isSuccess = false;
                });
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.6) ?? Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 8),
          TtsAnimatedSpeaker(
            isMuted: _isMuted,
            color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142),
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
                if (_isMuted) {
                  ref.read(learningTtsServiceProvider.notifier).stop();
                } else {
                  _speakQuestion();
                }
              });
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}/${questions.length}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF8D99AE), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBody() {
    final question = questions[currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Visual Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.8) ?? Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  question.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3142)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Grid of Object Options
          Expanded(
            flex: 4,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.0,
              ),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                bool isSelected = selectedAnswerIndex == index;
                Color cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
                
                if (isSelected) {
                  cardColor = isCorrect! ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2);
                }

                return GestureDetector(
                  onTap: () => _checkAnswer(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? (isCorrect! ? Colors.green : Colors.red) : (Theme.of(context).cardTheme.color ?? Colors.white),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 70),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
