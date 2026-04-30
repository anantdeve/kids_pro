import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardHeight = (screenWidth * 0.48).clamp(180.0, 240.0);
        final imageWidth = (screenWidth * 0.55).clamp(200.0, 260.0);

        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Coming Soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: cardHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. The Main Card Container
                Container(
                  width: double.infinity,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAEEB), // Base pink color
                    border: Border.all(color: Colors.white, width: 8),
                    borderRadius: BorderRadius.circular(10)// Thick white border

                  ),
                  clipBehavior: Clip.antiAlias, // Important for the rotated box
                  child: Stack(
                    children: [
                      // 2. The Main Pink/Purple Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.magicBookGradient,
                          ),
                        ),
                      ),

                      // 3. The Tilted White Background Sheet
                      Positioned(
                        right: -screenWidth * 0.1,
                        top: -cardHeight * 0.5,
                        bottom: -cardHeight * 0.5,
                        width: screenWidth * 0.5,
                        child: Transform.rotate(
                          angle: -0.25, // Tilted counter-clockwise like design
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // 4. Text Content
                      Positioned(
                        left: 24,
                        top: 0,
                        bottom: 0,
                        right: imageWidth * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'NEW ADVENTURE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Magic Story\nBook Maker',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.08).clamp(24.0, 36.0),
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to create your own',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 5. Triple Sparkle Stars (Yellow Stars from design)
                    ],
                  ),
                ),

                // 6. The Overlapping Magic Book Sticker (Properly set outside to bleed)
                Positioned(
                  right: -screenWidth * 0.05,
                  top: -cardHeight * 0.22, // Bleed out top
                  bottom: -cardHeight * 0.1,
                  width: imageWidth,
                  child: Image.asset(
                    'assets/images/magic_book.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
