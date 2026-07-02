import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class SuccessOverlay extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onFinished;
  final bool showBadge;
  final String? lottieUrl;
  final BoxFit? lottieFit;
  final double? lottieSize;

  const SuccessOverlay({
    super.key,
    required this.isVisible,
    required this.onFinished,
    this.showBadge = false,
    this.lottieUrl,
    this.lottieFit,
    this.lottieSize,
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay> with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  late String _currentLottieUrl;

  final List<String> _defaultLotties = [
    'https://assets9.lottiefiles.com/packages/lf20_obhph3sh.json', // Confetti
    'https://assets10.lottiefiles.com/packages/lf20_rovf9gzu.json', // Confetti 2
    'https://assets9.lottiefiles.com/packages/lf20_pkanqwys.json', // Star burst
    'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json',   // Celebration
  ];

  @override
  void initState() {
    super.initState();
    _currentLottieUrl = widget.lottieUrl ?? (List.from(_defaultLotties)..shuffle()).first;
    
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didUpdateWidget(SuccessOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      if (widget.lottieUrl == null) {
        setState(() {
          _currentLottieUrl = (List.from(_defaultLotties)..shuffle()).first;
        });
      }
      _startCelebration();
    }
  }

  void _startCelebration() {
    _badgeController.forward(from: 0);
    
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

  @override
  void dispose() {
    _badgeController.dispose();
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

          // Lottie Confetti Animation
          if (widget.isVisible)
            Positioned.fill(
              child: widget.lottieSize != null
                  ? Center(
                      child: SizedBox(
                        width: widget.lottieSize,
                        height: widget.lottieSize,
                        child: Lottie.network(
                          _currentLottieUrl,
                          fit: widget.lottieFit ?? BoxFit.contain,
                          repeat: false,
                        ),
                      ),
                    )
                  : Lottie.network(
                      _currentLottieUrl,
                      fit: widget.lottieFit ?? BoxFit.cover,
                      repeat: false,
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
