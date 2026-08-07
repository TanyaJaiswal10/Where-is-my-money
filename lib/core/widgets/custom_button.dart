import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.fullWidth = false,
    this.isLoading = false,
    this.width,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    BorderSide borderSide = BorderSide.none;
    Gradient? gradient;
    Color? bgColor;
    List<BoxShadow>? shadows;

    switch (variant) {
      case ButtonVariant.primary:
        gradient = AppColors.primaryButtonGradient;
        textColor = const Color(0xFFFFFFFF); // Pure White
        shadows = [
          BoxShadow(
            color: AppColors.lilacAccent.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ];
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.darkCard;
        textColor = AppColors.darkTextPrimary;
        borderSide = const BorderSide(
          color: AppColors.darkBorder,
          width: 1.0,
        );
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColors.primaryLight;
        borderSide = const BorderSide(color: AppColors.primaryLight, width: 1.5);
        break;
      case ButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = AppColors.darkTextSecondary;
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: textColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.0, color: textColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          );

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(25.0),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              border: Border.fromBorderSide(borderSide),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: content,
          ),
        ),
      ),
    );
  }
}
