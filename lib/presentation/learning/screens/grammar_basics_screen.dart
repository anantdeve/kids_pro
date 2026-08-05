import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class GrammarBasicsScreen extends ConsumerStatefulWidget {
  final String topic;

  const GrammarBasicsScreen({super.key, required this.topic});

  @override
  ConsumerState<GrammarBasicsScreen> createState() => _GrammarBasicsScreenState();
}

class _GrammarBasicsScreenState extends ConsumerState<GrammarBasicsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool? _isCorrect;

  List<Map<String, dynamic>> get _content {
    switch (widget.topic) {
      case 'nouns':
        return [
          {
            'type': 'learning',
            'title': 'What is a Noun?',
            'description': 'A noun is a naming word. It can be a person, place, animal, or thing!',
            'emoji': '🏷️',
            'example': 'Dog, School, Apple, Boy',
          },
          {
            'type': 'learning',
            'title': 'Person',
            'description': 'Names of people like Teacher, Doctor, Girl, or your friend!',
            'emoji': '👩‍🏫',
            'example': 'The **teacher** is smiling.',
          },
          {
            'type': 'learning',
            'title': 'Place',
            'description': 'Names of places like Park, School, City, or Home.',
            'emoji': '🏞️',
            'example': 'We play in the **park**.',
          },
          {
            'type': 'learning',
            'title': 'Animal or Thing',
            'description': 'Names of animals like Cat, Dog, or things like Car, Book.',
            'emoji': '🐶🚗',
            'example': 'The **cat** sleeps on the **bed**.',
          },
          {
            'type': 'practice',
            'question': 'Fill in the blank with a person (noun)!',
            'sentence': 'The ___ is very kind.',
            'options': ['teacher', 'jump', 'very', 'blue'],
            'correctAnswer': 'teacher',
            'emoji': '🤔',
          },
          {
            'type': 'practice',
            'question': 'Fill in the blank with a place (noun)!',
            'sentence': 'We played in the beautiful ___.',
            'options': ['park', 'played', 'softly', 'beautiful'],
            'correctAnswer': 'park',
            'emoji': '🏞️',
          },
        ];
      case 'verbs':
        return [
          {
            'type': 'learning',
            'title': 'What is a Verb?',
            'description': 'A verb is an action word! It tells what someone or something is doing.',
            'emoji': '🏃‍♂️',
            'example': 'Run, Jump, Play, Eat',
          },
          {
            'type': 'learning',
            'title': 'Action!',
            'description': 'If you can do it, it is a verb!',
            'emoji': '🤸‍♀️',
            'example': 'The girl **jumps** high.',
          },
          {
            'type': 'learning',
            'title': 'More Verbs',
            'description': 'Sleeping, eating, reading, and singing are all verbs too.',
            'emoji': '📖🎵',
            'example': 'He **sings** a song.',
          },
          {
            'type': 'practice',
            'question': 'Fill in the blank with an action word (verb)!',
            'sentence': 'The cat ___ over the fence.',
            'options': ['jumped', 'happy', 'fence', 'The'],
            'correctAnswer': 'jumped',
            'emoji': '🏃',
          },
          {
            'type': 'practice',
            'question': 'Fill in the blank with an action word!',
            'sentence': 'She ___ a book every night.',
            'options': ['reads', 'book', 'night', 'red'],
            'correctAnswer': 'reads',
            'emoji': '📖',
          },
        ];
      case 'adjectives':
        return [
          {
            'type': 'learning',
            'title': 'What is an Adjective?',
            'description': 'An adjective is a describing word. It tells us more about a noun.',
            'emoji': '✨',
            'example': 'Big, Red, Happy, Soft',
          },
          {
            'type': 'learning',
            'title': 'Colors and Sizes',
            'description': 'Words like blue, tall, tiny, and round are adjectives.',
            'emoji': '🔵📏',
            'example': 'The **red** apple is **big**.',
          },
          {
            'type': 'learning',
            'title': 'Feelings and Looks',
            'description': 'Words like happy, sad, beautiful, and scary are adjectives.',
            'emoji': '😊👻',
            'example': 'The **happy** dog wagged its tail.',
          },
          {
            'type': 'practice',
            'question': 'Fill in the blank with a describing word (adjective)!',
            'sentence': 'I saw a ___ elephant at the zoo.',
            'options': ['big', 'saw', 'elephant', 'run'],
            'correctAnswer': 'big',
            'emoji': '🐘',
          },
          {
            'type': 'practice',
            'question': 'Fill in the blank with a describing word!',
            'sentence': 'She gave me a ___ flower.',
            'options': ['beautiful', 'gave', 'flower', 'She'],
            'correctAnswer': 'beautiful',
            'emoji': '🌸',
          },
        ];
      default:
        return [];
    }
  }

  String get _topicTitle {
    switch (widget.topic) {
      case 'nouns': return 'Learn Nouns';
      case 'verbs': return 'Learn Verbs';
      case 'adjectives': return 'Learn Adjectives';
      default: return 'Learn Grammar';
    }
  }

  Color get _topicColor {
    switch (widget.topic) {
      case 'nouns': return const Color(0xFFFF9A9E);
      case 'verbs': return const Color(0xFF06D6A0);
      case 'adjectives': return const Color(0xFF118AB2);
      default: return const Color(0xFF48CAE4);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    _playSuccessSound();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSuccessSound() async {
    try {
      // Assuming you have this sound in assets. Ignore if not found.
      // await _audioPlayer.play(AssetSource('sounds/pop.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _nextSlide() {
    final currentSlide = _content[_currentIndex];
    if (currentSlide['type'] == 'practice' && _isCorrect != true) {
      return; // Cannot proceed until answered correctly
    }

    if (_currentIndex < _content.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _isCorrect = null;
      });
      _controller.reset();
      _controller.forward();
      _playSuccessSound();
    } else {
      // Completed basics
      context.pop();
    }
  }

  void _prevSlide() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswer = null;
        _isCorrect = null;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_content.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Topic not found')),
      );
    }

    final currentSlide = _content[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _topicColor.withValues(alpha: 0.2),
              _topicColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D3142), size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _topicTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _topicColor,
                        shadows: [const Shadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _content.length,
                backgroundColor: Colors.white,
                color: _topicColor,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            
            const Spacer(),

            // Content Card
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: _topicColor.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: _topicColor.withValues(alpha: 0.5), width: 4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentSlide['type'] == 'practice') ...[
                          Text(
                            currentSlide['emoji'] ?? '🤔',
                            style: const TextStyle(fontSize: 60),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentSlide['question'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _topicColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              String displaySentence = currentSlide['sentence'] ?? '';
                              if (_isCorrect == true && _selectedAnswer != null) {
                                displaySentence = displaySentence.replaceAll('___', _selectedAnswer!);
                              }
                              return Text(
                                '"$displaySentence"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A4A4A),
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: (currentSlide['options'] as List<dynamic>).map((optionObj) {
                              final option = optionObj.toString();
                              final isSelected = _selectedAnswer == option;
                              final isCorrectAnswer = currentSlide['correctAnswer'] == option;
                              
                              Color buttonColor = Colors.white;
                              Color textColor = _topicColor;
                              
                              if (isSelected) {
                                if (_isCorrect == true) {
                                  buttonColor = Colors.green.shade100;
                                  textColor = Colors.green.shade800;
                                } else if (_isCorrect == false) {
                                  buttonColor = Colors.red.shade100;
                                  textColor = Colors.red.shade800;
                                }
                              } else if (_isCorrect == true && isCorrectAnswer) {
                                buttonColor = Colors.green.shade100;
                                textColor = Colors.green.shade800;
                              }

                              return ElevatedButton(
                                onPressed: () {
                                  if (_isCorrect == true) return; // already correct
                                  setState(() {
                                    _selectedAnswer = option;
                                    _isCorrect = isCorrectAnswer;
                                  });
                                  if (isCorrectAnswer) {
                                    _playSuccessSound();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  foregroundColor: textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isSelected ? textColor : _topicColor.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  elevation: isSelected ? 0 : 2,
                                ),
                                child: Text(
                                  option,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_isCorrect == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                'Great Job! You found it! 🎉',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ),
                          if (_isCorrect == false)
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                'Not quite! Try again.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ),
                        ] else ...[
                          Text(
                            currentSlide['emoji'] ?? '',
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            currentSlide['title'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _topicColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentSlide['description'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4A4A),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (currentSlide['example'] != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _topicColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Example: ${currentSlide['example']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _topicColor,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Navigation Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(
                      onPressed: _prevSlide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _topicColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded),
                    )
                  else
                    const SizedBox(width: 80), // Placeholder for alignment

                  ElevatedButton(
                    onPressed: (currentSlide['type'] == 'practice' && _isCorrect != true) ? null : _nextSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _topicColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _topicColor.withValues(alpha: 0.3),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: (currentSlide['type'] == 'practice' && _isCorrect != true) ? 0 : 8,
                      shadowColor: _topicColor.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      _currentIndex == _content.length - 1 ? 'Finish!' : 'Next',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
