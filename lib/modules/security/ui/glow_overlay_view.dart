import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';

class GlowOverlayView extends StatefulWidget {
  final bool isSafe;
  final bool visible;
  final int durationMs;

  const GlowOverlayView({
    super.key,
    required this.isSafe,
    required this.visible,
    this.durationMs = AppConstants.glowDurationMs,
  });

  @override
  State<GlowOverlayView> createState() => _GlowOverlayViewState();
}

class _GlowOverlayViewState extends State<GlowOverlayView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.visible) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant GlowOverlayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward(from: 0.0);
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final glowColor = widget.isSafe
        ? AppColors.glowSafe
        : AppColors.glowMalicious;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(color: glowColor),
          );
        },
      ),
    );
  }
}
