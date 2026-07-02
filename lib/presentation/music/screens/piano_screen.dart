import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Map<String, AudioPlayer> _players = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    void initPlayer(Map<String, dynamic> note) {
      final player = AudioPlayer();
      player.setPlayerMode(PlayerMode.lowLatency);
      player.setReleaseMode(ReleaseMode.stop);
      player.setSource(AssetSource('piano/${note['file']}'));
      _players[note['id']] = player;
    }

    for (var note in _whiteNotes) {
      initPlayer(note);
    }
    for (var note in _blackNotes) {
      initPlayer(note);
    }
  }
  
  // White keys data (2 Octaves for wider keys)
  final List<Map<String, dynamic>> _whiteNotes = [
    // Octave 4
    {'id': 'w1', 'file': 'C4.mp3', 'color': Color(0xFFFFD1E5)},
    {'id': 'w2', 'file': 'D4.mp3', 'color': Color(0xFFD1E9FF)},
    {'id': 'w3', 'file': 'E4.mp3', 'color': Color(0xFFD1EFE2)},
    {'id': 'w4', 'file': 'F4.mp3', 'color': Color(0xFFE1D1FF)},
    {'id': 'w5', 'file': 'G4.mp3', 'color': Color(0xFFFFE1D1)},
    {'id': 'w6', 'file': 'A4.mp3', 'color': Color(0xFFFFEDD1)},
    {'id': 'w7', 'file': 'B4.mp3', 'color': Color(0xFFFFD1D1)},
    // Octave 5
    {'id': 'w8', 'file': 'C5.mp3', 'color': Color(0xFFFFC1D5)},
    {'id': 'w9', 'file': 'D5.mp3', 'color': Color(0xFFC1D9FF)},
    {'id': 'w10', 'file': 'E5.mp3', 'color': Color(0xFFC1DFD2)},
    {'id': 'w11', 'file': 'F5.mp3', 'color': Color(0xFFD1C1FF)},
    {'id': 'w12', 'file': 'G5.mp3', 'color': Color(0xFFFFD1C1)},
    {'id': 'w13', 'file': 'A5.mp3', 'color': Color(0xFFFFDDC1)},
    {'id': 'w14', 'file': 'B5.mp3', 'color': Color(0xFFFFC1C1)},
  ];

  // Black keys data
  final List<Map<String, dynamic>> _blackNotes = [
    // Octave 4
    {'id': 'b1', 'file': 'Db4.mp3', 'color': Color(0xFFFF49C6), 'position': 1},
    {'id': 'b2', 'file': 'Eb4.mp3', 'color': Color(0xFF16B6CA), 'position': 2},
    {'id': 'b3', 'file': 'Gb4.mp3', 'color': Color(0xFF6E47B2), 'position': 4},
    {'id': 'b4', 'file': 'Ab4.mp3', 'color': Color(0xFFEF7A55), 'position': 5},
    {'id': 'b5', 'file': 'Bb4.mp3', 'color': Color(0xFFEDC825), 'position': 6},
    // Octave 5
    {'id': 'b6', 'file': 'Db5.mp3', 'color': Color(0xFFFF39B6), 'position': 8},
    {'id': 'b7', 'file': 'Eb5.mp3', 'color': Color(0xFF06A6BA), 'position': 9},
    {'id': 'b8', 'file': 'Gb5.mp3', 'color': Color(0xFF5E37A2), 'position': 11},
    {'id': 'b9', 'file': 'Ab5.mp3', 'color': Color(0xFFDF6A45), 'position': 12},
    {'id': 'b10', 'file': 'Bb5.mp3', 'color': Color(0xFFDDB815), 'position': 13},
  ];

  final Map<int, String> _pointerLastNote = {};
  final ValueNotifier<Set<String>> _activeNotesNotifier = ValueNotifier({});
  DateTime? _lastPointsAwarded;

  void _playNote(Map<String, dynamic> noteData) {
    final String id = noteData['id'];

    final newNotes = Set<String>.from(_activeNotesNotifier.value);
    newNotes.add(id);
    _activeNotesNotifier.value = newNotes;

    final player = _players[id];
    if (player != null) {
      // stop() resets position to 0 without causing SoundPool seek exceptions
      player.stop().then((_) {
        player.resume();
      });
    }

    // Award points at most once every 2 seconds to prevent lag
    final now = DateTime.now();
    if (_lastPointsAwarded == null || now.difference(_lastPointsAwarded!).inSeconds >= 2) {
      if (mounted) {
        ref.read(userProvider.notifier).addPoints('Music', 1);
      }
      _lastPointsAwarded = now;
    }
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _activeNotesNotifier.value.contains(id)) {
        final currentNotes = Set<String>.from(_activeNotesNotifier.value);
        currentNotes.remove(id);
        _activeNotesNotifier.value = currentNotes;
      }
    });
  }

  void _handlePointerEvent(PointerEvent event, double pianoWidth, double padding, double pianoHeight) {
    final double localX = event.localPosition.dx - padding;
    final double whiteKeyWidth = pianoWidth / _whiteNotes.length;
    
    Map<String, dynamic>? touchedNoteData;

    // Check black keys first (top layer)
    for (var black in _blackNotes) {
      double blackKeyWidth = whiteKeyWidth * 0.65;
      double leftPos = (black['position'] * whiteKeyWidth) - (blackKeyWidth / 2);
      if (localX >= leftPos && localX <= leftPos + blackKeyWidth && event.localPosition.dy < (pianoHeight * 0.6)) {
        touchedNoteData = black;
        break;
      }
    }

    // If no black key touched, check white keys
    if (touchedNoteData == null) {
      int index = (localX / whiteKeyWidth).floor();
      if (index >= 0 && index < _whiteNotes.length) {
        touchedNoteData = _whiteNotes[index];
      }
    }

    if (touchedNoteData != null) {
      final String id = touchedNoteData['id'];
      if (_pointerLastNote[event.pointer] != id) {
        _pointerLastNote[event.pointer] = id;
        _playNote(touchedNoteData);
      }
    } else {
      _pointerLastNote.remove(event.pointer);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    for (var player in _players.values) {
      player.dispose();
    }
    _activeNotesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    final double horizontalPadding = isTablet ? screenWidth * 0.05 : 2;
    final double pianoAreaWidth = screenWidth - (horizontalPadding * 2);
    final double whiteKeyWidth = pianoAreaWidth / _whiteNotes.length;

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
                        onTap: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          Navigator.pop(context);
                        },
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
                
                const SizedBox(height: 16),
                
                // Realistic Piano Keyboard
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double pianoHeight = constraints.maxHeight;
                      return Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (event) => _handlePointerEvent(event, pianoAreaWidth, horizontalPadding, pianoHeight),
                        onPointerMove: (event) => _handlePointerEvent(event, pianoAreaWidth, horizontalPadding, pianoHeight),
                        onPointerUp: (event) => _pointerLastNote.remove(event.pointer),
                        onPointerCancel: (event) => _pointerLastNote.remove(event.pointer),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: ValueListenableBuilder<Set<String>>(
                            valueListenable: _activeNotesNotifier,
                            builder: (context, activeNotes, _) {
                              return Stack(
                                children: [
                                  // White Keys Layer
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: _whiteNotes.map((note) {
                                      return Expanded(
                                        child: _WhiteKey(
                                          color: note['color'],
                                          isPressed: activeNotes.contains(note['id']),
                                          width: whiteKeyWidth,
                                        ),
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
                                        color: note['color'],
                                        isPressed: activeNotes.contains(note['id']),
                                        width: blackKeyWidth,
                                        height: pianoHeight * 0.6,
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteKey extends StatelessWidget {
  final Color color;
  final bool isPressed;
  final double width;

  const _WhiteKey({
    required this.color,
    required this.isPressed,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _BlackKey extends StatelessWidget {
  final Color color;
  final bool isPressed;
  final double width;
  final double height;

  const _BlackKey({
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
    );
  }
}
