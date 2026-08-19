import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'search_widget.dart';

class CustomAppHeader extends StatelessWidget {
  final String title;
  final String? location;
  final bool showFilter; // أضفنا هذا المتغير للتحكم في ظهور الفلترة
  final VoidCallback? onFilterTap;

  const CustomAppHeader({
    super.key, 
    required this.title, 
    this.location, 
    this.showFilter = true, // افتراضياً الفلترة ستكون موجودة
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.menu, color: Colors.white),
              Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title, 
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
            ),
          ),
          if (location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Text(location!, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // نمرر الـ showFilter للويدجت المسؤول عن البحث
          SearchAndFilterWidget(
            showFilter: showFilter, 
            onFilterTap: onFilterTap
          ),
        ],
      ),
    );
  }
}