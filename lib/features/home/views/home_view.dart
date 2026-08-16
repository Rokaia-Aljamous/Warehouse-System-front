import 'package:customer_app/features/auth/views/change_password_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:customer_app/features/auth/views/profile_view.dart';
import 'package:customer_app/features/home/views/filter_dialog.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';
import 'package:customer_app/features/home/widgets/app_header_out.dart';
import 'package:customer_app/features/orders/views/my_orders_view.dart';
import 'package:customer_app/features/return/views/myReturnsView.dart';
import 'package:flutter/material.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/views/login_view.dart';
import '../../../core/storage/token_storage.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/WarehouseCard.dart';
import '../widgets/app_bottom_nav.dart'; // تأكدي من استيراد ملف الشريط

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0; // التتبع للصفحة الحالية
  final _homeController = HomeController();

  @override
  void initState() {
    super.initState();
    _homeController.loadWarehouses();
    _homeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      // ── Drawer (new) ────────────────────────────────────────────────
      drawer: const _HomeDrawer(),
      // لا يوجد زر سلة عام هون — السلة أصبحت خاصة بكل مستودع، وبتوصلها
      // من جوا شاشة "Warehouse Details" لكل مستودع لحاله.
      // دمج الشريط هنا
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex)
            return; // لا تفعل شيئاً إذا كان المستخدم في نفس الصفحة

          setState(() => _currentIndex = index);

          // ربط التنقل:
          switch (index) {
            case 0:
              // انتقل للـ Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
              break;
            case 1:
              // انتقل للطلبات
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersView()),
              );
              break;
            case 2:
              // انتقل للمرتجعات
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyReturnsView()),
              );
              break;
            case 3:
              // انتقل للبروفايل
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
              break;
          }
        },
      ),
      body: Column(
        children: [
          // ── Header wrapper — intercepts the menu (left) and bell (right)
          // icon taps so the menu opens the Drawer and the bell navigates
          // to NotificationsView. The shared CustomAppHeader widget itself
          // is left untouched.
          _HomeHeader(
            title: 'app_name'.tr(),
            showFilter: true,
            onFilterTap: () async {
              final result = await showFilterDialog(
                context,
                governorates: _homeController.availableGovernorates,
                currentGovernorate: _homeController.governorateFilter,
                currentType: _homeController.typeFilter,
              );
              if (result != null) {
                _homeController.applyFilters(
                  governorate: result['governorate'],
                  type: result['type'],
                );
              }
            },
            onSearchChanged: _homeController.search,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _homeController.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _homeController.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _homeController.errorMessage!,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        OutlinedButton(
                          onPressed: _homeController.loadWarehouses,
                          child: Text('common.try_again'.tr()),
                        ),
                      ],
                    ),
                  )
                : _homeController.warehouses.isEmpty
                ? Center(
                    child: Text(
                      'common.no_results'.tr(),
                      style: AppTextStyles.bodySmall,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    itemCount: _homeController.warehouses.length,
                    itemBuilder: (_, index) {
                      final w = _homeController.warehouses[index];
                      return WarehouseCard(
                        warehouseId: w.id,
                        title: w.warehouseName,
                        location: '${w.governorate}, ${w.location}',
                        warehouseType: w.type,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Header wrapper that opens the drawer (left) and notifications (right),
/// reusing the shared [CustomAppHeader] widget without modifying it.
class _HomeHeader extends StatelessWidget {
  final String title;
  final bool showFilter;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;

  const _HomeHeader({
    required this.title,
    this.showFilter = true,
    this.onFilterTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerCtx) => Stack(
        children: [
          CustomAppHeader(
            title: title,
            showFilter: showFilter,
            onFilterTap: onFilterTap,
            onSearchChanged: onSearchChanged,
          ),
          // Invisible tap target over the menu icon (left).
          Positioned(
            top: 60,
            left: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Scaffold.of(innerCtx).openDrawer(),
              child: const SizedBox(width: 32, height: 32),
            ),
          ),
          // Invisible tap target over the bell icon (right).
          Positioned(
            top: 60,
            right: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.push(
                innerCtx,
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              ),
              child: const SizedBox(width: 32, height: 32),
            ),
          ),
        ],
      ),
    );
  }
}

/// Home Drawer — same flat list style as WarehouseDetailsView's drawer.
/// Items: Profile, Change Password, Wallet, Light, English, divider, Logout.
class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

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
            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'drawer.wallet'.tr(),
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.light_mode_outlined,
              label: 'drawer.theme'.tr(),
              onTap: () => Navigator.pop(context),
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
              onTap: () async {
                Navigator.pop(context);
                final token = await TokenStorage.getToken();
                try {
                  if (token != null) {
                    await AuthRepository().logout(token: token);
                  }
                } catch (_) {
                  // Local logout must still complete if the token expired or
                  // the server is temporarily unreachable.
                } finally {
                  await TokenStorage.clearToken();
                }
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Single drawer menu item — icon + label, with optional destructive style.
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
        : AppColors.textPrimary;
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
