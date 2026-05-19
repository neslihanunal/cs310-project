import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _routeAfterSplash();
  }

  Future<void> _routeAfterSplash() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    while (authProvider.isLoading) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) {
        return;
      }
    }

    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      return;
    }
    if (authProvider.needsEmailVerification) {
      Navigator.pushReplacementNamed(context, AppRoutes.verifyEmail);
      return;
    }
    if (authProvider.needsProfile) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulse),
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
                    TextSpan(
                      text: 'Board',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'STUDENT EDITION',
                style: AppTextStyles.caption(size: 10).copyWith(
                  letterSpacing: 0.12,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(
                  3,
                  (index) => _DotLoader(delay: index * 200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotLoader extends StatefulWidget {
  const _DotLoader({required this.delay});

  final int delay;

  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tileSize = size / 2 - 1;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: _Tile(s: tileSize, opacity: 0.9)),
          Positioned(
            right: 0,
            top: 0,
            child: _Tile(s: tileSize, opacity: 0.55),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: _Tile(s: tileSize, opacity: 0.55),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _Tile(s: tileSize, opacity: 0.25),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.s, required this.opacity});

  final double s;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(opacity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) => _LogoWidget(size: size);
}
