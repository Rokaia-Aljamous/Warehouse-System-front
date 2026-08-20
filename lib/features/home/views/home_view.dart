import 'package:customer_app/core/theme/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:customer_app/features/auth/views/profile_view.dart';
import 'package:customer_app/features/home/views/filter_dialog.dart';
import 'package:customer_app/features/home/views/my_cart_view.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';
import 'package:customer_app/features/home/widgets/app_header_out.dart';
import 'package:customer_app/features/orders/views/my_orders_view.dart';
import 'package:customer_app/features/return/views/myReturnsView.dart';
import 'package:flutter/material.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/WarehouseCard.dart';
import '../widgets/app_bottom_nav.dart'; // تأكدي من استيراد ملف الشريط
import '../widgets/app_drawer.dart';

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
    // ListenableBuilder يجعل هذه الصفحة (وهي الصفحة التي يفتح منها الـDrawer)
    // تعيد بناء نفسها فوراً عند تغيير الـTheme، وقراءة context.locale هنا
    // تربط نفس إعادة البناء بتغيير اللغة أيضاً — دون الحاجة للتنقل والعودة.
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        context.locale;
        return Scaffold(
          backgroundColor: AppColors.cardBg,
          // ── Drawer (new) ────────────────────────────────────────────────
          // (كانت const سابقاً) — إزالة const ضرورية حتى يُعاد بناء الـDrawer
          // فعلياً (بألوانه ونصوصه المترجمة) عند كل إعادة بناء للصفحة الناتجة عن
          // تبديل الـTheme أو اللغة، بدل أن يبقى Flutter يعيد استخدام نفس الكائن
          // الثابت (const) دون تحديث محتواه.
          drawer: const AppDrawer(),
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
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
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
      },
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
