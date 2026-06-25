import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;
  late AnimationController _gradientController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Main Entry Animation (Scale & Fade)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    ]).animate(_mainController);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // 2. Floating Animation for the Child Image
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 3. Gradient Shimmer Animation for Text
    _gradientController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3),
    )..repeat();

    _mainController.forward();

    // Navigate to home/auth after animation sequence
    Future.delayed(const Duration(milliseconds: 4500), () async {
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      final hasStandard = prefs.containsKey('child_standard_selection');
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (mounted) {
        if (currentUser == null) {
          context.go('/auth');
        } else if (hasStandard) {
          context.go('/home');
        } else {
          context.go('/standard-selection');
        }
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color(0xFFFFD6E5), // Soft Pink
                      Color(0xFFFFB3C6), // Noticeable Pink
                    ],
                  ),
                ),
              ),
            ),

          // Animated Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Child Image
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 20, // Reduced from 30 for better performance
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/splash_child.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                          cacheWidth: 500, // Decode image at smaller resolution
                        ),
                      ),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // KidsPro Gradient Animated Text
                    AnimatedBuilder(
                      animation: _gradientController,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: const [
                                Color(0xFFFF4081), // Pink
                                Color(0xFF7C4DFF), // Purple
                                Color(0xFF00BCD4), // Cyan
                                Color(0xFFFF4081), // Pink back
                              ],
                              stops: [
                                _gradientController.value - 0.2,
                                _gradientController.value,
                                _gradientController.value + 0.2,
                                _gradientController.value + 0.4,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              tileMode: TileMode.clamp,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'KidsPro',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Learning Made Fun!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
