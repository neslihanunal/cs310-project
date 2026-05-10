import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/routes.dart';
import 'splash_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _PreviewCard(top: 0.08, leftFrac: 0.05, rot: -1.5, delay: 0,   postit: AppColors.postit[0], title: 'Spring Hackathon', cat: 'Academic'),
      _PreviewCard(top: 0.06, rightFrac: 0.04, rot: 1.2,  delay: 100, postit: AppColors.postit[2], title: 'Open Mic Night',   cat: 'Arts'),
      _PreviewCard(top: 0.38, leftFrac: 0.12, rot: 0.8,  delay: 200, postit: AppColors.postit[4], title: 'Career Fair',      cat: 'Career'),
      _PreviewCard(top: 0.35, rightFrac: 0.08, rot: -0.9, delay: 300, postit: AppColors.postit[1], title: '5v5 Basketball',   cat: 'Sports'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
          child: Column(
            children: [
              // Floating preview cards
              Expanded(
                child: LayoutBuilder(builder: (ctx, constraints) {
                  return Stack(
                    children: cards.map((card) {
                      double? left = card.leftFrac != null ? constraints.maxWidth * card.leftFrac! : null;
                      double? right = card.rightFrac != null ? constraints.maxWidth * card.rightFrac! : null;
                      return Positioned(
                        top: constraints.maxHeight * card.top,
                        left: left, right: right,
                        child: _AnimatedPreviewCard(card: card),
                      );
                    }).toList(),
                  );
                }),
              ),
              // Bottom content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(size: 28),
                  const SizedBox(height: 12),
                  Text('Your campus.\nOne board.', style: AppTextStyles.heading(28).copyWith(height: 1.15)),
                  const SizedBox(height: 6),
                  Text('Every club event, in one place.', style: AppTextStyles.body(13, color: AppColors.textSec).copyWith(height: 1.6)),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text('Continue with Sabancı Email', style: AppTextStyles.body(14, color: AppColors.bg, weight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 12, color: AppColors.textDim),
                      const SizedBox(width: 5),
                      Text('Closed to @sabanciuniv.edu accounts only', style: AppTextStyles.caption(size: 11)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard {
  final double top;
  final double? leftFrac;
  final double? rightFrac;
  final double rot;
  final int delay;
  final PostItColors postit;
  final String title;
  final String cat;
  const _PreviewCard({required this.top, this.leftFrac, this.rightFrac, required this.rot, required this.delay, required this.postit, required this.title, required this.cat});
}

class _AnimatedPreviewCard extends StatefulWidget {
  final _PreviewCard card;
  const _AnimatedPreviewCard({required this.card});
  @override
  State<_AnimatedPreviewCard> createState() => _AnimatedPreviewCardState();
}

class _AnimatedPreviewCardState extends State<_AnimatedPreviewCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _offset   = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.card.delay), () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.card.postit;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Transform.rotate(
          angle: widget.card.rot * 0.0174533,
          child: Container(
            width: 130,
            decoration: BoxDecoration(
              color: c.bg,
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(top: -3, left: 0, right: 0, child: Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c.pin, shape: BoxShape.circle)))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.card.cat.toUpperCase(), style: TextStyle(fontSize: 8, color: c.pin, fontWeight: FontWeight.w600, letterSpacing: 0.08)),
                      const SizedBox(height: 6),
                      Text(widget.card.title, style: TextStyle(fontSize: 11, color: c.cardText, fontWeight: FontWeight.w500, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
