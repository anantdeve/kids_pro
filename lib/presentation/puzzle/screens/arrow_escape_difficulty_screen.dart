import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/magical_blob.dart';
import 'arrow_escape_level_screen.dart';
import 'arrow_escape_screen.dart';

class ArrowEscapeDifficultyScreen extends StatefulWidget {
  const ArrowEscapeDifficultyScreen({super.key});

  @override
  State<ArrowEscapeDifficultyScreen> createState() => _ArrowEscapeDifficultyScreenState();
}

class _ArrowEscapeDifficultyScreenState extends State<ArrowEscapeDifficultyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF5F8), Color(0xFFF0F7FF), Color(0xFFFFF9E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(top: -50, left: -50, child: MagicalBlob(size: 300, color: const Color(0xFFFFD1E1).withValues(alpha: 0.6))),
          Positioned(bottom: -50, right: -50, child: MagicalBlob(size: 350, color: const Color(0xFFE1F5FE).withValues(alpha: 0.7))),
          Positioned(top: 200, right: -100, child: MagicalBlob(size: 250, color: const Color(0xFFE8DDFF).withValues(alpha: 0.5))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildDifficultyCard(context, 'Easy', '5x5 Grid • Very Simple', AppColors.primaryGreen, Icons.sentiment_very_satisfied_rounded, ArrowDifficulty.easy),
                      const SizedBox(height: 20),
                      _buildDifficultyCard(context, 'Medium', '6x6 Grid • A Bit Tricky', const Color(0xFFFFB347), Icons.sentiment_satisfied_rounded, ArrowDifficulty.medium),
                      const SizedBox(height: 20),
                      _buildDifficultyCard(context, 'Hard', '7x7 Grid • Brain Teaser', AppColors.primaryPink, Icons.local_fire_department_rounded, ArrowDifficulty.hard),
                      const SizedBox(height: 40),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arrow Escape',
                  style: TextStyle(fontSize: 14, color: AppColors.textGray, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Select Difficulty',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900, 
                    color: const Color(0xFF334E68),
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, String title, String subtitle, Color color, IconData icon, ArrowDifficulty difficulty) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArrowEscapeLevelScreen(difficulty: difficulty)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGray)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
