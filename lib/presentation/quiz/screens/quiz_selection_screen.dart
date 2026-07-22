import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/providers/child_standard_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../domain/entities/child_standard.dart';
import '../../../data/repositories/local_quiz_repository.dart';

class QuizSelectionScreen extends ConsumerWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standardAsync = ref.watch(childStandardProvider);
    final standard = standardAsync.value ?? ChildStandard.standard1;
    
    final userAsync = ref.watch(userProvider);
    final currentPoints = userAsync.value?.featurePoints['Quiz'] ?? 0;

    List<Map<String, dynamic>> categories = [];
    if (standard == ChildStandard.standard1) {
      categories = [
        {'id': LocalQuizRepository.catAnimals, 'name': 'Animals', 'emoji': '🐶', 'requiredPoints': 0, 'level': 1, 'color': const Color(0xFF4FC3F7)},
        {'id': LocalQuizRepository.catShapesColors, 'name': 'Shapes & Colors', 'emoji': '🔴', 'requiredPoints': 100, 'level': 2, 'color': const Color(0xFF4DB6AC)},
        {'id': LocalQuizRepository.catFruitsVeggies, 'name': 'Fruits & Veggies', 'emoji': '🍎', 'requiredPoints': 200, 'level': 3, 'color': const Color(0xFF9575CD)},
        {'id': LocalQuizRepository.catToys, 'name': 'Toys & Play', 'emoji': '🧸', 'requiredPoints': 400, 'level': 4, 'color': const Color(0xFFFFB74D)},
        {'id': LocalQuizRepository.catFarmFriends, 'name': 'Farm Friends', 'emoji': '🐄', 'requiredPoints': 600, 'level': 5, 'color': const Color(0xFF81C784)},
        {'id': 9, 'name': 'MCQ', 'emoji': '🧠', 'requiredPoints': 800, 'level': 6, 'color': const Color(0xFFF06292), 'isApi': true},
      ];
    } else if (standard == ChildStandard.standard2) {
      categories = [
        {'id': LocalQuizRepository.catAnimals, 'name': 'Animals', 'emoji': '🦁', 'requiredPoints': 0, 'level': 1, 'color': const Color(0xFF4FC3F7)},
        {'id': LocalQuizRepository.catVehicles, 'name': 'Vehicles', 'emoji': '🚗', 'requiredPoints': 100, 'level': 2, 'color': const Color(0xFF4DB6AC)},
        {'id': LocalQuizRepository.catEverydayObjects, 'name': 'Everyday Objects', 'emoji': '⏰', 'requiredPoints': 200, 'level': 3, 'color': const Color(0xFF9575CD)},
        {'id': LocalQuizRepository.catWeather, 'name': 'Weather', 'emoji': '🌦️', 'requiredPoints': 400, 'level': 4, 'color': const Color(0xFFFFB74D)},
        {'id': LocalQuizRepository.catDinosaurs, 'name': 'Dinosaurs', 'emoji': '🦖', 'requiredPoints': 600, 'level': 5, 'color': const Color(0xFF81C784)},
      ];
    } else {
      categories = [
        {'id': LocalQuizRepository.catVehicles, 'name': 'Vehicles', 'emoji': '🚀', 'requiredPoints': 0, 'level': 1, 'color': const Color(0xFF4FC3F7)},
        {'id': LocalQuizRepository.catEverydayObjects, 'name': 'Everyday Objects', 'emoji': '🎸', 'requiredPoints': 100, 'level': 2, 'color': const Color(0xFF4DB6AC)},
        {'id': LocalQuizRepository.catPlanetsSpace, 'name': 'Planets & Space', 'emoji': '🪐', 'requiredPoints': 200, 'level': 3, 'color': const Color(0xFF9575CD)},
        {'id': LocalQuizRepository.catOccupations, 'name': 'Occupations', 'emoji': '👨‍⚕️', 'requiredPoints': 400, 'level': 4, 'color': const Color(0xFFFFB74D)},
        {'id': LocalQuizRepository.catHealthyFoods, 'name': 'Healthy Foods', 'emoji': '🥗', 'requiredPoints': 600, 'level': 5, 'color': const Color(0xFF81C784)},
      ];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient Mesh Effect
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE8F6FA),
                      Color(0xFFFEF2F4),
                      Color(0xFFFAFAFA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, currentPoints),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isLocked = currentPoints < cat['requiredPoints'];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (index * 150)),
                        curve: Curves.easeOutBack,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _PortalCard(
                            title: cat['name'],
                            subtitle: cat['subtitle'],
                            level: cat['level'],
                            emoji: cat['emoji'],
                            color: cat['color'],
                            isLocked: isLocked,
                            requiredPoints: cat['requiredPoints'],
                            onTap: () {
                              if (cat['isApi'] == true) {
                                context.push('/api-quiz?categoryId=${cat['id']}&difficulty=easy');
                              } else {
                                context.push('/magic-quiz?categoryId=${cat['id']}&difficulty=easy');
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int points) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFB347),
                        Color(0xFFFF7B9C),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Quiz Topics',
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width * 0.07).clamp(24.0, 32.0),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCC80), width: 2),
            ),
            child: Row(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  points.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF57C00),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int level;
  final String emoji;
  final Color color;
  final bool isLocked;
  final int requiredPoints;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    this.subtitle,
    required this.level,
    required this.emoji,
    required this.color,
    required this.isLocked,
    required this.requiredPoints,
    required this.onTap,
  });

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> with SingleTickerProviderStateMixin {
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
    Widget cardContent = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withValues(alpha: 0.4),
            widget.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(37.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Icon area
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.isLocked ? '🔒' : widget.emoji,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: widget.isLocked ? Colors.grey[600] : const Color(0xFFFF8A65), // Salmon
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.isLocked ? Colors.grey[500] : widget.color,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      widget.isLocked ? 'Needs ${widget.requiredPoints} Stars' : 'LEVEL ${widget.level}',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.isLocked ? Colors.grey[500] : (Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF8D99AE)),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                widget.isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: widget.isLocked ? Colors.grey[400] : widget.color.withValues(alpha: 0.4),
                size: widget.isLocked ? 24 : 30,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isLocked) {
      cardContent = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.33, 0.33, 0.33, 0, 0,
          0.33, 0.33, 0.33, 0, 0,
          0.33, 0.33, 0.33, 0, 0,
          0,    0,    0,    1, 0,
        ]),
        child: cardContent,
      );
    }

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, widget.isLocked ? 0 : _floatAnimation.value),
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.isLocked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('🔒', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You need ${widget.requiredPoints} Stars to unlock this level! Keep playing!',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFFFA726), // Orange
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            : widget.onTap,
        child: Opacity(
          opacity: widget.isLocked ? 0.7 : 1.0,
          child: cardContent,
        ),
      ),
    );
  }
}
