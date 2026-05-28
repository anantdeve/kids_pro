import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/providers/user_provider.dart';
import '../../../core/widgets/magical_blob.dart';
import '../../../data/repositories/local_quiz_repository.dart';
import '../../../domain/entities/visual_question.dart';

class MagicQuizScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String difficulty;
  
  const MagicQuizScreen({super.key, required this.categoryId, required this.difficulty});

  @override
  ConsumerState<MagicQuizScreen> createState() => _MagicQuizScreenState();
}

class _MagicQuizScreenState extends ConsumerState<MagicQuizScreen> {
  final LocalQuizRepository _repository = LocalQuizRepository();
  late List<VisualQuestion> questions;
  
  int currentQuestionIndex = 0;
  int score = 0;
  bool? isCorrect;
  int? selectedAnswerIndex;
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    setState(() {
      questions = _repository.getQuestionsForCategory(widget.categoryId);
    });
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quiz Finished! 🎉', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D3142))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Text('🌟', style: TextStyle(fontSize: 50)),
              ),
              const SizedBox(height: 10),
              Text('+$earnedPoints Stars!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 20),
              Text('Your Score', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600)),
              Text('$score / ${questions.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF4CAF50))),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                child: const Text('Back Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFFFFF9F5)),
          ),
          MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withOpacity(0.4), top: 100, left: -50),
          MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withOpacity(0.5), top: -50, right: -50),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildQuizBody()),
              ],
            ),
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
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Color(0xFF2D3142), size: 24),
            ),
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
                    backgroundColor: Colors.grey.withOpacity(0.1),
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
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  question.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.volume_up_rounded, color: Color(0xFFFF8A65), size: 40),
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
                Color cardColor = Colors.white;
                
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
                        color: isSelected ? (isCorrect! ? Colors.green : Colors.red) : Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
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
