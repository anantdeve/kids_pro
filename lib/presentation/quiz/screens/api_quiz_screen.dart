import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/widgets/magical_blob.dart';
import '../../../data/services/quiz_api_service.dart';
import '../../../domain/entities/api_question.dart';
import '../../learning/widgets/success_overlay.dart';
import '../../learning/services/learning_tts_service.dart';
import '../../learning/widgets/tts_animated_speaker.dart';

class ApiQuizScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String difficulty;
  
  const ApiQuizScreen({super.key, required this.categoryId, required this.difficulty});

  @override
  ConsumerState<ApiQuizScreen> createState() => _ApiQuizScreenState();
}

class _ApiQuizScreenState extends ConsumerState<ApiQuizScreen> {
  bool _isMuted = false;
  final QuizApiService _apiService = QuizApiService();
  List<ApiQuestion> questions = [];
  bool isLoading = true;
  String? errorMessage;
  
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

  Future<void> _loadQuestions() async {
    try {
      final fetchedQuestions = await _apiService.fetchQuestions(
        categoryId: widget.categoryId,
        difficulty: widget.difficulty,
        amount: 5,
      );
      if (mounted) {
        setState(() {
          questions = fetchedQuestions;
          isLoading = false;
        });
        _speakQuestion();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _speakQuestion() {
    if (!_isMuted && questions.isNotEmpty) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction(questions[currentQuestionIndex].question);
    }
  }

  void _checkAnswer(int index) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswerIndex = index;
      hasAnswered = true;
      if (questions[currentQuestionIndex].options[index] == questions[currentQuestionIndex].correctAnswer) {
        isCorrect = true;
        score++;
      } else {
        isCorrect = false;
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
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
              child: Container(color: const Color(0xFFFCE4EC)), // Light pinkish for GK
            ),
          MagicalBlob(size: 300, color: const Color(0xFFF8BBD0).withValues(alpha: 0.4), top: 100, left: -50),
          MagicalBlob(size: 350, color: const Color(0xFFE1BEE7).withValues(alpha: 0.5), top: -50, right: -50),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
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
                  questions.isEmpty ? 'Loading...' : 'Question ${currentQuestionIndex + 1}/${questions.length}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF8D99AE), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF06292)),
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

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF06292)),
      );
    }
    
    if (errorMessage != null || questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😢', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              errorMessage ?? 'No questions found.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color(0xFF2D3142), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadQuestions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF06292),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Text Question Card
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
                  question.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D3142)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // List of Text Options
          Expanded(
            flex: 6,
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                bool isSelected = selectedAnswerIndex == index;
                Color cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
                
                if (hasAnswered) {
                  if (option == question.correctAnswer) {
                    cardColor = const Color(0xFFC8E6C9); // Green if it's correct
                  } else if (isSelected) {
                    cardColor = const Color(0xFFFFCDD2); // Red if wrong selection
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () => _checkAnswer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: hasAnswered && option == question.correctAnswer
                              ? Colors.green
                              : (isSelected ? Colors.red : (Theme.of(context).cardTheme.color ?? Colors.white)),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                        ),
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
