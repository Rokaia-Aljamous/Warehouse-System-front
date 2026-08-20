import 'package:customer_app/features/auth/views/profile_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../controllers/returns_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/return_model.dart';

import '../../home/views/home_view.dart';
import '../../home/widgets/app_bottom_nav.dart';
import '../../orders/views/my_orders_view.dart';
import '../../orders/widgets/app_header_in.dart';

import 'pending_return_view.dart';
import 'inprogress_return_view.dart';
import 'archived_return_view.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';

class MyReturnsView extends StatefulWidget {
  const MyReturnsView({super.key});

  @override
  State<MyReturnsView> createState() => _MyReturnsViewState();
}

class _MyReturnsViewState extends State<MyReturnsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _controller = ReturnsController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller.loadReturns();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,

      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersView()),
              );
              break;

            case 2:
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

      body: RefreshIndicator(
        onRefresh: _controller.loadReturns,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'returns.my_returns'.tr(),
                showBack: true,
                showNotification: true,
                onNotificationTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsView()),
                ),
                extraBottomPadding: 25,
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _ReturnsTabBarDelegate(
                TabBar(
                  controller: _tabController,

                  indicatorColor: AppColors.textOnPrimary,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,

                  labelColor: AppColors.textOnPrimary,
                  unselectedLabelColor: AppColors.textOnPrimary.withOpacity(
                    0.6,
                  ),

                  dividerColor: Colors.transparent,

                  labelStyle: AppTextStyles.fieldLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),

                  unselectedLabelStyle: AppTextStyles.fieldLabel.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),

                  tabs: [
                    Tab(text: 'returns.pending'.tr()),
                    Tab(text: 'returns.in_progress'.tr()),
                    Tab(text: 'returns.archived'.tr()),
                  ],
                ),
              ),
            ),
          ],

          body: _controller.isLoading && _controller.returns.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _controller.errorMessage != null && _controller.returns.isEmpty
              ? Center(
                  child: Text(
                    _controller.errorMessage!,
                    style: AppTextStyles.bodySmall,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    PendingReturnsScreen(
                      returns: _controller.byCategory(ReturnUiCategory.pending),
                      onReturnUpdated: _controller.loadReturns,
                    ),
                    InProgressReturnsScreen(
                      returns: _controller.byCategory(
                        ReturnUiCategory.inProgress,
                      ),
                    ),
                    ArchivedReturnsScreen(
                      returns: _controller.byCategory(
                        ReturnUiCategory.archived,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ReturnsTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _ReturnsTabBarDelegate(this.tabBar);

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

  @override
  double get maxExtent => tabBar.preferredSize.height + 10;

  @override
  double get minExtent => tabBar.preferredSize.height + 10;

  @override
  bool shouldRebuild(covariant _ReturnsTabBarDelegate oldDelegate) {
    return false;
  }
}
