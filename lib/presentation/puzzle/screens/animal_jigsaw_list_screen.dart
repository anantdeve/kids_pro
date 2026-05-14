import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../music/widgets/music_activity_card.dart';
import 'jigsaw_puzzle_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimalJigsawListScreen extends StatefulWidget {
  const AnimalJigsawListScreen({super.key});

  @override
  State<AnimalJigsawListScreen> createState() => _AnimalJigsawListScreenState();
}

class _AnimalJigsawListScreenState extends State<AnimalJigsawListScreen> {
  int _unlockedAnimalIndex = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _animals = const [
    {'name': 'Lion King 🦁', 'tag': 'lion', 'color': Colors.orangeAccent},
    {'name': 'Happy Elephant 🐘', 'tag': 'elephant', 'color': Colors.blueAccent},
    {'name': 'Cute Panda 🐼', 'tag': 'panda', 'color': Colors.grey},
    {'name': 'Playful Monkey 🐒', 'tag': 'monkey', 'color': Colors.brown},
    {'name': 'Magic Zebra 🦓', 'tag': 'zebra', 'color': Colors.blueGrey},
    {'name': 'Tall Giraffe 🦒', 'tag': 'giraffe', 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedAnimalIndex = prefs.getInt('jigsaw_unlocked_animal_index') ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _animals.length,
                    itemBuilder: (context, index) {
                      final animal = _animals[index];
                      final isLocked = index > _unlockedAnimalIndex;
                      
                      return IgnorePointer(
                        ignoring: isLocked,
                        child: Opacity(
                          opacity: isLocked ? 0.6 : 1.0,
                          child: MusicActivityCard(
                            title: isLocked ? 'Locked 🔒' : animal['name'],
                            subtitle: isLocked 
                                ? 'Complete the previous animal to unlock!' 
                                : 'Tap to solve the ${animal['tag']} puzzle!',
                            imagePath: 'assets/images/number_puzzle.png', 
                            themeColor: isLocked ? Colors.grey : animal['color'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JigsawPuzzleScreen(
                                    initialAnimalTag: animal['tag'],
                                    animalName: animal['name'],
                                    animalIndex: index,
                                  ),
                                ),
                              ).then((_) => _loadProgress());
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Color(0xFF334E68), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Choose an Animal 🦁',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF334E68),
            ),
          ),
        ],
      ),
    );
  }
}
