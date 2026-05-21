import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/api.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'chat_screen.dart';
import 'rating_sheet.dart';

class RequestDetailSheet extends StatefulWidget {
  final Request req;
  const RequestDetailSheet({super.key, required this.req});

  @override
  State<RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends State<RequestDetailSheet> {
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;
  late Request _req;

  @override
  void initState() {
    super.initState();
    _req = widget.req;
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _loading = true);
    try {
      final j = await ApiService.call('offers.for_request', {'request_id': _req.id});
      if (mounted) setState(() => _offers = List<Map<String, dynamic>>.from(j['data']?['offers'] ?? []));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  Future<void> _acceptOffer(int offerId) async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'تقبل العرض ده؟' : 'Accept this offer?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Text(rtl ? 'هيفتح شات بينك وبين المزود' : 'A chat will open with the provider', style: GoogleFonts.cairo()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(s.t('accept'), style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      final j = await ApiService.call('offers.accept', {'offer_id': offerId});
      s.toast(rtl ? 'تم القبول 🤝' : 'Accepted 🤝', 'success');
      await s.loadMyReqs();
      final tid = j['data']?['thread_id'] as int?;
      if (!mounted) return;
      Navigator.pop(context); // close sheet
      if (tid != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: s,
              child: ChatDetailScreen(threadId: tid, requestId: _req.id, peerName: ''),
            ),
          ));
        }
      }
    } catch (e) {
      s.toast(e.toString(), 'error');
    }
  }

  Future<void> _rejectOffer(int offerId) async {
    try {
      await ApiService.call('offers.reject', {'offer_id': offerId});
      await _loadOffers();
      if (mounted) context.read<AppState>().toast(context.read<AppState>().isRTL ? 'تم الرفض' : 'Rejected', 'info');
    } catch (_) {}
  }

  Future<void> _cancelReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    String reason = '';
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'تلغي الطلب؟' : 'Cancel Request?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(rtl ? 'ممكن تسيب سبب بسيط (اختياري)' : 'You can leave a reason (optional)', style: GoogleFonts.cairo(fontSize: 13)),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(hintText: rtl ? 'سبب الإلغاء…' : 'Reason (optional)…'),
          style: GoogleFonts.cairo(),
          onChanged: (v) => reason = v,
          maxLines: 2,
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(rtl ? 'إلغاء الطلب' : 'Cancel Request',
            style: GoogleFonts.cairo(color: RqwstColors.rose, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      await ApiService.call('requests.cancel', {'request_id': _req.id, 'reason': reason});
      await s.loadMyReqs();
      if (!mounted) return;
      Navigator.pop(context);
      s.toast(s.t('reqCancelled'), 'warning');
    } catch (_) {}
  }

  Future<void> _completeReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'الطلب خلص؟' : 'Request complete?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Text(rtl ? 'هتأكد إن كل حاجة تمت' : 'Confirm everything went well', style: GoogleFonts.cairo()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(rtl ? 'أيوه، خلص' : 'Yes, done',
            style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      final myId = s.user?.id ?? 0;
      final j = await ApiService.call('requests.complete', {'request_id': _req.id});
      await s.loadMyReqs();
      if (!mounted) return;
      Navigator.pop(context);
      s.toast(s.t('reqCompleted'), 'success');
      final srvReq = j['data']?['req'] ?? {};
      final providerId = srvReq['provider_id'] as int?;
      final requesterId = srvReq['user_id'] as int?;
      if (mounted && myId == requesterId && providerId != null && providerId != myId) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ChangeNotifierProvider.value(
            value: s,
            child: RatingSheet(requestId: _req.id, toUserId: providerId),
          ),
        );
      }
    } catch (_) {}
  }

  bool get _canChat => (_req.state == 'accepted' || _req.state == 'in_progress') && _req.threadId != null;
  bool get _canComplete => _req.state == 'accepted' || _req.state == 'in_progress';
  bool get _canCancel => _req.state == 'bidding' || _req.state == 'open' || _req.state == 'posted';
  bool get _isMine => true; // sheet is only opened for own requests

  String _statusLabel(AppState s) {
    switch (_req.state) {
      case 'bidding': return s.t('bidding');
      case 'accepted': case 'in_progress': return s.t('accepted');
      case 'completed': case 'done': return s.t('completed');
      case 'cancelled': case 'canceled': return s.t('cancelled');
      default: return _req.state;
    }
  }

  String _statusColor() {
    switch (_req.state) {
      case 'bidding': return 'amber';
      case 'accepted': case 'in_progress': return 'invert';
      case 'completed': case 'done': return 'green';
      case 'cancelled': case 'canceled': return 'red';
      default: return 'slate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2))),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              StatusPill(label: _statusLabel(s), color: _statusColor()),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Description + meta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_req.description, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, height: 1.4)),
              const SizedBox(height: 8),
              Wrap(spacing: 14, children: [
                if (_req.area != null)
                  _Meta(icon: Icons.location_on_outlined, text: _req.area!),
                _Meta(icon: Icons.attach_money, text: '${_req.finalPrice > 0 ? _req.finalPrice : _req.price} ${s.t('egp')}', color: RqwstColors.brand),
                if (_req.requesterName != null)
                  _Meta(icon: Icons.person_outline, text: _req.requesterName!),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(spacing: 8, children: [
              if (_canChat)
                BrandButton(
                  label: s.t('openChat'),
                  small: true,
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: s,
                            child: ChatDetailScreen(threadId: _req.threadId!, requestId: _req.id, peerName: ''),
                          ),
                        ));
                      }
                    });
                  },
                ),
              if (_canComplete)
                BrandButton(label: rtl ? 'الطلب اكتمل' : s.t('markDone'), small: true, ghost: true,
                  icon: Icons.check, onTap: _completeReq),
              if (_canCancel)
                BrandButton(label: s.t('cancel'), small: true, danger: true,
                  icon: Icons.close, onTap: _cancelReq),
            ]),
          ),
          const SizedBox(height: 18),

          // Offers section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.people_outline, size: 16),
              const SizedBox(width: 8),
              Text(s.t('offers'), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
              if (_offers.isNotEmpty) ...[
                const SizedBox(width: 8),
                StatusPill(label: '${_offers.length}', color: 'slate'),
              ],
            ]),
          ),
          const SizedBox(height: 10),

          // Offers list
          Expanded(child: _loading
              ? ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 2,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerBox(height: 90)))
              : _offers.isEmpty
                  ? Center(child: Text(s.t('noOffers'),
                      style: GoogleFonts.cairo(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))))
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: _offers.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OfferCard(
                          offer: _offers[i],
                          req: _req,
                          s: s,
                          onAccept: _isMine ? () => _acceptOffer(_offers[i]['id'] as int) : null,
                          onReject: _isMine ? () => _rejectOffer(_offers[i]['id'] as int) : null,
                        ),
                      ),
                    )),
        ]),
      ),
    );
  }
}

// ── Offer card ─────────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final Request req;
  final AppState s;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _OfferCard({
    required this.offer, required this.req, required this.s,
    this.onAccept, this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = offer['status'] as String? ?? 'pending';
    final accepted = status == 'accepted';
    final rtl = s.isRTL;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accepted ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
          width: accepted ? 1.5 : 1,
        ),
        boxShadow: accepted
            ? [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.15), blurRadius: 20)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
      ),
      child: Column(children: [
        // Provider header row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: offer['provider_photo'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(offer['provider_photo'] as String, fit: BoxFit.cover))
                  : const Icon(Icons.person, color: Colors.grey, size: 22),
            ),
            const SizedBox(width: 12),
            // Name + badges + rating
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offer['provider_name'] as String? ?? '',
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Wrap(spacing: 5, runSpacing: 4, children: [
                if (offer['id_verified'] == true)
                  _VerifyBadge(label: rtl ? 'هوية' : 'ID ✓', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF15803D)),
                if (offer['criminal_verified'] == true)
                  _VerifyBadge(label: rtl ? 'سجل نظيف' : 'Clear ✓', bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1D4ED8)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('⭐', style: TextStyle(fontSize: 11)),
                  Text(' ${(offer['provider_rating'] as num? ?? 0).toStringAsFixed(1)}'
                      ' (${offer['provider_rating_count'] ?? 0})',
                    style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                ]),
              ]),
            ])),
            // Price
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${offer['price']}',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900, color: RqwstColors.brand)),
              Text(s.t('egp'),
                style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
            ]),
          ]),
        ),

        // Vehicle strip (delivery requests)
        if (offer['vehicle_make'] != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.symmetric(horizontal: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07))),
            ),
            child: Row(children: [
              Text(offer['vehicle_type'] == 'car' ? '🚗' : '🛵', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text('${offer['vehicle_make']} ${offer['vehicle_model']} ${offer['vehicle_year']}',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              // Vehicle photos mini strip
              if ((offer['vehicle_photos'] as List?)?.any((p) => p != null) == true)
                Row(children: [
                  ...((offer['vehicle_photos'] as List).where((p) => p != null).take(3).map((ph) =>
                    Container(
                      width: 36, height: 28, margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07))),
                      child: ClipRRect(borderRadius: BorderRadius.circular(6),
                        child: Image.network(ph as String, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 14))),
                    )
                  )),
                ]),
            ]),
          ),
        ],

        // Payment methods + action buttons
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            // Payment pills
            Wrap(spacing: 5, children: [
              if ((offer['payment_methods'] as List?)?.contains('cash') == true || offer['payment_method'] == 'cash')
                _PayBadge(label: '💵 ${rtl ? 'كاش' : 'Cash'}'),
              if ((offer['payment_methods'] as List?)?.contains('instapay') == true || offer['payment_method'] == 'instapay')
                _PayBadge(label: '📱 إنستاباي', purple: true),
            ]),
            const Spacer(),
            // Action buttons (only for pending + owner)
            if (status == 'pending' && onAccept != null)
              Row(children: [
                BrandButton(label: s.t('accept'), small: true, onTap: onAccept),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onReject,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: RqwstColors.roseL,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, size: 16, color: RqwstColors.rose),
                  ),
                ),
              ])
            else
              StatusPill(
                label: status == 'accepted' ? (rtl ? '✓ مقبول' : '✓ Accepted')
                    : status == 'rejected' ? (rtl ? 'مرفوض' : 'Rejected')
                    : (rtl ? 'في الانتظار' : 'Pending'),
                color: status == 'accepted' ? 'green' : status == 'rejected' ? 'red' : 'slate',
              ),
          ]),
        ),

        // Tap hint
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            rtl ? 'اضغط على البطاقة لرؤية التفاصيل' : 'Tap card to see full profile & reviews',
            style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
          ),
        ),
      ]),
    );
  }
}

class _VerifyBadge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _VerifyBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check, size: 7, color: fg),
      const SizedBox(width: 2),
      Text(label, style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
    ]),
  );
}

class _PayBadge extends StatelessWidget {
  final String label;
  final bool purple;
  const _PayBadge({required this.label, this.purple = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: purple ? const Color(0xFFEDE9FE) : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: purple ? const Color(0xFFC4B5FD) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
    ),
    child: Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700,
      color: purple ? const Color(0xFF7C3AED) : null)),
  );
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _Meta({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
    const SizedBox(width: 4),
    Text(text, style: GoogleFonts.cairo(fontSize: 13,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      fontWeight: color != null ? FontWeight.w700 : FontWeight.w400)),
  ]);
}
