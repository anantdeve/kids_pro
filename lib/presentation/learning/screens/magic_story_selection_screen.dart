import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';

class MagicStorySelectionScreen extends StatefulWidget {
  const MagicStorySelectionScreen({super.key});

  @override
  State<MagicStorySelectionScreen> createState() => _MagicStorySelectionScreenState();
}

class _MagicStorySelectionScreenState extends State<MagicStorySelectionScreen> {
  String? selectedHero;
  String? selectedPlace;
  bool isLoading = false;

  final List<Map<String, dynamic>> heroes = [
    {'name': 'Astronaut', 'emoji': '👨‍🚀', 'color': const Color(0xFFCBE9FF)},
    {'name': 'Dinosaur', 'emoji': '🦖', 'color': const Color(0xFFD4F0D4)},
    {'name': 'Princess', 'emoji': '👸', 'color': const Color(0xFFFFCBE6)},
    {'name': 'Robot', 'emoji': '🤖', 'color': const Color(0xFFE5D4FF)},
  ];

  final List<Map<String, dynamic>> places = [
    {'name': 'Moon', 'emoji': '🌙', 'color': const Color(0xFFE2E9F0)},
    {'name': 'Candy Land', 'emoji': '🍭', 'color': const Color(0xFFFFD9EC)},
    {'name': 'Underwater', 'emoji': '🌊', 'color': const Color(0xFFCBE9FF)},
    {'name': 'Forest', 'emoji': '🌳', 'color': const Color(0xFFD4F0D4)},
  ];

  Future<void> _generateStory() async {
    if (selectedHero == null || selectedPlace == null) return;

    setState(() => isLoading = true);

    try {
      // IMPORTANT: Replace with your actual API key. 
      // Do not commit your key to GitHub!
      const apiKey = 'OPEN API KEY';
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a magical storyteller for children aged 3-5. Create very short, simple, and happy stories.'
            },
            {
              'role': 'user',
              'content': 'Create a short 4-sentence story about a $selectedHero who visits $selectedPlace. Use simple words and emojis.'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final story = data['choices'][0]['message']['content'];
        if (mounted) {
          _showStoryReader(story);
        }
      } else {
        throw Exception('Failed to load story');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oops! The magic is taking a nap. Try again!')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showStoryReader(String story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryReaderScreen(
          story: story,
          hero: selectedHero!,
          place: selectedPlace!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(screenWidth),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSectionTitle('Pick your Hero!', screenWidth),
                        const SizedBox(height: 16),
                        _buildGrid(heroes, true, screenWidth),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Pick a Place!', screenWidth),
                        const SizedBox(height: 16),
                        _buildGrid(places, false, screenWidth),
                        SizedBox(height: screenHeight * 0.15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: screenHeight * 0.04,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              child: _buildActionBtn(screenWidth),
            ),
            if (isLoading)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
                      const SizedBox(height: 24),
                      Text(
                        'Creating Magic...',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFE8E0),
              padding: const EdgeInsets.all(10),
              minimumSize: const Size(44, 44),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Create Your Story ✨',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (screenWidth * 0.055).clamp(18.0, 24.0),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ),
          ),
          CircleAvatar(
            radius: (screenWidth * 0.045).clamp(16.0, 20.0),
            backgroundColor: const Color(0xFFCBE9FF),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.07,
        fontWeight: FontWeight.w900,
        color: const Color(0xFFFF7A59),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items, bool isHero, double screenWidth) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = isHero ? selectedHero == item['name'] : selectedPlace == item['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isHero) {
                selectedHero = item['name'];
              } else {
                selectedPlace = item['name'];
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF7A59) : Colors.transparent,
                width: 4,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: item['color'].withValues(alpha: 0.6), blurRadius: 15, offset: const Offset(0, 8))]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(item['emoji'], style: TextStyle(fontSize: screenWidth * 0.12)),
                ),
                const SizedBox(height: 8),
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFFFF7A59) : const Color(0xFF2D3436).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(double screenWidth) {
    final bool canGenerate = selectedHero != null && selectedPlace != null;

    return GestureDetector(
      onTap: canGenerate ? _generateStory : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: canGenerate ? const Color(0xFFE2E0D4) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(50),
          boxShadow: canGenerate
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]
              : null,
          border: Border.all(
            color: canGenerate ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "Let's Go! 🚀",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.w900,
            color: canGenerate ? const Color(0xFFFF7A59) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class StoryReaderScreen extends StatelessWidget {
  final String story;
  final String hero;
  final String place;

  const StoryReaderScreen({
    super.key,
    required this.story,
    required this.hero,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE8E0),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Your Story ✨',
                      style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 20),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.08),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7A59).withValues(alpha: 0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFFF7A59).withValues(alpha: 0.1), width: 2),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD600), size: 50),
                          const SizedBox(height: 24),
                          Text(
                            story,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.055,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'The End ❤️',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF7A59),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
