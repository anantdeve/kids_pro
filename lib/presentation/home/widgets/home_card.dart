import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color shadowColor;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);

    // Floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + (widget.title.length * 100)), // Variation in speed
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: -8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        
        return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _floatAnimation]),
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.shadowColor.withValues(alpha: 0.5),
                        widget.shadowColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: widget.shadowColor,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5), // The border thickness
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25.5),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          flex: 1,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: (cardHeight * 0.08).clamp(12.0, 18.0),
                              fontWeight: FontWeight.w900,
                              color: AppColors.orangePrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          flex: 1,
                          child: Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: (cardHeight * 0.06).clamp(10.0, 14.0),
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textGray,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
