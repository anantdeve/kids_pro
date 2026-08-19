import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../widgets/failure_overlay.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';

class DragLettersScreen extends ConsumerStatefulWidget {
  const DragLettersScreen({super.key});

  @override
  ConsumerState<DragLettersScreen> createState() => _DragLettersScreenState();
}

class _DragLettersScreenState extends ConsumerState<DragLettersScreen> {
  final List<Map<String, String>> _wordsAndPictures = [
    {'word': 'CAT', 'picture': '🐱'},
    {'word': 'DOG', 'picture': '🐶'},
    {'word': 'SUN', 'picture': '☀️'},
    {'word': 'CAR', 'picture': '🚗'},
    {'word': 'BIRD', 'picture': '🐦'},
  ];

  late String _currentWord;
  late String _currentPicture;
  
  late List<String?> _placedLetters;
  late List<Map<String, dynamic>> _availableLetters; 
  bool _isSuccess = false;
  bool _isFailure = false;

  @override
  void initState() {
    super.initState();
    _generateLevel();
  }

  void _generateLevel() {
    final random = Random();
    final item = _wordsAndPictures[random.nextInt(_wordsAndPictures.length)];
    _currentWord = item['word']!;
    _currentPicture = item['picture']!;

    _placedLetters = List.filled(_currentWord.length, null);
    
    // Create draggable letter objects
    _availableLetters = [];
    for (int i = 0; i < _currentWord.length; i++) {
      _availableLetters.add({
        'id': i,
        'letter': _currentWord[i],
      });
    }
    
    _availableLetters.shuffle(random);

    setState(() {
      _isSuccess = false;
      _isFailure = false;
    });

    // Play word audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(learningTtsServiceProvider.notifier).playInstruction(_currentWord.toLowerCase());
    });
  }

  void _onLetterDropped(Map<String, dynamic> draggedItem, int targetIndex) {
    if (_isSuccess || _isFailure) return;

    if (draggedItem['letter'] == _currentWord[targetIndex]) {
      setState(() {
        _placedLetters[targetIndex] = draggedItem['letter'];
        _availableLetters.removeWhere((item) => item['id'] == draggedItem['id']);

        if (_placedLetters.where((l) => l == null).isEmpty) {
          _isSuccess = true;
          ref.read(userProvider.notifier).addPoints('Learning', 30);
          ref.read(learningTtsServiceProvider.notifier).playFeedback('Great job!');
        }
      });
    } else {
      setState(() {
        _isFailure = true;
      });
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6FA), // Light teal background
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                
                const SizedBox(height: 40),
                
                // Picture
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(_currentPicture, style: const TextStyle(fontSize: 80)),
                  ),
                ),
                
                const Spacer(),
                
                // Target Slots
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 12,
                  children: List.generate(_currentWord.length, (index) {
                    return DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (details) => _placedLetters[index] == null,
                      onAcceptWithDetails: (details) => _onLetterDropped(details.data, index),
                      builder: (context, candidateData, rejectedData) {
                        final isPlaced = _placedLetters[index] != null;
                        return Container(
                          width: 55,
                          height: 65,
                          decoration: BoxDecoration(
                            color: isPlaced ? const Color(0xFF00BF63) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidateData.isNotEmpty 
                                  ? const Color(0xFF00BF63) 
                                  : (isPlaced ? Colors.transparent : Colors.grey.withValues(alpha: 0.3)),
                              width: 3,
                            ),
                            boxShadow: isPlaced ? [
                              BoxShadow(color: const Color(0xFF00BF63).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
                            ] : null,
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _placedLetters[index] ?? '',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                
                const Spacer(),
                
                // Available Letters Tray
                if (!_isSuccess)
                  Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _availableLetters.map((item) {
                          return Draggable<Map<String, dynamic>>(
                            data: item,
                            feedback: _buildLetterBlock(item['letter'], isDragging: true),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildLetterBlock(item['letter']),
                            ),
                            child: _buildLetterBlock(item['letter']),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                if (_isSuccess)
                  const SizedBox(height: 150),
              ],
            ),
          ),
          
          // Success Overlay
          SuccessOverlay(
            isVisible: _isSuccess,
            lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_obhph3sh.json',
            onFinished: _generateLevel,
          ),
          
          // Failure Overlay
          FailureOverlay(
            isVisible: _isFailure,
            onFinished: () {
              setState(() {
                _isFailure = false;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLetterBlock(String letter, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDragging ? 0.2 : 0.1),
              blurRadius: isDragging ? 15 : 5,
              offset: Offset(0, isDragging ? 8 : 4),
            ),
          ],
          border: Border.all(color: const Color(0xFF00BF63).withValues(alpha: 0.3), width: 2),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(learningTtsServiceProvider.notifier).stop();
              context.popWithSound();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00BF63), Color(0xFF009688)],
              ).createShader(bounds),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'WORD BUILDER',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
          // Mute/Unmute Button
          Consumer(
            builder: (context, ref, child) {
              final isMuted = ref.watch(learningTtsServiceProvider).isMuted;
              return GestureDetector(
                onTap: () => ref.read(learningTtsServiceProvider.notifier).toggleMute(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
                    ],
                  ),
                  child: Icon(
                    isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: isMuted ? Colors.grey : const Color(0xFF00BF63),
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Replay Audio Button
          GestureDetector(
            onTap: () {
              final isMuted = ref.read(learningTtsServiceProvider).isMuted;
              if (!isMuted) {
                ref.read(learningTtsServiceProvider.notifier).playInstruction(_currentWord.toLowerCase());
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
                ],
              ),
              child: const Icon(Icons.replay_rounded, color: Color(0xFF00BF63), size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
