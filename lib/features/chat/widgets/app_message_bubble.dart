import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AppMessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;

  const AppMessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLg),
            topRight: Radius.circular(AppSpacing.radiusLg),
            bottomLeft: Radius.circular(AppSpacing.radiusSm),
            bottomRight: Radius.circular(AppSpacing.radiusLg),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: const Color(0xBF10164A), // Deep Navy Translucent Glass
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(AppSpacing.radiusSm),
                  bottomRight: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border.all(
                  color: AppColors.darkBorder,
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 20.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextPrimary, // Crisp #FFFFFF
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _formatTime(timestamp),
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkTextSecondary, // Crisp #D9DEFF
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
