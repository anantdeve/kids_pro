import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Make avatar size dynamic based on screen width, max 60, min 40
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = (screenWidth * 0.12).clamp(40.0, 60.0);
    
    // Scale text slightly based on screen width
    final isSmallScreen = screenWidth < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/avatar.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowGlow, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Greeting Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for an adventure?',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12, 
                        color: AppColors.textGray, 
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Hi, Nothing!',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20, 
                              color: AppColors.orangePrimary, 
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('👋', style: TextStyle(fontSize: isSmallScreen ? 14 : 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Points Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.orangeLight, width: 1.5),
            boxShadow: const [
              BoxShadow(color: AppColors.shadowGlow, blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: isSmallScreen ? 16 : 20),
              const SizedBox(width: 4),
              Text(
                '800',
                style: TextStyle(
                  color: AppColors.orangePrimary, 
                  fontWeight: FontWeight.bold, 
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
