import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/child_standard_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/child_standard.dart';
import '../../../core/providers/settings_provider.dart';
import 'dart:math';

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
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
        child: userState.when(
          data: (user) {
            final screenWidth = MediaQuery.of(context).size.width;
            
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(user),
                        const SizedBox(height: 32),
                        _buildAvatarSection(user),
                        const SizedBox(height: 32),
                        _buildStatsRow(user),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.push('/standard-selection'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 4,
                              shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.school_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Level: $standardName',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.push('/saved-art'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8B66), // Orange
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 4,
                              shadowColor: const Color(0xFFFF8B66).withValues(alpha: 0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.palette_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Saved Art Gallery',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
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
                        _buildAchievementsGrid(user, screenWidth),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              final router = GoRouter.of(context);
                              router.go('/auth');
                              ref.read(navigationIndexProvider.notifier).setIndex(0);
                              ref.read(authControllerProvider.notifier).signOut();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Padding for bottom nav bar
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orangePrimary)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        const Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.pinkPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF79F6F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: const Color(0xFFF79F6F),
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF79F6F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: Color(0xFFF79F6F),
            ),
            onPressed: () => _showSettingsBottomSheet(user),
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
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF79F6F), Color(0xFFFF8DA1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8DA1).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipOval(
                    child: (user.avatarPath != null && File(user.avatarPath!).existsSync())
                        ? Image.file(File(user.avatarPath!), fit: BoxFit.cover)
                        : Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _showImageSourceActionSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3142),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            user.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3142),
              letterSpacing: 0.5,
            ),
          ),
        ),

      ],
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bgColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F8B9C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(UserModel user, double screenWidth) {
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

    int crossAxisCount = 3;
    if (screenWidth < 380) {
      crossAxisCount = 2;
    } else if (screenWidth > 600) {
      crossAxisCount = 4;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final bool isLocked = achievement['locked'] as bool;

        return Container(
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey[200] : achievement['color'] as Color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isLocked ? [] : [
              BoxShadow(
                color: (achievement['color'] as Color).withValues(alpha: 0.4),
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
                color: isLocked ? Colors.grey[400] : Colors.white,
                size: 36,
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    color: isLocked ? Colors.grey[500] : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final settingsState = ref.watch(settingsProvider);
          final isSoundsEnabled = settingsState.value?.magicalSoundsEnabled ?? true;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 24),
                    Text('MAGIC SETTINGS', style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
                    const SizedBox(height: 24),
                    _buildSettingsTile('Change Explorer Name', Icons.edit_rounded, AppColors.orangePrimary, onTap: () {
                      Navigator.pop(context);
                      _showEditNameDialog(user.name);
                    }),
                    const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF3F4F6)),
                    _buildSettingsTile(
                      'Magical Sounds', 
                      Icons.volume_up_rounded, 
                      AppColors.primaryPink,
                      trailing: Switch(
                        value: isSoundsEnabled,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).toggleMagicalSounds();
                        },
                        activeThumbColor: AppColors.primaryPink,
                      ),
                    ),
                    const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF3F4F6)),
                    _buildSettingsTile('Parental Control', Icons.lock_rounded, AppColors.primaryBlue, onTap: () {
                      Navigator.pop(context);
                      _showMathGate();
                    }),
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
          );
        }
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color color, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w800, fontSize: 16),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Color(0xFF7F8B9C)),
    );
  }

  void _showMathGate() {
    final random = Random();
    final num1 = random.nextInt(10) + 5; // 5 to 14
    final num2 = random.nextInt(10) + 5; // 5 to 14
    final correctAnswer = num1 * num2;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('FOR PARENTS ONLY', style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w900, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('To access Parental Controls, please solve this:', style: const TextStyle(color: Color(0xFF7F8B9C), fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text('$num1 x $num2 = ?', style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w900, fontSize: 20),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                hintText: 'Answer',
                hintStyle: const TextStyle(color: Color(0xFF7F8B9C)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF7F8B9C), fontWeight: FontWeight.w800))),
          ElevatedButton(
            onPressed: () {
              if (controller.text == correctAnswer.toString()) {
                Navigator.pop(context);
                _showParentalControls();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect answer. Please try again.', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.red),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('VERIFY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showParentalControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text('PARENTAL CONTROLS', style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.timer_rounded, color: AppColors.primaryBlue),
                  title: Text('Daily Time Limit (Coming Soon)', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w700)),
                  trailing: Switch(value: false, onChanged: (v) {}),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.block_rounded, color: Colors.red),
                  title: Text('Manage Access (Coming Soon)', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF7F8B9C)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                Text('UPDATE AVATAR', style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryBlue),
                  ),
                  title: Text('From Gallery', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w800, fontSize: 16)),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
                  ),
                  title: Text('From Camera', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w800, fontSize: 16)),
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

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.white;
    final paint2 = Paint()..color = Colors.grey[200]!;
    const squareSize = 20.0;

    for (double i = 0; i < size.width; i += squareSize) {
      for (double j = 0; j < size.height; j += squareSize) {
        if (((i / squareSize).floor() + (j / squareSize).floor()) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(i, j, squareSize, squareSize), paint1);
        } else {
          canvas.drawRect(Rect.fromLTWH(i, j, squareSize, squareSize), paint2);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
