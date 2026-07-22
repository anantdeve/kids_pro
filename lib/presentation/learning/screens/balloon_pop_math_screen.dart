import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import 'dart:async';

class BalloonPopMathScreen extends StatefulWidget {
  const BalloonPopMathScreen({super.key});

  @override
  State<BalloonPopMathScreen> createState() => _BalloonPopMathScreenState();
}

class _BalloonPopMathScreenState extends State<BalloonPopMathScreen> {
  int score = 0;
  int timeLeft = 60;
  Timer? _gameTimer;
  Timer? _spawnTimer;

  int num1 = 0;
  int num2 = 0;
  int get correctAnswer => num1 + num2;

  List<_BalloonData> activeBalloons = [];
  final math.Random _random = math.Random();
  
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 800));
    _generateEquation();
    _startGame();
  }

  void _startGame() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            _endGame();
          }
        });
      }
    });

    _spawnTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && timeLeft > 0) {
        _spawnBalloon();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _showGameOverDialog();
  }

  void _generateEquation() {
    num1 = _random.nextInt(10) + 1;
    num2 = _random.nextInt(10) + 1;
    activeBalloons.clear();
    // Immediately spawn the correct answer so it's possible to win
    _spawnBalloon(forceCorrect: true);
    _spawnBalloon();
    _spawnBalloon();
  }

  void _spawnBalloon({bool forceCorrect = false}) {
    if (activeBalloons.length >= 8) return; // Max balloons on screen

    int value;
    if (forceCorrect) {
      value = correctAnswer;
    } else {
      value = correctAnswer + _random.nextInt(10) - 5;
      if (value == correctAnswer || value < 0) value = correctAnswer + 2;
    }

    final double xPosition = _random.nextDouble() * 0.8 + 0.1; // 10% to 90% of screen width
    final Color color = _getRandomColor();
    final String id = DateTime.now().microsecondsSinceEpoch.toString() + _random.nextInt(1000).toString();

    setState(() {
      activeBalloons.add(_BalloonData(
        id: id,
        value: value,
        xPosition: xPosition,
        color: color,
        speed: _random.nextDouble() * 2 + 3, // Random speed
      ));
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF7B9C), // Pink
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFFB74D), // Orange
      const Color(0xFF8C52FF), // Purple
      const Color(0xFF00BF63), // Green
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _handleBalloonTap(_BalloonData balloon) {
    if (balloon.value == correctAnswer) {
      // Correct!
      _confettiController.play();
      setState(() {
        score += 10;
        activeBalloons.removeWhere((b) => b.id == balloon.id);
        _generateEquation(); // Next round
      });
    } else {
      // Wrong!
      setState(() {
        score = math.max(0, score - 5);
        activeBalloons.removeWhere((b) => b.id == balloon.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! That was the wrong balloon.', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 500),
        )
      );
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Time\'s Up! ⏰', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You scored:', style: TextStyle(fontSize: 20)),
            Text('$score', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF4ECDC4))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // close dialog
              context.pop(); // close screen
            },
            child: const Text('Back to Hub', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7B9C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              context.pop();
              setState(() {
                score = 0;
                timeLeft = 60;
                activeBalloons.clear();
                _generateEquation();
                _startGame();
              });
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6FA),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8FD3FF), Color(0xFFDDF6FF)],
              ),
            ),
          ),

          // Active Balloons
          ...activeBalloons.map((balloon) => _AnimatedBalloonWidget(
                key: ValueKey(balloon.id),
                data: balloon,
                onTap: () => _handleBalloonTap(balloon),
                onOffScreen: () {
                  if (mounted) {
                    setState(() {
                      activeBalloons.removeWhere((b) => b.id == balloon.id);
                    });
                  }
                },
              )),

          // Confetti for correct answers
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.yellow, Colors.green, Colors.pink, Colors.blue],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar (Back, Timer, Score)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32),
                        onPressed: () => context.pop(),
                      ),
                      
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: timeLeft <= 10 ? Colors.redAccent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_rounded, color: timeLeft <= 10 ? Colors.white : const Color(0xFF2D3142)),
                            const SizedBox(width: 8),
                            Text(
                              '$timeLeft s',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: timeLeft <= 10 ? Colors.white : const Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              '$score',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Equation Board
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Text(
                      '$num1 + $num2 = ?',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF4ECDC4)),
                    ),
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

class _BalloonData {
  final String id;
  final int value;
  final double xPosition; // 0.0 to 1.0
  final Color color;
  final double speed; // seconds to reach top

  _BalloonData({
    required this.id,
    required this.value,
    required this.xPosition,
    required this.color,
    required this.speed,
  });
}

class _AnimatedBalloonWidget extends StatefulWidget {
  final _BalloonData data;
  final VoidCallback onTap;
  final VoidCallback onOffScreen;

  const _AnimatedBalloonWidget({
    super.key,
    required this.data,
    required this.onTap,
    required this.onOffScreen,
  });

  @override
  State<_AnimatedBalloonWidget> createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<_AnimatedBalloonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.data.speed * 1000).toInt()),
    );

    _yAnimation = Tween<double>(begin: 1.2, end: -0.2).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onOffScreen();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _yAnimation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Add a slight wobble on the X axis
        final wobble = math.sin(_yAnimation.value * math.pi * 10) * 15;

        return Positioned(
          top: screenHeight * _yAnimation.value,
          left: (screenWidth * widget.data.xPosition) + wobble - 40, // 40 is half balloon width
          child: GestureDetector(
            onTap: widget.onTap,
            child: _buildBalloon(),
          ),
        );
      },
    );
  }

  Widget _buildBalloon() {
    return SizedBox(
      width: 80,
      height: 120,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Balloon String
          Positioned(
            bottom: 0,
            child: Container(
              width: 2,
              height: 40,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          
          // Balloon Body
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(
              color: widget.data.color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
                bottom: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(color: widget.data.color.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.data.value}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
              ),
            ),
          ),
          
          // Specular highlight (reflection)
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              width: 15,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
