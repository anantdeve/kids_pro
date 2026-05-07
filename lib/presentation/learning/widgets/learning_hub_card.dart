import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LearningHubCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? titleEmoji;
  final String? secondaryEmoji;
  final String imagePath;
  final IconData fallbackIcon;
  final Color titleColor;
  final VoidCallback onTap;

  const LearningHubCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleEmoji,
    this.secondaryEmoji,
    required this.imagePath,
    required this.fallbackIcon,
    required this.titleColor,
    required this.onTap,
  });

  @override
  State<LearningHubCard> createState() => _LearningHubCardState();
}

class _LearningHubCardState extends State<LearningHubCard> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + (widget.title.length * 50)),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.16).clamp(60.0, 75.0);

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnimation.value),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.titleColor.withValues(alpha: 0.4),
              widget.titleColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(27.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(27.5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.titleColor.withValues(alpha: 0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(iconSize / 2),
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.titleColor.withValues(alpha: 0.1),
                                  widget.titleColor.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              widget.fallbackIcon,
                              color: widget.titleColor,
                              size: iconSize * 0.45,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: widget.titleColor.withValues(alpha: 0.8),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              if (widget.titleEmoji != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  widget.titleEmoji!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ],
                          ),
                          if (widget.secondaryEmoji != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.secondaryEmoji!,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.titleColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: widget.titleColor.withValues(alpha: 0.4),
                        size: 24,
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
  }
}
