import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/providers/navigation_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    
    // Make avatar size dynamic based on screen width, max 60, min 40
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = (screenWidth * 0.12).clamp(40.0, 60.0);
    
    // Scale text slightly based on screen width
    final isSmallScreen = screenWidth < 360;

    return userState.when(
      data: (user) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Avatar with Glow
                GestureDetector(
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).setIndex(3);
                  },
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orangePrimary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user.avatarPath != null
                          ? Image.file(File(user.avatarPath!), fit: BoxFit.cover)
                          : Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
                    ),
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
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textGray, 
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Hi, ${user.name}!',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 22, 
                                color: AppColors.pinkPrimary, 
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('👋', style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Premium Points Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9F1C).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  user.totalPoints.toString(),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const Icon(Icons.error_outline),
    );
  }
}
