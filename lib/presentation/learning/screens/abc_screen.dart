import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/get_learning_items_usecase.dart';
import '../viewmodels/learning_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_provider.dart';

class AbcScreen extends ConsumerWidget {
  const AbcScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(learningItemsProvider(LearningCategory.alphabet));
    final audioPlayer = ref.read(audioPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn ABC'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: asyncItems.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (items) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  audioPlayer.playAudio(item.audioUrl);
                  
                  // Award dynamic points
                  ref.read(userProvider.notifier).addPoints('Learning', 5);

                  // Show some animation feedback
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.title} for ${item.subtitle}! (+5 Stars)'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryPink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Since we might not have actual image assets yet, fallback to icon
                      const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
