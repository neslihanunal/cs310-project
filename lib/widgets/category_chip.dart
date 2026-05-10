import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.label, required this.isActive, required this.onTap});

  static IconData iconForCat(String cat) {
    switch (cat) {
      case 'Academic': return Icons.menu_book_outlined;
      case 'Social':   return Icons.people_outlined;
      case 'Sports':   return Icons.sports_basketball_outlined;
      case 'Career':   return Icons.work_outline;
      case 'Arts':     return Icons.palette_outlined;
      default:         return Icons.apps_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentFaded : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.accent : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All') ...[
              Icon(iconForCat(label), size: 10, color: isActive ? AppColors.accent : AppColors.textDim),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTextStyles.body(10, color: isActive ? AppColors.accent : AppColors.textSec, weight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
