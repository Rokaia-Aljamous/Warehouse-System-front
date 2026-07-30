import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'package:customer_app/features/orders/widgets/app_header_in.dart';

/// "Change Password" screen — accessible from the Drawer.
///
/// Uses the shared [AppHeader] (the project's fixed header) and the Auth
/// [AppTextField] widget for all three fields, exactly like Profile/Auth.
///
/// On "Confirm":
///   - Saves the new password to SharedPreferences (local only, no API).
///   - Pops back to the previous screen.
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _oldPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    // Local-only validation + save (no backend).
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_password', _newPasswordCtrl.text);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          // ── Shared fixed header ─────────────────────────────────────
          AppHeader(
            title: 'Change Password',
            showBack: true,
            showNotification: true,
            onNotificationTap: () {},
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
            extraBottomPadding: 25,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.xl),

                  // ── Old Password ────────────────────────────────────
                  AppTextField(
                    label: 'OLD PASSWORD',
                    hint: 'old password',
                    icon: Icons.lock_outline,
                    controller: _oldPasswordCtrl,
                    obscureText: !_showOld,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showOld
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showOld = !_showOld),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── New Password ────────────────────────────────────
                  AppTextField(
                    label: 'NEW PASSWORD',
                    hint: 'new password',
                    icon: Icons.lock_outline,
                    controller: _newPasswordCtrl,
                    obscureText: !_showNew,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showNew = !_showNew),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm Password ────────────────────────────────
                  AppTextField(
                    label: 'CONFIRM PASSWORD',
                    hint: 'confirm password',
                    icon: Icons.lock_outline,
                    controller: _confirmPasswordCtrl,
                    obscureText: !_showConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // ── Confirm button (Auth AppButton) ─────────────────
                  AppButton(
                    label: 'Confirm',
                    onPressed: _confirm,
                    color: AppColors.primary,
                    textColor: Colors.white,
                    borderColor: AppColors.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
