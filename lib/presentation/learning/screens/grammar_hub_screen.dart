import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../core/providers/user_provider.dart';

class GrammarHubScreen extends ConsumerStatefulWidget {
  const GrammarHubScreen({super.key});

  @override
  ConsumerState<GrammarHubScreen> createState() => _GrammarHubScreenState();
}

class _GrammarHubScreenState extends ConsumerState<GrammarHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final grammarPoints = userState.value?.featurePoints['Grammar'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFCAF0F8), // Fresh sky blue theme for grammar
      body: Stack(
        children: [
          // Magical Sky Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF48CAE4), Color(0xFF90E0EF), Color(0xFFCAF0F8)],
              ),
            ),
          ),
          
          // Animated Clouds
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              final screenHeight = MediaQuery.of(context).size.height;
              return Stack(
                children: [
                  _buildCloud(context, 0.2, screenHeight * 0.4, _backgroundController.value),
                  _buildCloud(context, 0.5, screenHeight * 0.55, _backgroundController.value + 0.3),
                  _buildCloud(context, 0.8, screenHeight * 0.45, _backgroundController.value + 0.6),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      _buildBackButton(context),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grammar',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.0,
                                shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Points Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFF9F1C), size: 24),
                            const SizedBox(width: 4),
                            Text(
                              '$grammarPoints',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF073B4C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Grid of Games
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                    children: [
                      _buildGameCard(
                        context: context,
                        title: 'Fill in the\nBlanks',
                        icon: '📝',
                        colors: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
                        route: '/fill-in-the-blanks',
                      ),
                      _buildGameCard(
                        context: context,
                        title: 'Sentence\nBuilder',
                        icon: '🧩',
                        colors: [const Color(0xFF06D6A0), const Color(0xFF80ED99)],
                        route: '/sentence-builder',
                      ),
                      _buildGameCard(
                        context: context,
                        title: 'Find the\nMistake',
                        icon: '🔍',
                        colors: [const Color(0xFF118AB2), const Color(0xFF48CAE4)],
                        route: '/find-mistake',
                      ),
                      _buildGameCard(
                        context: context,
                        title: 'Picture\nGrammar',
                        icon: '🖼️',
                        colors: [const Color(0xFFFFB703), const Color(0xFFFFD166)],
                        route: '/picture-grammar',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
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
    );
  }

  Widget _buildCloud(BuildContext context, double scale, double topOffset, double progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    final p = progress % 1.0;
    final leftPos = -100.0 + (screenWidth + 200) * p;
    
    return Positioned(
      top: topOffset,
      left: leftPos,
      child: Icon(
        Icons.cloud_rounded,
        color: Colors.white.withValues(alpha: 0.95), // Highly visible white
        size: 150 * scale, // Make clouds slightly larger
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String icon,
    required List<Color> colors,
    required String route,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: _BouncingCard(
        title: title,
        icon: icon,
        colors: colors,
        onTap: () {
          context.push(route);
        },
      ),
    );
  }
}

class _BouncingCard extends StatefulWidget {
  final String title;
  final String icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _BouncingCard({
    required this.title,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<_BouncingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    Future.delayed(Duration(milliseconds: math.Random().nextInt(1000)), () {
      if (mounted) {
        _controller.repeat(reverse: true, period: const Duration(seconds: 2));
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.stop();
        _controller.value = 1.0;
        _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
        _controller.forward(from: 0);
      },
      onTapUp: (_) {
        _controller.reverse().then((_) {
          widget.onTap();
          _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(_controller);
          _controller.repeat(reverse: true, period: const Duration(seconds: 2));
        });
      },
      onTapCancel: () {
        _controller.reverse().then((_) {
          _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(_controller);
          _controller.repeat(reverse: true, period: const Duration(seconds: 2));
        });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: widget.colors[0].withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: widget.icon.endsWith('.png')
                    ? ClipOval(
                        child: Image.asset(
                          widget.icon,
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 40),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
