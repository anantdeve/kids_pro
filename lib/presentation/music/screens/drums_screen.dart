import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';

class DrumsScreen extends StatefulWidget {
  const DrumsScreen({super.key});

  @override
  State<DrumsScreen> createState() => _DrumsScreenState();
}

class _DrumsScreenState extends State<DrumsScreen> {
  final List<AudioPlayer> _players = List.generate(6, (_) {
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);
    return player;
  });
  int _currentPlayerIndex = 0;

  final List<Map<String, dynamic>> _drums = [
    {
      'title': 'Hi-Hat',
      'color': Color(0xFFFFD600),
      'image': 'assets/images/hi_hat.png',
      'sound': 'hi-hat.mp3',
    },
    {
      'title': 'Crash',
      'color': Color(0xFFFF9800),
      'image': 'assets/images/crash.png',
      'sound': 'crash.mp3',
    },
    {
      'title': 'Tom 1',
      'color': Color(0xFF00D4FF),
      'image': 'assets/images/drum_sticks.png',
      'sound': 'tom1.mp3',
    },
    {
      'title': 'Tom 2',
      'color': Color(0xFFB388FF),
      'image': 'assets/images/drum_sticks.png',
      'sound': 'tom2.mp3',
    },
    {
      'title': 'Snare',
      'color': Color(0xFFFF80AB),
      'image': 'assets/images/drum_sticks.png',
      'sound': 'snare.mp3',
    },
    {
      'title': 'Kick',
      'color': Color(0xFFFF5722),
      'image': 'assets/images/drum_sticks.png',
      'sound': 'kick.mp3',
    },
  ];

  void _playDrum(String soundFile) async {
    try {
      final player = _players[_currentPlayerIndex];
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      
      // Using low-latency mode, we just play
      await player.stop();
      await player.play(AssetSource('audio/drums/$soundFile'));
    } catch (e) {
      debugPrint('Error playing drum sound: $e');
    }
  }

  @override
  void dispose() {
    for (var player in _players) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Blurry Cloudy Background
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF9F5), Color(0xFFFDF2FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          // Soft Blurs
          Positioned(top: -50, left: -50, child: _BlurCircle(color: Color(0x33FFD180), size: 300)),
          Positioned(bottom: 100, right: -50, child: _BlurCircle(color: Color(0x2280D8FF), size: 400)),
          Positioned(top: 200, right: 0, child: _BlurCircle(color: Color(0x22F48FB1), size: 250)),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, screenWidth),
                
                const SizedBox(height: 10),
                
                // Instruction
                Text(
                  'Tap the drums to play a beat!',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.06).clamp(20.0, 24.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF8B66),
                  ),
                ),
                
                const Spacer(),
                
                // Drums Grid - Adjusted for precise matching
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DrumPad(data: _drums[0], onTap: () => _playDrum(_drums[0]['sound']), size: screenWidth * 0.32),
                          _DrumPad(data: _drums[1], onTap: () => _playDrum(_drums[1]['sound']), size: screenWidth * 0.32),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Closer together
                        children: [
                          _DrumPad(data: _drums[2], onTap: () => _playDrum(_drums[2]['sound']), size: screenWidth * 0.28),
                          const SizedBox(width: 20),
                          _DrumPad(data: _drums[3], onTap: () => _playDrum(_drums[3]['sound']), size: screenWidth * 0.28),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DrumPad(data: _drums[4], onTap: () => _playDrum(_drums[4]['sound']), size: screenWidth * 0.32),
                          _DrumPad(data: _drums[5], onTap: () => _playDrum(_drums[5]['sound']), size: screenWidth * 0.32),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.popWithSound(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(context).cardTheme.color ?? Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
              child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF334E68), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beat the rhythm!', style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textGray, fontWeight: FontWeight.w600)),
                Text('Fun Drums 🥁', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF334E68), height: 1.1)),
              ],
            ),
          ),
          Container(
            width: 45, height: 45,
            decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/avatar.png'), fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }
}

class _DrumPad extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final double size;

  const _DrumPad({required this.data, required this.onTap, required this.size});

  @override
  State<_DrumPad> createState() => _DrumPadState();
}

class _DrumPadState extends State<_DrumPad> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) { _controller.forward(); widget.onTap(); },
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size, height: widget.size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.data['color'], width: 10),
                    boxShadow: [
                      BoxShadow(color: widget.data['color'].withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(widget.data['image'], fit: BoxFit.contain, errorBuilder: (c, e, s) => Icon(Icons.music_note, color: widget.data['color'], size: 30)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Label Capsule
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: widget.data['color'].withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.data['title'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.data['color'].withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
