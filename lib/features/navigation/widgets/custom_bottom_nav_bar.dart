import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomBottomNavBar({
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
          decoration: const BoxDecoration(
            color: Color(0xD90B1035), // Deep Translucent Navy Glass
            border: Border(
              top: BorderSide(
                color: AppColors.darkBorder,
                width: 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: "Chat",
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.donut_large_outlined,
                  selectedIcon: Icons.donut_large_rounded,
                  label: "Insights",
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      borderRadius: BorderRadius.circular(16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
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
                    color: Color(0x403159C9),
                    blurRadius: 12.0,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 20.0,
              color: isSelected ? Colors.white : AppColors.darkTextMuted,
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
