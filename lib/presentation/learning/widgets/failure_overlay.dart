import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class FailureOverlay extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onFinished;

  const FailureOverlay({
    super.key,
    required this.isVisible,
    required this.onFinished,
  });

  @override
  State<FailureOverlay> createState() => _FailureOverlayState();
}

class _FailureOverlayState extends State<FailureOverlay> {
  // A sad/crying emoji lottie animation
  final String _lottieUrl = 'https://assets5.lottiefiles.com/packages/lf20_bhnno05h.json'; 
  Timer? _fallbackTimer;

  @override
  void didUpdateWidget(FailureOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Safety fallback timer in case Lottie gets stuck loading
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.isVisible) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return SizedBox.expand(
      child: IgnorePointer(
        ignoring: false, // Block touches while it's playing
        child: Stack(
          children: [
            // Lottie Animation
            if (widget.isVisible)
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.network(
                    _lottieUrl,
                    fit: BoxFit.contain,
                    repeat: false,
                    onLoaded: (composition) {
                      _fallbackTimer?.cancel();
                      // Wait for the animation to finish playing before dismissing
                      Future.delayed(composition.duration, () {
                        if (mounted && widget.isVisible) {
                          widget.onFinished();
                        }
                      });
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // If it fails to load, show fallback and dismiss quickly
                      _fallbackTimer?.cancel();
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted && widget.isVisible) {
                          widget.onFinished();
                        }
                      });
                      
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Text(
                          '😢',
                          style: TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
