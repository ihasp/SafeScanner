import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../shared/models/scan_mode.dart';

class ScanModeSwitch extends StatelessWidget {
  final ScanMode scanMode;
  final ValueChanged<ScanMode> onModeChanged;
  final bool disabled;

  const ScanModeSwitch({
    super.key,
    required this.scanMode,
    required this.onModeChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const buttonSize = AppConstants.switchButtonSize;
    final isCrypto = scanMode == ScanMode.crypto;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.switchBackground,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        children: [
          // Animated white thumb background
          AnimatedPositioned(
            duration: const Duration(
              milliseconds: AppConstants.switchAnimationDurationMs,
            ),
            curve: Curves.easeOutCubic,
            left: isCrypto ? buttonSize : 0,
            top: 0,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Icons row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: disabled ? null : () => onModeChanged(ScanMode.qr),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: Center(
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 24,
                      color: isCrypto ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: disabled ? null : () => onModeChanged(ScanMode.crypto),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: Center(
                    child: Icon(
                      Icons.currency_bitcoin_rounded,
                      size: 24,
                      color: isCrypto ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
