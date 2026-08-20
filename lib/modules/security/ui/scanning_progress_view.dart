import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ScanningProgressView extends StatelessWidget {
  final String text;

  const ScanningProgressView({super.key, this.text = 'Scanning the link...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 40),
          Transform.scale(
            scale: 1.5,
            child: const CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
