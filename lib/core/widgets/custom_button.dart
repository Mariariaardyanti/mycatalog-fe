import 'package:flutter/material.dart';
import 'package:shopping_app/core/constants/api_colors.dart';

enum ButtonVariant { primary, outlined, text }
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 52,
  });

  // ── Loading indicator ─────────────────────────────────────────
  Widget _loadingSpinner({required Color color}) => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: color,
          backgroundColor: color.withOpacity(0.2),
        ),
      );

  // ── Button content ────────────────────────────────────────────
  Widget _content({required Color spinnerColor}) {
    if (isLoading) return _loadingSpinner(color: spinnerColor);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        // ── Primary ────────────────────────────────────────────────
        ButtonVariant.primary => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnGold,
              disabledBackgroundColor: AppColors.primaryLight,
              disabledForegroundColor: AppColors.textSecondary,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((s) => s
                      .contains(WidgetState.pressed)
                  ? AppColors.overlayPressed
                  : null),
            ),
            child: _content(spinnerColor: AppColors.textOnGold),
          ),

        // ── Outlined ───────────────────────────────────────────────
        ButtonVariant.outlined => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.textSecondary,
              backgroundColor: AppColors.primaryFill,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((s) => s
                      .contains(WidgetState.pressed)
                  ? AppColors.primary.withOpacity(0.08)
                  : null),
            ),
            child: _content(spinnerColor: AppColors.primary),
          ),

        // ── Text ───────────────────────────────────────────────────
        ButtonVariant.text => TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            child: _content(spinnerColor: AppColors.primary),
          ),
      },
    );
  }
}

// ── Contoh penggunaan ──────────────────────────────────────────────
// CustomButton(label: 'Masuk', onPressed: _login, isLoading: _loading)
// CustomButton(label: 'Daftar', variant: ButtonVariant.outlined, onPressed: () {})
// CustomButton(label: 'Lupa Password?', variant: ButtonVariant.text, onPressed: () {})
// CustomButton(label: 'Simpan', icon: const Icon(Icons.save_rounded, size: 18), onPressed: () {})