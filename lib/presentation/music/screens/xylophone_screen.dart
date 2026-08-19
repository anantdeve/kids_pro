import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';

class XylophoneScreen extends StatefulWidget {
  const XylophoneScreen({super.key});

  @override
  State<XylophoneScreen> createState() => _XylophoneScreenState();
}

class _XylophoneScreenState extends State<XylophoneScreen> {
  final List<AudioPlayer> _players = List.generate(8, (_) {
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);
    return player;
  });
  int _currentPlayerIndex = 0;

  final List<Map<String, dynamic>> _notes = [
    {'note': 'note1.wav', 'color': const Color(0xFFFF5252), 'label': 'C', 'widthFactor': 0.95},
    {'note': 'note2.wav', 'color': const Color(0xFFFFAB40), 'label': 'D', 'widthFactor': 0.88},
    {'note': 'note3.wav', 'color': const Color(0xFFFFD740), 'label': 'E', 'widthFactor': 0.81},
    {'note': 'note4.wav', 'color': const Color(0xFF69F0AE), 'label': 'F', 'widthFactor': 0.74},
    {'note': 'note5.wav', 'color': const Color(0xFF40C4FF), 'label': 'G', 'widthFactor': 0.67},
    {'note': 'note6.wav', 'color': const Color(0xFF7C4DFF), 'label': 'A', 'widthFactor': 0.60},
    {'note': 'note7.wav', 'color': const Color(0xFFE040FB), 'label': 'B', 'widthFactor': 0.53},
  ];

  String? _activeNote;

  void _playNote(String note) async {
    setState(() => _activeNote = note);

    try {
      final player = _players[_currentPlayerIndex];
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      
      await player.stop();
      await player.play(AssetSource('audio/xylophone/$note'));
    } catch (e) {
      debugPrint('Error playing xylophone note: $e');
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _activeNote == note) {
        setState(() => _activeNote = null);
      }
    });
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
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Magical Background
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF5FDFF), Color(0xFFFFF5FB)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          
          // Floating clouds/decorations
          Positioned(top: 100, left: -20, child: _DecorativeCloud(size: 150, opacity: 0.4)),
          Positioned(bottom: 50, right: -30, child: _DecorativeCloud(size: 200, opacity: 0.3)),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, screenWidth),
                
                const SizedBox(height: 20),
                
                Text(
                  'Tap the rainbow bars!',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.05).clamp(18.0, 22.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF8B66),
                  ),
                ),
                
                const Spacer(),
                
                // Xylophone Bars
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: _notes.map((noteData) {
                      return _XylophoneBar(
                        data: noteData,
                        isActive: _activeNote == noteData['note'],
                        onTap: () => _playNote(noteData['note']),
                        screenWidth: screenWidth,
                      );
                    }).toList(),
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
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF334E68), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rainbow melodies!',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textGray, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Happy Xylophone 🌈',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF334E68),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 45, height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage('assets/images/avatar.png'), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class _XylophoneBar extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isActive;
  final VoidCallback onTap;
  final double screenWidth;

  const _XylophoneBar({
    required this.data,
    required this.isActive,
    required this.onTap,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: screenWidth * data['widthFactor'],
          height: (screenWidth * 0.12).clamp(45.0, 65.0),
          transform: isActive ? (Matrix4.identity()..scale(0.98)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: isActive ? data['color'].withValues(alpha: 0.8) : data['color'],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: data['color'].withValues(alpha: 0.4),
                blurRadius: isActive ? 4 : 12,
                offset: isActive ? const Offset(0, 2) : const Offset(0, 6),
              ),
              // Highlights for "3D" effect
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 0,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Screws/Circles on sides
              Positioned(left: 20, top: 0, bottom: 0, child: _BarScrew()),
              Positioned(right: 20, top: 0, bottom: 0, child: _BarScrew()),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarScrew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
      ),
    );
  }
}

class _DecorativeCloud extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorativeCloud({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(Icons.cloud, size: size, color: Colors.blue.withValues(alpha: 0.1)),
    );
  }
}
