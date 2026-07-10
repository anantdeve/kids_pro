import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../../../core/providers/user_provider.dart';
import '../services/learning_tts_service.dart';

class ListenAndChooseScreen extends ConsumerStatefulWidget {
  const ListenAndChooseScreen({super.key});

  @override
  ConsumerState<ListenAndChooseScreen> createState() => _ListenAndChooseScreenState();
}

class _ListenAndChooseScreenState extends ConsumerState<ListenAndChooseScreen> {
  final List<Map<String, String>> _wordsAndPictures = [
    {'word': 'APPLE', 'picture': '🍎'},
    {'word': 'BANANA', 'picture': '🍌'},
    {'word': 'CAT', 'picture': '🐱'},
    {'word': 'DOG', 'picture': '🐶'},
    {'word': 'ELEPHANT', 'picture': '🐘'},
    {'word': 'FROG', 'picture': '🐸'},
    {'word': 'GRAPE', 'picture': '🍇'},
    {'word': 'HOUSE', 'picture': '🏠'},
    {'word': 'SUN', 'picture': '☀️'},
    {'word': 'CAR', 'picture': '🚗'},
    {'word': 'BIRD', 'picture': '🐦'},
    {'word': 'TREE', 'picture': '🌳'},
    {'word': 'FISH', 'picture': '🐟'},
  ];

  late String _correctWord;
  late List<Map<String, String>> _options;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to play sound after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateLevel();
    });
  }

  void _generateLevel() {
    final random = Random();
    
    // Pick correct word object
    final correctItem = _wordsAndPictures[random.nextInt(_wordsAndPictures.length)];
    _correctWord = correctItem['word']!;

    // Pick 3 wrong words
    final otherItems = _wordsAndPictures.where((item) => item['word'] != _correctWord).toList();
    otherItems.shuffle(random);
    final incorrectOptions = otherItems.take(3).toList();

    _options = [...incorrectOptions, correctItem];
    _options.shuffle(random);

    setState(() {
      _isSuccess = false;
    });

    _playAudio();
  }

  void _playAudio() {
    ref.read(learningTtsServiceProvider.notifier).playInstruction(_correctWord.toLowerCase());
  }

  void _onOptionSelected(String selectedWord) {
    if (selectedWord == _correctWord) {
      setState(() {
        _isSuccess = true;
      });
      ref.read(userProvider.notifier).addPoints('Learning', 20);
    } else {
      // Play a bump or 'try again' sound (could use TTS for try again)
      ref.read(learningTtsServiceProvider.notifier).playInstruction('Try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ttsState = ref.watch(learningTtsServiceProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E5), // Light orange background
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Play Audio Button
                        GestureDetector(
                          onTap: _playAudio,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: ttsState.isSpeaking ? const Color(0xFFFF914D) : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFFF914D).withValues(alpha: 0.5), 
                                width: 4,
                              ),
                            ),
                            child: Icon(
                              Icons.volume_up_rounded,
                              size: 80,
                              color: ttsState.isSpeaking ? Colors.white : const Color(0xFFFF914D),
                            ),
                          ),
                        ),
                        
                        const Text(
                          'Tap to hear the word again!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5C677D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Options Grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.2,
                            children: _options.map((item) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2D3142),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _onOptionSelected(item['word']!),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    item['picture']!,
                                    style: const TextStyle(
                                      fontSize: 60,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Success Overlay
          SuccessOverlay(
            isVisible: _isSuccess,
            lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_obhph3sh.json',
            onFinished: _generateLevel,
          ),
        ],
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
              context.pop();
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
                colors: [Color(0xFFFF914D), Color(0xFFFF5252)],
              ).createShader(bounds),
              child: const Text(
                'LISTEN & CHOOSE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
