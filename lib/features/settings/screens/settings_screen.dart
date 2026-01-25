import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/colors.dart';
import '../../../app/widgets/glass_container.dart';
import '../../../core/providers/user_preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Settings'),
              centerTitle: true,
              floating: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87),
                onPressed: () => context.pop(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Spacer for cleaner look
                  const SizedBox(height: 12),
                      // Profile Card
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        opacity: 0.6,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userPrefs.userName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userPrefs.email.isEmpty ? 'No email set' : userPrefs.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () => _showEditProfileDialog(context, ref, userPrefs),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 24),

                      // Subscription Banner
                      GestureDetector(
                        onTap: () => context.push('/subscription'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFDA085).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.black, size: 32),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upgrade to PRO',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Unlock all features',
                                      style: TextStyle(color: Colors.black87, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Upgrade',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),
                      const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),

                      // Theme Settings
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        opacity: 0.5,
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.brightness_auto,
                              title: 'Auto Theme',
                              trailing: Switch.adaptive(
                                value: userPrefs.isAutoTheme,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  ref.read(userPreferencesProvider.notifier).updateThemeMode(
                                    isDark: isDark,
                                    isAuto: value,
                                  );
                                },
                              ),
                            ),
                            if (!userPrefs.isAutoTheme) ...[
                              const Divider(color: AppColors.divider),
                              _SettingsTile(
                                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                                title: 'Dark Mode',
                                trailing: Switch.adaptive(
                                  value: userPrefs.isDarkMode,
                                  activeColor: AppColors.primary,
                                  onChanged: (value) {
                                    ref.read(userPreferencesProvider.notifier).updateThemeMode(
                                      isDark: value,
                                      isAuto: false,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                      const SizedBox(height: 24),
                      const Text('Learning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),

                      // Language Settings
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        opacity: 0.5,
                        child: _SettingsTile(
                          icon: Icons.school_rounded,
                          title: 'Language Level',
                          subtitle: userPrefs.languageLevel,
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () => _showLevelPicker(context, ref, userPrefs.languageLevel),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'CineLearn v1.0.0',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserPreferencesState prefs) {
    final nameController = TextEditingController(text: prefs.userName);
    final emailController = TextEditingController(text: prefs.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userPreferencesProvider.notifier).updateProfile(
                name: nameController.text,
                email: emailController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLevelPicker(BuildContext context, WidgetRef ref, String currentLevel) {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Language Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...levels.map((level) => ListTile(
              leading: Icon(
                level == currentLevel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: level == currentLevel ? AppColors.primary : Colors.grey,
              ),
              title: Text(level),
              onTap: () {
                ref.read(userPreferencesProvider.notifier).updateProfile(level: level);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: AppColors.textSecondary)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
