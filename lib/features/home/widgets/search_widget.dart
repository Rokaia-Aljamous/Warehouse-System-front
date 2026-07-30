import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SearchAndFilterWidget extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchAndFilterWidget({
    super.key,
    this.onFilterTap,
    this.showFilter = true,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: showFilter 
              ? IconButton(icon: const Icon(Icons.tune), onPressed: onFilterTap) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}