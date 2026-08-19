import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../widgets/success_overlay.dart';
import '../widgets/failure_overlay.dart';
import '../../../core/providers/user_provider.dart';

class MatchWordToPictureScreen extends ConsumerStatefulWidget {
  const MatchWordToPictureScreen({super.key});

  @override
  ConsumerState<MatchWordToPictureScreen> createState() => _MatchWordToPictureScreenState();
}

class _MatchWordToPictureScreenState extends ConsumerState<MatchWordToPictureScreen> {
  final List<Map<String, String>> _wordsAndPictures = [
    {'word': 'APPLE', 'picture': '🍎'},
    {'word': 'DOG', 'picture': '🐶'},
    {'word': 'CAT', 'picture': '🐱'},
    {'word': 'SUN', 'picture': '☀️'},
    {'word': 'CAR', 'picture': '🚗'},
    {'word': 'BIRD', 'picture': '🐦'},
    {'word': 'TREE', 'picture': '🌳'},
    {'word': 'FISH', 'picture': '🐟'},
  ];

  late String _currentWord;
  late String _correctPicture;
  late List<String> _options;
  bool _isSuccess = false;
  bool _isFailure = false;
  final Map<String, bool> _attemptedOptions = {};

  @override
  void initState() {
    super.initState();
    _generateLevel();
  }

  void _generateLevel() {
    final random = Random();
    final item = _wordsAndPictures[random.nextInt(_wordsAndPictures.length)];
    _currentWord = item['word']!;
    _correctPicture = item['picture']!;

    // Select 3 random incorrect options
    final otherItems = _wordsAndPictures.where((e) => e['word'] != _currentWord).toList();
    otherItems.shuffle();
    final incorrectOptions = otherItems.take(3).map((e) => e['picture']!).toList();

    _options = [...incorrectOptions, _correctPicture];
    _options.shuffle(random);

    setState(() {
      _isSuccess = false;
      _isFailure = false;
      _attemptedOptions.clear();
    });
  }

  void _onOptionSelected(String selectedPicture) {
    if (_isSuccess || _isFailure) return;

    if (selectedPicture == _correctPicture) {
      setState(() {
        _isSuccess = true;
        _attemptedOptions[selectedPicture] = true;
      });
      ref.read(userProvider.notifier).addPoints('Learning', 20);
    } else {
      setState(() {
        _attemptedOptions[selectedPicture] = false;
        _isFailure = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF), // Light blue background
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
                        // Word Display
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFF8C52FF).withValues(alpha: 0.3), width: 3),
                          ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _currentWord,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Options Grid
                        Expanded(
                          flex: 3,
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            physics: const NeverScrollableScrollPhysics(),
                            children: _options.map((emoji) {
                              Color borderColor = Colors.grey.withValues(alpha: 0.2);
                              double borderWidth = 2.0;
                              if (_attemptedOptions.containsKey(emoji)) {
                                borderColor = _attemptedOptions[emoji]! ? Colors.green : Colors.red;
                                borderWidth = 4.0;
                              }

                              return GestureDetector(
                                onTap: () => _onOptionSelected(emoji),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: borderColor, width: borderWidth),
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 70),
                                      ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.popWithSound(),
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
                colors: [Color(0xFF8C52FF), Color(0xFFFF914D)],
              ).createShader(bounds),
              child: const Text(
                'WORD MATCH',
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
