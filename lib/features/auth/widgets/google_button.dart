import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Colors.grey,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(
          Icons.g_mobiledata,
          size: 32,
        ),
        label: isLoading
            ? const CircularProgressIndicator()
            : const Text(
                "Continue with Google",
              ),
      ),
    );
  }
}