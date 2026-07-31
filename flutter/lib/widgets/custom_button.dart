import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

/// Custom Styled Button Widget
/// DHOLERA REAL ESTATE
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? AppColors.surface : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.primary : Colors.white,
          elevation: isSecondary ? 0 : 2,
          side: isSecondary ? const BorderSide(color: AppColors.border, width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppColors.primary : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20.0),
                    const SizedBox(width: 8.0),
                  ],
                  Text(
                    text,
                    style: AppStyles.buttonText.copyWith(
                      color: isSecondary ? AppColors.primary : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
