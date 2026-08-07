import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class UserMessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;

  const UserMessageBubble({
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
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLg),
            topRight: Radius.circular(AppSpacing.radiusLg),
            bottomLeft: Radius.circular(AppSpacing.radiusLg),
            bottomRight: Radius.circular(AppSpacing.radiusSm),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.userBubbleGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(AppSpacing.radiusLg),
                  bottomRight: Radius.circular(AppSpacing.radiusSm),
                ),
                border: Border.all(
                  color: const Color(0x40FFFFFF),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40B879FF),
                    blurRadius: 20.0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: Color(0xFFFFFFFF), // Pure White #FFFFFF
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _formatTime(timestamp),
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE6EAFF),
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
