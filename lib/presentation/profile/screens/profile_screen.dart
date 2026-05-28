import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/child_standard_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/child_standard.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        ref.read(userProvider.notifier).updateAvatar(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final standardAsync = ref.watch(childStandardProvider);
    final standard = standardAsync.value ?? ChildStandard.standard1;
    
    String standardName = 'Standard 1';
    if (standard == ChildStandard.standard2) standardName = 'Standard 2';
    if (standard == ChildStandard.standard3) standardName = 'Standard 3';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Color(0xFFFFD6E5), // Soft Pink
              Color(0xFFFFB3C6), // Noticeable Pink
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: userState.when(
          data: (user) => SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 32),
                _buildAvatarSection(user),
                const SizedBox(height: 24),
                _buildStreakBadge(),
                const SizedBox(height: 32),
                _buildStatsRow(user),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/standard-selection'),
                    icon: const Icon(Icons.school_rounded, color: Colors.white),
                    label: Text(
                      'Change Learning Level ($standardName)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 20),
                _buildAchievementsGrid(user),
                const SizedBox(height: 100), // Padding for bottom nav bar
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orangePrimary)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF81D4FA),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: user.avatarPath != null
                ? Image.file(File(user.avatarPath!), fit: BoxFit.cover)
                : Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2D3142),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showSettingsBottomSheet(user),
          child: const Text(
            'Edit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF79F6F), // Custom soft orange
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(UserModel user) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8DA1), // Pinkish background for avatar
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: user.avatarPath != null
                      ? Image.file(File(user.avatarPath!), fit: BoxFit.cover)
                      : Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _showImageSourceActionSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF79F6F), // Orange pencil bg
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF79F6F), // Orange name text
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Age 3',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7F8B9C), // Grayish text
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E6), // Very light yellow/orange
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: Color(0xFFFFB74D), size: 20),
            SizedBox(width: 8),
            Text(
              '1 Day Streak!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFB74D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    int quizzes = (user.featurePoints['Quiz'] ?? 0) ~/ 20; 
    int stories = (user.featurePoints['Learning'] ?? 0) ~/ 30; 
    int totalPoints = user.totalPoints;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.psychology_rounded,
            iconColor: const Color(0xFFF79F6F),
            bgColor: const Color(0xFFFFF2EC), // Light orange bg
            number: quizzes.toString(),
            label: 'Quizzes',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFFFFD54F),
            bgColor: const Color(0xFFFFFDE7), // Light yellow bg
            number: totalPoints.toString(),
            label: 'Total Points',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFFFF8DA1),
            bgColor: const Color(0xFFFFF0F3), // Light pink bg
            number: stories.toString(),
            label: 'Stories',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required Color bgColor, required String number, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7F8B9C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(UserModel user) {
    final quizPoints = user.featurePoints['Quiz'] ?? 0;
    final learningPoints = user.featurePoints['Learning'] ?? 0;
    final puzzlePoints = user.featurePoints['Puzzle'] ?? 0;
    final totalPoints = user.totalPoints;

    final achievements = [
      {'title': 'Quiz Explorer', 'icon': Icons.search_rounded, 'color': Colors.lightBlue, 'locked': quizPoints == 0},
      {'title': 'Quiz Master', 'icon': Icons.emoji_events_rounded, 'color': Colors.amber, 'locked': quizPoints < 100},
      {'title': 'Story Creator', 'icon': Icons.brush_rounded, 'color': Colors.pinkAccent, 'locked': learningPoints == 0},
      {'title': 'Master Author', 'icon': Icons.menu_book_rounded, 'color': Colors.purpleAccent, 'locked': learningPoints < 100},
      {'title': 'Brainiac', 'icon': Icons.psychology_rounded, 'color': Colors.teal, 'locked': puzzlePoints < 50},
      {'title': 'All-Rounder', 'icon': Icons.star_rounded, 'color': Colors.orangeAccent, 'locked': totalPoints < 300},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final bool isLocked = achievement['locked'] as bool;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock_rounded : achievement['icon'] as IconData,
                color: isLocked ? const Color(0xFFB0BEC5) : achievement['color'] as Color,
                size: 38,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  achievement['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isLocked ? const Color(0xFFB0BEC5) : const Color(0xFF2D3142),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsBottomSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                const Text('MAGIC SETTINGS', style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
                const SizedBox(height: 24),
                _buildSettingsTile('Change Explorer Name', Icons.edit_rounded, AppColors.orangePrimary, onTap: () {
                  Navigator.pop(context);
                  _showEditNameDialog(user.name);
                }),
                const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF3F4F6)),
                _buildSettingsTile('Magical Sounds', Icons.volume_up_rounded, AppColors.primaryPink),
                const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF3F4F6)),
                _buildSettingsTile('Parental Control', Icons.lock_rounded, AppColors.primaryBlue),
                const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF3F4F6)),
                _buildSettingsTile('Delete Profile', Icons.delete_forever_rounded, Colors.red, onTap: () {
                  Navigator.pop(context);
                  _showDeleteProfileDialog();
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w800, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF7F8B9C)),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text('UPDATE AVATAR', style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryBlue),
                  ),
                  title: const Text('From Gallery', style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w800, fontSize: 16)),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
                  ),
                  title: const Text('From Camera', style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w800, fontSize: 16)),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('WHAT\'S YOUR NAME?', style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w900, fontSize: 18)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            hintText: 'Enter your name...',
            hintStyle: const TextStyle(color: Color(0xFF7F8B9C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF7F8B9C), fontWeight: FontWeight.w800))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(userProvider.notifier).updateName(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF79F6F), // Orange color
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showDeleteProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('DELETE PROFILE?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 18)),
        content: const Text(
          'Are you sure you want to delete your profile? All your stars and progress will be lost forever!',
          style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w600),
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF7F8B9C), fontWeight: FontWeight.w800))),
          ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier).resetProfile();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile reset successfully.', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
