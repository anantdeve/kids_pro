import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/child_standard_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/child_standard.dart';

class StandardSelectionScreen extends ConsumerStatefulWidget {
  const StandardSelectionScreen({super.key});

  @override
  ConsumerState<StandardSelectionScreen> createState() => _StandardSelectionScreenState();
}

class _StandardSelectionScreenState extends ConsumerState<StandardSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: Theme.of(context).brightness == Brightness.light ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Color(0xFFFFD6E5), // Soft Pink
              Color(0xFFFFB3C6), // Noticeable Pink
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ) : null,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          children: [
                            // Floating Image Header
                            AnimatedBuilder(
                              animation: _floatAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatAnimation.value),
                                  child: Container(
                                    height: screenHeight * 0.22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/splash_child.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            // Welcome Text
                            Text(
                              'Choose Your Level!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).textTheme.displayLarge?.color ?? AppColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pick the perfect learning journey for your child.',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryPink.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    
                    // Animated Cards Container with Gradient
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: Theme.of(context).brightness == Brightness.light ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color(0xFFFFD6E5), // Soft pink
                            ],
                          ) : null,
                          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardTheme.color : null,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildAnimatedCard(
                              index: 0,
                              standard: ChildStandard.standard1,
                              title: 'Standard 1',
                              subtitle: 'Ages 5-6 • Basic Fun & Learning',
                              color: AppColors.primaryPink,
                              icon: Icons.auto_awesome_rounded,
                              tag: 'Start Here!',
                            ),
                            const SizedBox(height: 12),
                            _buildAnimatedCard(
                              index: 1,
                              standard: ChildStandard.standard2,
                              title: 'Standard 2',
                              subtitle: 'Ages 6-7 • Medium Challenges',
                              color: AppColors.primaryPink,
                              icon: Icons.rocket_launch_rounded,
                              tag: 'Popular',
                            ),
                            const SizedBox(height: 12),
                            _buildAnimatedCard(
                              index: 2,
                              standard: ChildStandard.standard3,
                              title: 'Standard 3',
                              subtitle: 'Ages 7-8 • Advanced Puzzles',
                              color: AppColors.primaryPink,
                              icon: Icons.psychology_rounded,
                              tag: 'Advanced',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)), // Bottom padding
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required int index,
    required ChildStandard standard,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String tag,
  }) {
    // Calculate slide animation based on index
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          0.3 + (index * 0.2), // Staggered start
          0.8 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: _StandardCard(
        standard: standard,
        title: title,
        subtitle: subtitle,
        color: color,
        icon: icon,
        tag: tag,
        onTap: () async {
          await ref.read(childStandardProvider.notifier).updateStandard(standard);
          if (mounted) {
            ref.read(navigationIndexProvider.notifier).setIndex(0);
            context.go('/home');
          }
        },
      ),
    );
  }
}

// Separate stateful widget for the bounce effect on tap
class _StandardCard extends StatefulWidget {
  final ChildStandard standard;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String tag;
  final VoidCallback onTap;

  const _StandardCard({
    required this.standard,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.tag,
    required this.onTap,
  });

  @override
  State<_StandardCard> createState() => _StandardCardState();
}

class _StandardCardState extends State<_StandardCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 150), widget.onTap);
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: widget.color.withValues(alpha: 0.2),
              width: 3,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withValues(alpha: 0.7),
                            widget.color,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: widget.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: widget.color.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ],
                ),
              ),
              // Tag Badge
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
