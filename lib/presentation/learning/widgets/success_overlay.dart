import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuccessOverlay extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onFinished;
  final bool showBadge;

  const SuccessOverlay({
    super.key,
    required this.isVisible,
    required this.onFinished,
    this.showBadge = false,
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay> with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late AnimationController _confettiController;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        _updateParticles();
      });
  }

  @override
  void didUpdateWidget(SuccessOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    // Create particles
    for (int i = 0; i < 100; i++) {
      _particles.add(ConfettiParticle(
        color: _getRandomColor(),
        random: _random,
      ));
    }

    _badgeController.forward(from: 0);
    _confettiController.forward(from: 0);
    
    // Provide haptic feedback
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _badgeController.reverse();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onFinished();
        });
      }
    });
  }

  void _updateParticles() {
    setState(() {
      for (var p in _particles) {
        p.update(_confettiController.value);
      }
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF7B9C), // Pink
      const Color(0xFFB497FF), // Purple
      const Color(0xFFFFD166), // Yellow
      const Color(0xFF67E1F5), // Blue
      const Color(0xFF5CD6A1), // Green
      const Color(0xFFFF8B66), // Orange
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && _badgeController.isDismissed) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !widget.isVisible,
      child: Stack(
        children: [
          // Dimmed Background
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: widget.isVisible ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Confetti
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(particles: _particles),
            ),
          ),

          // Success Badge
          if (widget.showBadge)
            Center(
              child: ScaleTransition(
              scale: _badgeScale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🌟',
                          style: TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFF7B9C), Color(0xFFB497FF)],
                          ).createShader(bounds),
                          child: const Text(
                            'GREAT JOB!',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiParticle {
  late double x, y;
  late double vx, vy;
  late double size;
  final Color color;
  late double rotation;
  late double rotationSpeed;
  final math.Random random;

  ConfettiParticle({required this.color, required this.random}) {
    reset();
  }

  void reset() {
    // Start from center
    x = 0.5;
    y = 0.4;
    
    // Random explosion velocity
    double angle = random.nextDouble() * 2 * math.pi;
    double speed = random.nextDouble() * 0.05 + 0.01;
    vx = math.cos(angle) * speed;
    vy = math.sin(angle) * speed - 0.02; // Initial upward boost
    
    size = random.nextDouble() * 10 + 5;
    rotation = random.nextDouble() * 2 * math.pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
  }

  void update(double progress) {
    // Gravity
    vy += 0.0015;
    
    // Drag
    vx *= 0.98;
    vy *= 0.98;
    
    x += vx;
    y += vy;
    rotation += rotationSpeed;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color;
      final center = Offset(p.x * size.width, p.y * size.height);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(p.rotation);
      
      // Draw different shapes
      if (p.random.nextBool()) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
