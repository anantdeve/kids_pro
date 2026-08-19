import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';
import '../../learning/widgets/success_overlay.dart';
import '../../../core/providers/user_provider.dart';

class MemoryMatchScreen extends ConsumerStatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  ConsumerState<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends ConsumerState<MemoryMatchScreen> {
  late List<MemoryCard> cards;
  int? firstSelectedIndex;
  int? secondSelectedIndex;
  bool isChecking = false;
  int matchesFound = 0;
  int totalPairs = 8;
  int moves = 0;
  bool _isSuccess = false;

  final List<String> gameIcons = [
    '🍎', '🍌', '🍇', '🍓', '🍒', '🍍', '🥝', '🍉',
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final List<String> selectedIcons = (gameIcons..shuffle()).take(totalPairs).toList();
    final List<String> pairList = [...selectedIcons, ...selectedIcons];
    pairList.shuffle();

    setState(() {
      cards = pairList.map((icon) => MemoryCard(icon: icon)).toList();
      firstSelectedIndex = null;
      secondSelectedIndex = null;
      isChecking = false;
      matchesFound = 0;
      moves = 0;
    });
  }

  void _onCardTap(int index) {
    if (isChecking || cards[index].isFlipped || cards[index].isMatched) return;

    setState(() {
      cards[index].isFlipped = true;
      if (firstSelectedIndex == null) {
        firstSelectedIndex = index;
      } else {
        secondSelectedIndex = index;
        isChecking = true;
        moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (cards[firstSelectedIndex!].icon == cards[secondSelectedIndex!].icon) {
      setState(() {
        cards[firstSelectedIndex!].isMatched = true;
        cards[secondSelectedIndex!].isMatched = true;
        matchesFound++;
        firstSelectedIndex = null;
        secondSelectedIndex = null;
        isChecking = false;
      });

      // Award points per perfect match immediately
      ref.read(userProvider.notifier).addPoints('Memory Match', 10);

      if (matchesFound == totalPairs) {
        _showVictoryDialog();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            cards[firstSelectedIndex!].isFlipped = false;
            cards[secondSelectedIndex!].isFlipped = false;
            firstSelectedIndex = null;
            secondSelectedIndex = null;
            isChecking = false;
          });
        }
      });
    }
  }

  void _showVictoryDialog() {
    setState(() {
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth),
            _buildStats(screenWidth),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: GridView.builder(
                  itemCount: cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 6 : 4,
                    crossAxisSpacing: screenWidth * 0.03,
                    mainAxisSpacing: screenWidth * 0.03,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    return MemoryCardWidget(
                      card: cards[index],
                      onTap: () => _onCardTap(index),
                      fontSize: (screenWidth * 0.08).clamp(28.0, 48.0),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SuccessOverlay(
        isVisible: _isSuccess,
        onFinished: () {
          setState(() {
            _isSuccess = false;
            _startNewGame();
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.popWithSound(),
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D3142), size: 32),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Memory Match 🧠',
                style: TextStyle(
                  fontSize: (screenWidth * 0.07).clamp(22.0, 30.0),
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

  Widget _buildStats(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Points', (matchesFound * 10).toString(), screenWidth),
          _buildStatItem('Moves', moves.toString(), screenWidth),
          IconButton(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFF8A65), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, double screenWidth) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: (screenWidth * 0.04).clamp(12.0, 16.0), 
            color: const Color(0xFF8D99AE), 
            fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: (screenWidth * 0.06).clamp(18.0, 24.0), 
            fontWeight: FontWeight.w800, 
            color: const Color(0xFFFF8A65)
          ),
        ),
      ],
    );
  }
}

class MemoryCard {
  final String icon;
  bool isFlipped;
  bool isMatched;

  MemoryCard({required this.icon, this.isFlipped = false, this.isMatched = false});
}

class MemoryCardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final double fontSize;

  const MemoryCardWidget({
    super.key, 
    required this.card, 
    required this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0, end: card.isFlipped || card.isMatched ? 1.0 : 0.0),
        builder: (context, value, child) {
          final isBack = value > 0.5;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi),
            alignment: Alignment.center,
            child: isBack
                ? _buildFront(context)
                : _buildBack(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..rotateY(pi),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(card.icon, style: TextStyle(fontSize: fontSize)),
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A65),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFE53935), // Red question mark
          ),
        ),
      ),
    );
  }
}
