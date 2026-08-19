// lib/features/home/views/filter_dialog.dart
import 'package:easy_localization/easy_localization.dart';
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
            Text(
              'home.filter_title'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Governorate (حقيقي: من المستودعات الموجودة فعلياً) ─────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'home.select_province'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                  hint: Text('home.all_governorates'.tr()),
                  value: selectedGovernorate,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('home.all_governorates'.tr()),
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
                'home.search_type'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                hintText: 'home.search_type_hint'.tr(),
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
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'common.clear'.tr(),
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
                      child: Text(
                        'home.apply_filters'.tr(),
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
