import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.onBack, this.title, this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Icon(Icons.arrow_back, color: AppColors.textSec, size: 18),
                ),
              ),
              if (actions != null) ...[
                const Spacer(),
                ...actions!,
              ],
            ],
          ),
        ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title!, style: AppTextStyles.heading(18)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: AppTextStyles.caption()),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}