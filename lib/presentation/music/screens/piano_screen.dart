import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_provider.dart';

class PianoScreen extends ConsumerStatefulWidget {
  const PianoScreen({super.key});

  @override
  ConsumerState<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends ConsumerState<PianoScreen> {
  final List<AudioPlayer> _players = List.generate(8, (_) => AudioPlayer());
  int _currentPlayerIndex = 0;
  
  // White keys data
  final List<Map<String, dynamic>> _whiteNotes = [
    {'note': 'c.mp3', 'label': 'C', 'color': Color(0xFFFFE1F5)}, // Light Pink
    {'note': 'd.mp3', 'label': 'D', 'color': Color(0xFFE1F9FF)}, // Light Blue
    {'note': 'e.mp3', 'label': 'E', 'color': Color(0xFFE1FFF2)}, // Light Green
    {'note': 'f.mp3', 'label': 'F', 'color': Color(0xFFF1E1FF)}, // Light Purple
    {'note': 'g.mp3', 'label': 'G', 'color': Color(0xFFFFF1E1)}, // Light Orange
    {'note': 'a.mp3', 'label': 'A', 'color': Color(0xFFFFFDE1)}, // Light Yellow
    {'note': 'b.mp3', 'label': 'B', 'color': Color(0xFFFFE1E1)}, // Light Red
  ];

  // Black keys data
  final List<Map<String, dynamic>> _blackNotes = [
    {'note': 'cs4.mp3', 'label': 'C', 'color': Color(0xFFFF59D6), 'position': 1},
    {'note': 'ds4.mp3', 'label': 'D', 'color': Color(0xFF26C6DA), 'position': 2},
    {'note': 'fs4.mp3', 'label': 'F', 'color': Color(0xFF7E57C2), 'position': 4},
    {'note': 'gs4.mp3', 'label': 'G', 'color': Color(0xFFFF8A65), 'position': 5},
    {'note': 'as4.mp3', 'label': 'A', 'color': Color(0xFFFDD835), 'position': 6},
  ];

  final Map<int, String> _pointerLastNote = {};
  String? _activeNote;

  void _playNote(String note) async {
    setState(() {
      _activeNote = note;
    });

    final player = _players[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    
    await player.stop();
    await player.play(AssetSource('audio/piano/$note'));

    // Award dynamic points for playing music
    ref.read(userProvider.notifier).addPoints('Music', 1);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _activeNote == note) {
        setState(() {
          _activeNote = null;
        });
      }
    });
  }

  void _handlePointerEvent(PointerEvent event, double pianoWidth, double padding) {
    final double localX = event.localPosition.dx - padding;
    final double whiteKeyWidth = pianoWidth / 7;
    
    String? touchedNote;

    // Check black keys first (top layer)
    for (var black in _blackNotes) {
      double blackKeyWidth = whiteKeyWidth * 0.65;
      double leftPos = (black['position'] * whiteKeyWidth) - (blackKeyWidth / 2);
      if (localX >= leftPos && localX <= leftPos + blackKeyWidth && event.localPosition.dy < 250) {
        touchedNote = black['note'];
        break;
      }
    }

    // If no black key touched, check white keys
    if (touchedNote == null) {
      int index = (localX / whiteKeyWidth).floor();
      if (index >= 0 && index < _whiteNotes.length) {
        touchedNote = _whiteNotes[index]['note'];
      }
    }

    if (touchedNote != null) {
      if (_pointerLastNote[event.pointer] != touchedNote) {
        _pointerLastNote[event.pointer] = touchedNote;
        _playNote(touchedNote);
      }
    } else {
      _pointerLastNote.remove(event.pointer);
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
    final isTablet = screenWidth > 600;
    
    final double horizontalPadding = isTablet ? screenWidth * 0.1 : 20;
    final double pianoAreaWidth = screenWidth - (horizontalPadding * 2);
    final double whiteKeyWidth = pianoAreaWidth / 7;

    return Scaffold(
      body: Stack(
        children: [
          if (Theme.of(context).brightness == Brightness.light)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFFAF0),
                      Color(0xFFFFE4E1),
                      Color(0xFFFFF5EE),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color?.withOpacity(0.5) ?? Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF334E68), size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Play beautiful music!',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textGray, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Magic Piano 🎹',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.05).clamp(20.0, 24.0),
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).textTheme.displayLarge?.color ?? const Color(0xFF334E68),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 1),
                
                Text(
                  'Tap the keys to play music!',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.05).clamp(18.0, 22.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF8B66),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Realistic Piano Keyboard
                Listener(
                  onPointerDown: (event) => _handlePointerEvent(event, pianoAreaWidth, horizontalPadding),
                  onPointerMove: (event) => _handlePointerEvent(event, pianoAreaWidth, horizontalPadding),
                  onPointerUp: (event) => _pointerLastNote.remove(event.pointer),
                  onPointerCancel: (event) => _pointerLastNote.remove(event.pointer),
                  child: Container(
                    height: 400,
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Stack(
                      children: [
                        // White Keys Layer
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: _whiteNotes.map((note) {
                            return _WhiteKey(
                              label: note['label'],
                              color: note['color'],
                              isPressed: _activeNote == note['note'],
                              width: whiteKeyWidth,
                            );
                          }).toList(),
                        ),
                        // Black Keys Layer
                        ..._blackNotes.map((note) {
                          double blackKeyWidth = whiteKeyWidth * 0.65;
                          double leftPos = (note['position'] * whiteKeyWidth) - (blackKeyWidth / 2);
                          return Positioned(
                            left: leftPos,
                            child: _BlackKey(
                              label: note['label'],
                              color: note['color'],
                              isPressed: _activeNote == note['note'],
                              width: blackKeyWidth,
                              height: 240,
                            ),
                          );
                        }),
                      ],
                    ),
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
}

class _WhiteKey extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPressed;
  final double width;

  const _WhiteKey({
    required this.label,
    required this.color,
    required this.isPressed,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width - 2,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: isPressed ? color.withOpacity(0.5) : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _BlackKey extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPressed;
  final double width;
  final double height;

  const _BlackKey({
    required this.label,
    required this.color,
    required this.isPressed,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isPressed ? color : const Color(0xFF2D2D2D),
            const Color(0xFF000000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isPressed ? Colors.white : color.withOpacity(0.6),
        ),
      ),
    );
  }
}
