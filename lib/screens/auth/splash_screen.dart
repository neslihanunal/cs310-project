import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: FadeTransition(
          opacity: Tween(begin: 0.6, end: 1.0).animate(_pulse),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LogoWidget(size: 40),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.heading(26),
                  children: [
                    const TextSpan(text: 'Campus'),
                    TextSpan(text: 'Board', style: TextStyle(color: AppColors.accent)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text('STUDENT EDITION', style: AppTextStyles.caption(size: 10).copyWith(letterSpacing: 0.12)),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => _DotLoader(delay: i * 200)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotLoader extends StatefulWidget {
  final int delay;
  const _DotLoader({required this.delay});
  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: FadeTransition(
      opacity: _anim,
      child: Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
    ),
  );
}

// ─── Reusable logo widget used across screens ───────────────────────────────
class _LogoWidget extends StatelessWidget {
  final double size;
  const _LogoWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    final s = size / 2 - 1;
    return SizedBox(
      width: size, height: size,
      child: Stack(
        children: [
          Positioned(left: 0,   top: 0,   child: _Tile(s: s, opacity: 0.9)),
          Positioned(right: 0,  top: 0,   child: _Tile(s: s, opacity: 0.55)),
          Positioned(left: 0,   bottom: 0, child: _Tile(s: s, opacity: 0.55)),
          Positioned(right: 0,  bottom: 0, child: _Tile(s: s, opacity: 0.25)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final double s;
  final double opacity;
  const _Tile({required this.s, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: s, height: s,
    decoration: BoxDecoration(
      color: AppColors.accent.withOpacity(opacity),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

// Export logo for use across other screens
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 28});
  @override
  Widget build(BuildContext context) => _LogoWidget(size: size);
}
