import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class GlassTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<TabBarItem> items;

  const GlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomInset + 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withAlpha(160)
                  : Colors.white.withAlpha(210),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(25)
                    : Colors.black.withAlpha(20),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isFocused = selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? (isDark
                                  ? Colors.white.withAlpha(30)
                                  : AppColors.primary.withAlpha(30))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: isFocused
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: isFocused
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class TabBarItem {
  final IconData icon;
  final String label;

  const TabBarItem({required this.icon, required this.label});
}
