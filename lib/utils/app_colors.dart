import 'package:flutter/material.dart';

class AppColors {
  static const Color bg          = Color(0xFF0B0C0F);
  static const Color surface     = Color(0xFF111318);
  static const Color surfaceAlt  = Color(0xFF161820);
  static const Color surfaceHigh = Color(0xFF1D1F28);
  static const Color accent      = Color(0xFF7B9FD4);
  static const Color accentDim   = Color(0xFF5C81BA);
  static       Color accentFaded = const Color(0xFF7B9FD4).withOpacity(0.10);
  static const Color text        = Color(0xFFE8E6E2);
  static const Color textSec     = Color(0xFF8A8C96);
  static const Color textDim     = Color(0xFF52545E);
  static const Color textMuted   = Color(0xFF34353C);
  static const Color border      = Color(0xFF1F2130);
  static const Color borderLight = Color(0xFF191B28);
  static const Color success     = Color(0xFF72A98F);
  static       Color successFaded = const Color(0xFF72A98F).withOpacity(0.12);
  static const Color danger      = Color(0xFFC27B72);
  static       Color dangerFaded  = const Color(0xFFC27B72).withOpacity(0.10);
  static const Color warning     = Color(0xFFC2A256);
  static       Color warningFaded = const Color(0xFFC2A256).withOpacity(0.10);

  // Post-it card color palettes
  static const List<PostItColors> postit = [
    PostItColors(bg: Color(0xFF171A22), border: Color(0xFF252A38), pin: Color(0xFF7B9FD4), cardText: Color(0xFFC8D4E8)),
    PostItColors(bg: Color(0xFF1A1720), border: Color(0xFF28243A), pin: Color(0xFF9B84C0), cardText: Color(0xFFCFC0E0)),
    PostItColors(bg: Color(0xFF1A1D1A), border: Color(0xFF262A26), pin: Color(0xFF72A98F), cardText: Color(0xFFBCDAcB)),
    PostItColors(bg: Color(0xFF1F1B18), border: Color(0xFF302820), pin: Color(0xFFC2956A), cardText: Color(0xFFDEC8A8)),
    PostItColors(bg: Color(0xFF1C1A20), border: Color(0xFF2C2838), pin: Color(0xFFA884B4), cardText: Color(0xFFCDB8D8)),
    PostItColors(bg: Color(0xFF181C1E), border: Color(0xFF242C30), pin: Color(0xFF6A9BB5), cardText: Color(0xFFB4CCE0)),
  ];
}

class PostItColors {
  final Color bg;
  final Color border;
  final Color pin;
  final Color cardText;
  const PostItColors({
    required this.bg,
    required this.border,
    required this.pin,
    required this.cardText,
  });
}
