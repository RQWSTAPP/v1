import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/api.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';

/// Port of the rating sheet from the original:
/// S.overlay === 'rating', submitRating(), S.rating = {rid, toUser, stars, msg}
class RatingSheet extends StatefulWidget {
  final int requestId;
  final int toUserId;
  const RatingSheet({super.key, required this.requestId, required this.toUserId});

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _stars = 5;
  final _msgCtrl = TextEditingController();
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final s = context.read<AppState>();
    setState(() => _submitting = true);
    try {
      await ApiService.call('ratings.submit', {
        'request_id': widget.requestId,
        'to_user': widget.toUserId,
        'stars': _stars,
        'message': _msgCtrl.text.trim(),
      });
      setState(() => _done = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      s.toast(e.toString(), 'error');
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),

        if (_done) ...[
          // Success state
          const Text('🎉', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(rtl ? 'شكراً على تقييمك!' : 'Thanks for your rating!',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
        ] else ...[
          // Star icon
          const Text('⭐', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(s.t('submitRating'),
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Star selector
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
            final filled = i < _stars;
            return GestureDetector(
              onTap: () => setState(() => _stars = i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('⭐', style: TextStyle(
                  fontSize: 36,
                  color: filled ? null : Colors.grey.withValues(alpha: 0.3),
                )),
              ),
            );
          })),
          const SizedBox(height: 6),

          // Star label
          Text(_starLabel(_stars, rtl),
            style: GoogleFonts.cairo(fontSize: 13, color: RqwstColors.amber, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
          const SizedBox(height: 18),

          // Optional message
          TextField(
            controller: _msgCtrl,
            maxLines: 2,
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: rtl ? 'اكتب تجربتك (اختياري)' : 'Your experience (optional)',
              hintStyle: GoogleFonts.cairo(),
            ),
            style: GoogleFonts.cairo(),
          ),
          const SizedBox(height: 18),

          // Buttons
          Row(children: [
            Expanded(child: BrandButton(label: s.t('cancel'), ghost: true, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 10),
            Expanded(child: BrandButton(label: s.t('submitRating'), loading: _submitting, onTap: _submit)),
          ]),
        ],
      ]),
    );
  }

  String _starLabel(int stars, bool rtl) {
    if (rtl) {
      switch (stars) {
        case 1: return 'سيء جداً';
        case 2: return 'سيء';
        case 3: return 'مقبول';
        case 4: return 'كويس';
        case 5: return 'ممتاز!';
      }
    } else {
      switch (stars) {
        case 1: return 'Very poor';
        case 2: return 'Poor';
        case 3: return 'OK';
        case 4: return 'Good';
        case 5: return 'Excellent!';
      }
    }
    return '';
  }
}
