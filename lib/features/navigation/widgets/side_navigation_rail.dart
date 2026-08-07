import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SideNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SideNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          width: 240,
          decoration: const BoxDecoration(
            color: Color(0xD90B1035), // Translucent Deep Navy Glass
            border: Border(
              right: BorderSide(
                color: AppColors.darkBorder,
                width: 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.lilacAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x80B879FF),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    "Where's My Money?",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary, // Pure White #FFFFFF
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Rail Items
              _buildRailItem(
                index: 0,
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: "Chat",
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildRailItem(
                index: 1,
                icon: Icons.donut_large_outlined,
                selectedIcon: Icons.donut_large_rounded,
                label: "Insights",
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildRailItem(
                index: 2,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: "Account & Settings",
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF3159C9), Color(0xFF6A57D8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x503159C9),
                  blurRadius: 16.0,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20.0,
                  color: isSelected
                      ? Colors.white
                      : AppColors.darkTextMuted,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
