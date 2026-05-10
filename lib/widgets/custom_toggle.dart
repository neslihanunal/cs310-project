import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomToggle extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final VoidCallback onTap;

  const CustomToggle({super.key, required this.value, this.activeColor = AppColors.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38, height: 21,
        decoration: BoxDecoration(
          color: value ? activeColor : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: value ? activeColor : AppColors.border),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: 2,
              left: value ? 18 : 2,
              child: Container(
                width: 15, height: 15,
                decoration: BoxDecoration(
                  color: value ? Colors.white : AppColors.textDim,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
