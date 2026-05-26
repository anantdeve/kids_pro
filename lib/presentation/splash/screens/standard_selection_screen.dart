import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/child_standard_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/child_standard.dart';

class StandardSelectionScreen extends ConsumerWidget {
  const StandardSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blueLight,
              AppColors.orangeLight,
              AppColors.softSky,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to KidsPro!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select your child\'s learning level to personalize their experience:',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildStandardCard(
                  context: context,
                  ref: ref,
                  standard: ChildStandard.standard1,
                  title: 'Standard 1',
                  subtitle: 'Age 5-6 \nBasic learning & fun',
                  color: AppColors.primaryPink,
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: 20),
                _buildStandardCard(
                  context: context,
                  ref: ref,
                  standard: ChildStandard.standard2,
                  title: 'Standard 2',
                  subtitle: 'Age 6-7 \nMedium difficulty',
                  color: AppColors.orangePrimary,
                  icon: Icons.explore_rounded,
                ),
                const SizedBox(height: 20),
                _buildStandardCard(
                  context: context,
                  ref: ref,
                  standard: ChildStandard.standard3,
                  title: 'Standard 3',
                  subtitle: 'Age 7-8 \nAdvanced puzzles & logic',
                  color: AppColors.primaryBlue,
                  icon: Icons.psychology_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardCard({
    required BuildContext context,
    required WidgetRef ref,
    required ChildStandard standard,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await ref.read(childStandardProvider.notifier).updateStandard(standard);
          if (context.mounted) {
            context.go('/home');
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
