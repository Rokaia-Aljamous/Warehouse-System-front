import 'package:customer_app/features/auth/views/change_password_view.dart';
import 'package:customer_app/features/auth/views/profile_view.dart';
import 'package:customer_app/features/home/views/my_cart_view.dart';
import 'package:customer_app/features/home/views/notifications_view.dart';
import 'package:customer_app/features/home/widgets/app_header_out.dart';
import 'package:customer_app/features/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import '../../../controllers/warehouse_details_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// "Warehouse Details" screen — products grid for a specific warehouse.
///
/// UI elements:
///   - Shared `CustomAppHeader` (left menu icon opens Drawer, right bell
///     icon navigates to NotificationsView).
///   - Drawer (left edge) — flat list: Profile, Change Password, Wallet,
///     Light, English, then divider, then Logout.
///   - Floating cart button (bottom-right) → [MyCartView].
class WarehouseDetailsView extends StatefulWidget {
  final int warehouseId;
  final String title;
  final String location;

  const WarehouseDetailsView({
    super.key,
    required this.warehouseId,
    required this.title,
    required this.location,
  });

  @override
  State<WarehouseDetailsView> createState() => _WarehouseDetailsViewState();
}

class _WarehouseDetailsViewState extends State<WarehouseDetailsView> {
  late final WarehouseDetailsController _controller;
  int? _addingProductId;

  @override
  void initState() {
    super.initState();
    _controller = WarehouseDetailsController(warehouseId: widget.warehouseId);
    _controller.loadAll();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onAddToCart(int productId) async {
    setState(() => _addingProductId = productId);
    final ok = await _controller.addToCart(productId);
    if (!mounted) return;
    setState(() => _addingProductId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'تمت الإضافة للسلة' : (_controller.cartError ?? 'تعذّرت الإضافة'),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF8),
      drawer: const _AppDrawer(),
      // Floating cart button — bottom-right (matches project's navy/orange palette)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyCartView(warehouseId: widget.warehouseId),
          ),
        ),
        backgroundColor: AppColors.iconColor,
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: CustomScrollView(
        slivers: [
          // Header — the menu icon (left) opens the drawer, the bell (right)
          // navigates to notifications. We wrap the shared CustomAppHeader
          // and overlay invisible tap targets to intercept the icon taps
          // without modifying the shared widget's API.
          SliverToBoxAdapter(
            child: _WarehouseHeader(
              title: widget.title,
              location: widget.location,
              showFilter: false,
            ),
          ),

          // حالة التحميل
          if (_controller.isLoadingProducts)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          // حالة الخطأ
          else if (_controller.productsError != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.productsError!,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _controller.loadProducts,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          // حالة القائمة فاضية
          else if (_controller.products.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('لا توجد منتجات بهذا المستودع حالياً')),
            )
          // القائمة الحقيقية
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = _controller.products[index];
                    return ProductCard(
                      name: p.name,
                      price: '\$ ${p.sellingPrice.toStringAsFixed(2)}',
                      image: "assets/image/Glazed Donuts.png",
                      networkImage: p.mainImage,
                      isAdding: _addingProductId == p.id,
                      onAddToCart: () => _onAddToCart(p.id),
                    );
                  },
                  childCount: _controller.products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Header wrapper that opens the drawer (left) and notifications (right).
///
/// We can't modify the shared `CustomAppHeader` widget, so we wrap it in
/// a [Builder] that gives us a drawer-capable context, and use a small
/// overlay [Stack] to intercept the icon tap targets without changing
/// the underlying widget's API.
class _WarehouseHeader extends StatelessWidget {
  final String title;
  final String? location;
  final bool showFilter;

  const _WarehouseHeader({
    required this.title,
    this.location,
    this.showFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerCtx) => Stack(
        children: [
          CustomAppHeader(
            title: title,
            location: location,
            showFilter: showFilter,
          ),
          // Invisible tap targets over the menu (left) and bell (right) icons.
          // The header has 24px horizontal padding and the icons sit ~60px
          // from the top (top padding is 60px in CustomAppHeader).
          Positioned(
            top: 60,
            left: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Scaffold.of(innerCtx).openDrawer(),
              child: const SizedBox(width: 32, height: 32),
            ),
          ),
          Positioned(
            top: 60,
            right: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.push(
                innerCtx,
                MaterialPageRoute(
                  builder: (_) => const NotificationsView(),
                ),
              ),
              child: const SizedBox(width: 32, height: 32),
            ),
          ),
        ],
      ),
    );
  }
}

/// Application Drawer — flat list matching Figma "Aside - Navigation Drawer".
///
/// Layout (top → bottom):
///   Profile
///   Change Password
///   Wallet
///   Light
///   English
///   ─────── (divider)
///   Logout  (red)
///
/// Background: cream `AppColors.cardBg`. Items use the project's
/// `AppColors.textPrimary` for label color and `AppColors.iconColor`
/// for icons — matching the rest of the app's palette.
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

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
              label: 'Profile',
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordView()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.light_mode_outlined,
              label: 'Light',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.language_outlined,
              label: 'English',
              onTap: () => Navigator.pop(context),
            ),
            const Divider(height: 32, indent: 24, endIndent: 24),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout (demo only).'),
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
    final Color color =
        isDestructive ? const Color(0xFFDC2626) : AppColors.textPrimary;
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
