import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/learning_tts_service.dart';

class TtsAnimatedSpeaker extends ConsumerWidget {
  final VoidCallback onTap;
  final bool isMuted;
  final Color? color;
  final double size;

  const TtsAnimatedSpeaker({
    super.key,
    required this.onTap,
    this.isMuted = false,
    this.color,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsService = ref.watch(learningTtsServiceProvider);
    final isSpeaking = ttsService.isSpeaking;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isSpeaking ? 12 : 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isSpeaking 
                  ? (color ?? const Color(0xFFFF8B66)).withValues(alpha: 0.5) 
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSpeaking ? 15 : 10,
              spreadRadius: isSpeaking ? 5 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: 1.0, end: isSpeaking ? 1.2 : 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Icon(
                isMuted ? Icons.volume_off_rounded : (isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined),
                color: isMuted ? Colors.grey : (color ?? Theme.of(context).textTheme.displayLarge?.color ?? Colors.black87),
                size: size,
              ),
            );
          },
        ),
      ),
    );
  }
}
