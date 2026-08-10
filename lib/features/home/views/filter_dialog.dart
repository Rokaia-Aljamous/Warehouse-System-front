// lib/features/home/views/filter_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// نافذة فلترة حقيقية: محافظة (من قائمة المحافظات الموجودة فعلياً بالمستودعات)
/// + نوع المستودع (بحث نصي جزئي). بترجع Map فيها القيم المختارة عند الضغط
/// على "Apply Filters"، أو null لو المستخدم سكّر النافذة بدون تطبيق.
Future<Map<String, String?>?> showFilterDialog(
  BuildContext context, {
  required List<String> governorates,
  String? currentGovernorate,
  String? currentType,
}) {
  String? selectedGovernorate = currentGovernorate;
  final typeController = TextEditingController(text: currentType ?? '');

  return showModalBottomSheet<Map<String, String?>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              "Apply Filters",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Governorate (حقيقي: من المستودعات الموجودة فعلياً) ─────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Province",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('All Governorates'),
                  value: selectedGovernorate,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Governorates'),
                    ),
                    ...governorates.map(
                      (g) =>
                          DropdownMenuItem<String?>(value: g, child: Text(g)),
                    ),
                  ],
                  onChanged: (v) =>
                      setModalState(() => selectedGovernorate = v),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ── Warehouse type (بحث نصي جزئي حقيقي) ─────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Search for Warehouse Type",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                hintText: 'e.g. Cold Storage, General...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'governorate': null,
                          'type': null,
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'governorate': selectedGovernorate,
                          'type': typeController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
