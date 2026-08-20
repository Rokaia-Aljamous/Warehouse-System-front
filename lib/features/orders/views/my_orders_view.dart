import 'package:easy_localization/easy_localization.dart';
import 'package:customer_app/features/auth/views/profile_view.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';
import 'package:flutter/material.dart';
import '../../../controllers/orders_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../home/widgets/app_bottom_nav.dart';
import 'pending_orders_view.dart';
import 'received_orders_view.dart';
import 'cancelled_orders_view.dart';
import 'package:customer_app/features/home/views/home_view.dart';
import 'package:customer_app/features/return/views/myReturnsView.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ordersController = OrdersController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ordersController.loadOrders();
    _ordersController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
              break;

            case 1:
              break;

            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyReturnsView()),
              );
              break;

            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
              break;
          }
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── الهيدر ────────────────────────────────────────
          SliverToBoxAdapter(
            child: AppHeader(
              title: 'orders.my_orders'.tr(),
              showBack: true,
              showNotification: true,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              ),
              extraBottomPadding: 25,
            ),
          ),

          // ── التابات ثابتة ─────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textOnPrimary,
                indicatorWeight: 2,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.6),
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: AppTextStyles.fieldLabel.copyWith(
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: 'status.pending'.tr()),
                  Tab(text: 'status.received'.tr()),
                  Tab(text: 'status.cancelled'.tr()),
                ],
              ),
            ),
          ),
        ],

        // ── محتوى التابات ──────────────────────────────────
        body: _ordersController.isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _ordersController.errorMessage != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _ordersController.errorMessage!,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _ordersController.loadOrders(),
                      child: Text('common.try_again'.tr()),
                    ),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  PendingOrdersScreen(
                    orders: _ordersController.orders
                        .where(
                          (o) =>
                              o.status == 'pending' || o.status == 'approved',
                        )
                        .toList(),
                  ),
                  ReceivedOrdersScreen(
                    orders: _ordersController.orders
                        .where((o) => o.status == 'delivered')
                        .toList(),
                  ),
                  CancelledOrdersScreen(
                    orders: _ordersController.orders
                        .where(
                          (o) =>
                              o.status == 'cancelled' || o.status == 'rejected',
                        )
                        .toList(),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      child: Align(alignment: Alignment.topCenter, child: tabBar),
    );
  }

  // ← زيد 10 عشان الانحناء يظهر تحت التابات
  @override
  double get maxExtent => tabBar.preferredSize.height + 10;

  @override
  double get minExtent => tabBar.preferredSize.height + 10;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
