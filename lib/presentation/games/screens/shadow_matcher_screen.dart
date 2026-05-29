import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math';

class ShadowMatcherScreen extends StatefulWidget {
  const ShadowMatcherScreen({super.key});

  @override
  State<ShadowMatcherScreen> createState() => _ShadowMatcherScreenState();
}

class _ShadowMatcherScreenState extends State<ShadowMatcherScreen> {
  late List<AnimalItem> animals;
  late List<AnimalItem> shadows;
  Map<int, bool> matches = {};
  int round = 1;
  final Random random = Random();

  final Map<String, List<String>> gameData = {
    'Animals': ['🦊', '🐢', '🐘', '🐨', '🦁', '🦒', '🦓', '🐸', '🐼', '🐯', '🐧', '🦉'],
    'Fruits': ['🍎', '🍌', '🍉', '🍇', '🍓', '🍍', '🍒', '🥝', '🍑', '🍋', '🍐', '🥭'],
    'Vehicles': ['🚗', '✈️', '🚢', '🚂', '🚁', '🚜', '🚲', '🚑', '🚒', '🚀', '🛵', '🚌'],
    'Toys': ['🧸', '🪀', '🪁', '🏀', '🎲', '🧩', '🎨', '🎺', '🥁', '🛹', '🎳', '🎮'],
  };

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame({bool incrementRound = false}) {
    if (incrementRound) round++;
    
    // Pick a random category
    final categories = gameData.keys.toList();
    final String category = categories[random.nextInt(categories.length)];
    final List<String> icons = gameData[category]!..shuffle();
    
    final List<String> selectedIcons = icons.take(4).toList();
    
    setState(() {
      animals = selectedIcons.asMap().entries.map((e) => AnimalItem(id: e.key, emoji: e.value)).toList();
      shadows = List.from(animals)..shuffle();
      matches = {};
    });
  }

  void _checkVictory() {
    if (matches.length == 4) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _startNewGame(incrementRound: true);
        }
      });
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Brilliant! 🕵️✨', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D3142))),
              const SizedBox(height: 20),
              const Text('🌟 🌟 🌟', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 20),
              const Text('You matched all the animals!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Color(0xFF5C677D))),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startNewGame();
                    },
                    child: const Text('Play Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF8A65))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final stickerSize = (screenWidth * 0.18).clamp(60.0, 85.0);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth),
            const SizedBox(height: 20),
            _buildInstructionBanner(screenWidth),
            const Spacer(flex: 1),
            _buildShadowRow(stickerSize),
            const Spacer(flex: 2),
            _buildAnimalRow(stickerSize),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D3142), size: 32),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Shadow Matcher 🕵️',
                style: TextStyle(
                  fontSize: (screenWidth * 0.075).clamp(22.0, 30.0),
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBanner(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Match the Animal Stickers! ✨',
        style: TextStyle(
          fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFF8A65),
        ),
      ),
    );
  }

  Widget _buildShadowRow(double stickerSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: shadows.map((item) {
          final isMatched = matches.containsKey(item.id);
          return DragTarget<AnimalItem>(
            onAcceptWithDetails: (details) {
              if (details.data.id == item.id) {
                setState(() {
                  matches[item.id] = true;
                });
                _checkVictory();
              }
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: stickerSize,
                height: stickerSize,
                decoration: BoxDecoration(
                  color: isMatched ? Colors.white : const Color(0xFFEEEEEE).withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isMatched ? Colors.white : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                  boxShadow: isMatched
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isMatched
                        ? Text(
                            item.emoji,
                            key: ValueKey('matched_${item.id}'),
                            style: TextStyle(fontSize: stickerSize * 0.5),
                          )
                        : Opacity(
                            key: ValueKey('shadow_${item.id}'),
                            opacity: 0.15,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0, 0, 0, 0, 80,
                                0, 0, 0, 0, 80,
                                0, 0, 0, 0, 80,
                                0, 0, 0, 1, 0,
                              ]),
                              child: Text(item.emoji, style: TextStyle(fontSize: stickerSize * 0.5)),
                            ),
                          ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimalRow(double stickerSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: animals.map((item) {
          final isMatched = matches.containsKey(item.id);
          if (isMatched) {
            return SizedBox(width: stickerSize, height: stickerSize);
          }
          return Draggable<AnimalItem>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: _buildSticker(item.emoji, stickerSize, isDragging: true),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildSticker(item.emoji, stickerSize),
            ),
            child: _buildSticker(item.emoji, stickerSize),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSticker(String emoji, double stickerSize, {bool isDragging = false}) {
    return Container(
      width: stickerSize,
      height: stickerSize,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.2 : 0.08),
            blurRadius: isDragging ? 20 : 10,
            offset: Offset(0, isDragging ? 10 : 4),
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: stickerSize * 0.5)),
      ),
    );
  }
}

class AnimalItem {
  final int id;
  final String emoji;

  AnimalItem({required this.id, required this.emoji});
}
