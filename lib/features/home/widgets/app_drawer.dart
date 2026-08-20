import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/views/change_password_view.dart';
import '../../auth/views/profile_view.dart';

/// دروار واحد مشترك يُستخدم بكل شاشات التطبيق يلي بدها تظهره (بدل ما يكون
/// في نسخة منفصلة مكررة بكل شاشة). أي تعديل مستقبلي على محتوى الدروار
/// (إضافة/حذف بند، تغيير لون...الخ) بيصير هون بمكان واحد بس وينعكس تلقائياً
/// بكل مكان مستخدم فيه.
///
/// البنود: Profile, Change Password, Light/Dark, Language, ثم Logout.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'drawer.profile'.tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.lock_outline,
              label: 'drawer.change_password'.tr(),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordView()),
                );
              },
            ),
            Builder(
              builder: (drawerContext) => ListenableBuilder(
                listenable: ThemeController.instance,
                builder: (context, _) {
                  final isDark = ThemeController.instance.isDark;
                  return _DrawerItem(
                    icon: isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    // التسمية نفسها تعكس الوضع الحالي (فاتح/Light في Light
                    // Mode، غامق/Dark في Dark Mode) وليس فقط الأيقونة.
                    label: isDark ? 'theme.dark'.tr() : 'theme.light'.tr(),
                    onTap: () {
                      Navigator.pop(drawerContext);
                      ThemeController.instance.toggle();
                    },
                  );
                },
              ),
            ),
            _DrawerItem(
              icon: Icons.language_outlined,
              label: 'drawer.language'.tr(),
              onTap: () async {
                final newLocale = context.locale.languageCode == 'en'
                    ? const Locale('ar')
                    : const Locale('en');
                await context.setLocale(newLocale);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const Divider(height: 32, indent: 24, endIndent: 24),
            _DrawerItem(
              icon: Icons.logout,
              label: 'drawer.logout'.tr(),
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('drawer.logout_demo'.tr()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// بند واحد بالدروار — أيقونة + نص، مع خيار الستايل الأحمر (Logout).
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive
        ? const Color(0xFFDC2626)
        : AppColors.textOnCard;
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        label,
        style: AppTextStyles.fieldLabel.copyWith(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
