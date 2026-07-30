// lib/features/home/widgets/filter_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

void showFilterDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, color: Colors.grey[300]), // مقبض السحب
          const SizedBox(height: 20),
          const Text("Apply Filters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // هنا يمكنك استدعاء الـ CustomFields التي استخدمتها في اللوج إن
          // كمثال:
          _buildDropdown("Select Province", "Damascus"),
          _buildDropdown("Select Area", "Mezzeh - Dummar Project"),
          _buildTextField("Search for Warehouse Type", "Search here..."),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}

// يمكنك نقل هذه المساعدات لملف Widgets مشترك لتستخدمها في اللوج إن والفلترة
Widget _buildDropdown(String label, String value) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: value,
          items: [DropdownMenuItem(value: value, child: Text(value))],
          onChanged: (v) {},
        ),
      ),
    ),
    const SizedBox(height: 15),
  ],
);

Widget _buildTextField(String label, String hint) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    TextField(decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: const Icon(Icons.search))),
    const SizedBox(height: 15),
  ],
);