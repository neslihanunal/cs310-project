import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';


class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _type  = 'Bug Report';
  int    _rating = 0;
  final  _textCtrl = TextEditingController();
  String _textErr  = '';

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (_rating == 0) {
      setState(() => _textErr = 'Please select a rating.');
      return;
    }
    if (_textCtrl.text.trim().length < 10) {
      setState(() => _textErr = 'Please write at least 10 characters of feedback.');
      return;
    }
    setState(() => _textErr = '');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.successFaded, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.success.withOpacity(0.3))),
            child: Icon(Icons.check, color: AppColors.success, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Thank you!', style: AppTextStyles.heading(20)),
          const SizedBox(height: 8),
          Text('Your feedback has been submitted. Our team will review it shortly.', textAlign: TextAlign.center, style: AppTextStyles.body(13, color: AppColors.textSec).copyWith(height: 1.6)),
        ]),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface, foregroundColor: AppColors.text,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: Text('Back to Settings', style: AppTextStyles.body(13, weight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBack: () => Navigator.pop(context), title: 'Send Feedback', subtitle: 'Help us improve CampusBoard'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Type selector
                  Text('TYPE', style: AppTextStyles.label()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: ['Bug Report', 'Feature Request', 'General', 'Club Request'].map((t) {
                      final act = _type == t;
                      return GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: act ? AppColors.accentFaded : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: act ? AppColors.accent.withOpacity(0.5) : AppColors.border),
                          ),
                          child: Text(t, style: AppTextStyles.body(12, color: act ? AppColors.accent : AppColors.textSec, weight: act ? FontWeight.w500 : FontWeight.w400)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Star rating
                  Text('RATING', style: AppTextStyles.label()),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < _rating;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.warning, size: 28),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Message field (form validation requirement: at least 2 input fields validated)
                  CustomTextField(
                    label: 'Your Feedback',
                    placeholder: 'Describe your bug, idea, or question…',
                    controller: _textCtrl,
                    maxLines: 5,
                    onChanged: (_) => setState(() => _textErr = ''),
                    errorText: _textErr.isEmpty ? null : _textErr,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent, foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text('Submit Feedback', style: AppTextStyles.body(13, color: AppColors.bg, weight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
