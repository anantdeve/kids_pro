import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({super.key});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    // Breathing pulse for the whole card
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Floating animation for the book sticker
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 40; // Horizontal margins
    final cardHeight = (screenWidth * 0.48).clamp(180.0, 240.0);
    final imageSize = (screenWidth * 0.65).clamp(220.0, 320.0);

    return GestureDetector(
      onTap: () => context.push('/magic-story'),
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: cardHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Large rounded corners as per image
            border: Border.all(color: Colors.white, width: 8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF06292).withValues(alpha: 0.15), // Soft pink shadow from image
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. Background Gradient with Highlight
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFB5E8), // Top-left highlight
                        Color(0xFFF06292), // Vibrant Mid-pink
                        Color(0xFFBA68C8), // Soft Purple-pink
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Tilted White Background Sheet (The "Page")
              Positioned(
                right: -screenWidth * 0.1,
                top: -cardHeight * 0.2,
                bottom: -cardHeight * 0.2,
                width: screenWidth * 0.55,
                child: Transform.rotate(
                  angle: -0.22, // Tilted exactly as image
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(-5, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Text Content
              Positioned(
                left: 5,
                top: 0,
                bottom: 0,
                right: screenWidth * 0.42,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 8),
                            Text(
                              'NEW ADVENTURE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Magic Story\nBook Maker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Match the large bold look of the image
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: Text(
                        'Tap to create your own',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12, // More visible subtext
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. The Book Image (Floating & Tilted)
              Positioned(
                right: -screenWidth * 0.08,
                bottom: -cardHeight * 0.2,
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Transform.rotate(
                        angle: 0.05, // Slight tilt for the book sticker
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/magic_book.png',
                    width: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 5. Yellow Sparkles (Exactly as in image)
              const Positioned(
                right: 155,
                top: 90,
                child: _TwinklingStar(size: 34, delay: 0),
              ),
              const Positioned(
                right: 175,
                top: 125,
                child: _TwinklingStar(size: 18, delay: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwinklingStar extends StatefulWidget {
  final double size;
  final int delay;

  const _TwinklingStar({required this.size, required this.delay});

  @override
  State<_TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<_TwinklingStar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(Icons.auto_awesome, color: const Color(0xFFFFD600), size: widget.size),
    );
  }
}
