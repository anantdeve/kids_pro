import 'package:flutter/material.dart';
import 'package:kids_pro/core/utils/navigation_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/magical_blob.dart';
import 'arrow_escape_screen.dart';

class ArrowEscapeLevelScreen extends StatelessWidget {
  final ArrowDifficulty difficulty;
  const ArrowEscapeLevelScreen({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    String diffName;
    Color themeColor;
    
    switch (difficulty) {
      case ArrowDifficulty.easy:
        diffName = 'Easy';
        themeColor = AppColors.primaryGreen;
        break;
      case ArrowDifficulty.medium:
        diffName = 'Medium';
        themeColor = const Color(0xFFFFB347);
        break;
      case ArrowDifficulty.hard:
        diffName = 'Hard';
        themeColor = AppColors.primaryPink;
        break;
    }

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
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, diffName, themeColor),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ArrowEscapeScreen(difficulty: difficulty, startLevel: levelNumber)
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 3),
                            boxShadow: [
                              BoxShadow(color: themeColor.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$levelNumber',
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
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

  Widget _buildHeader(BuildContext context, String diffName, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.popWithSound(),
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
                Text(
                  '$diffName Levels',
                  style: TextStyle(fontSize: 14, color: themeColor, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Select Level',
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
}
