import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableGlow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.enableGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0x7319235A); // rgba(25, 35, 90, 0.45)
    final border = borderColor ?? AppColors.darkBorder;

    Widget cardBody = ClipRRect(
      borderRadius: AppSpacing.borderRadiusLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: border, width: 1.0),
            boxShadow: enableGlow
                ? const [
                    BoxShadow(
                      color: Color(0x59000000), // 0 20px 60px rgba(0,0,0,0.35)
                      blurRadius: 36.0,
                      spreadRadius: -4.0,
                      offset: Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.borderRadiusLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          splashColor: AppColors.primarySubtle,
          highlightColor: Colors.transparent,
          child: cardBody,
        ),
      );
    }

    return cardBody;
  }
}
