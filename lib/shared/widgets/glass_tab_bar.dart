import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

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
            child: Stack(
              children: [
                if (items.isNotEmpty)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tabWidth = constraints.maxWidth / items.length;
                        final safeIndex = selectedIndex.clamp(
                          0,
                          items.length - 1,
                        );

                        return Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              left: safeIndex * tabWidth,
                              top: 0,
                              bottom: 0,
                              width: tabWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withAlpha(30)
                                      : AppColors.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isFocused = selectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTabSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<Color?>(
                                duration: const Duration(milliseconds: 200),
                                tween: ColorTween(
                                  end: isFocused
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                builder: (context, color, child) {
                                  return Icon(
                                    item.icon,
                                    size: 22,
                                    color: color,
                                  );
                                },
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  color: isFocused
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                child: Text(item.label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
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
