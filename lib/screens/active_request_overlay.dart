import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/api.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'request_detail_sheet.dart';
import 'chat_screen.dart';
import 'rating_sheet.dart';

// ── Stage helpers (port of arStage() from app.js) ─────────────────────────────
String _arStage(Request req) {
  final s = req.state.toLowerCase();
  if (s == 'bidding' || s == 'open' || s == 'posted') return 'searching';
  if (s == 'accepted' || s == 'in_progress') return 'accepted';
  return 'done';
}

bool _canComplete(Request req) =>
    req.state == 'accepted' || req.state == 'in_progress';

bool _canCancel(Request req) =>
    req.state == 'bidding' || req.state == 'open' || req.state == 'posted';

// ── AR Overlay widget ─────────────────────────────────────────────────────────
class ActiveRequestOverlay extends StatefulWidget {
  final Request req;
  final bool isProvider;
  final VoidCallback onDismiss;

  const ActiveRequestOverlay({
    super.key,
    required this.req,
    required this.isProvider,
    required this.onDismiss,
  });

  @override
  State<ActiveRequestOverlay> createState() => _ActiveRequestOverlayState();
}

class _ActiveRequestOverlayState extends State<ActiveRequestOverlay>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _pulseCtrl;

  List<Map<String, dynamic>> _offers = [];
  int _secondsLeft = 1800;
  int _totalSeconds = 1800;
  Timer? _countdown;
  bool _loadingOffers = false;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadOffers();
    _startTimer();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    _countdown?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Port of startARTimer() — uses expires_at if available, else 30min
    _secondsLeft = 1800;
    _totalSeconds = 1800;
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
      if (_secondsLeft == 0) {
        _countdown?.cancel();
        context.read<AppState>().loadMyReqs();
      }
    });
  }

  Future<void> _loadOffers() async {
    if (_loadingOffers) return;
    setState(() => _loadingOffers = true);
    try {
      final j = await ApiService.call('offers.for_request', {'request_id': widget.req.id});
      if (mounted) {
        setState(() => _offers = List<Map<String, dynamic>>.from(j['data']?['offers'] ?? []));
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingOffers = false);
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Future<void> _cancelReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    String reason = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(rtl ? 'تلغي الطلب؟' : 'Cancel Request?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(rtl ? 'ممكن تسيب سبب بسيط (اختياري)' : 'You can leave a reason (optional)',
            style: GoogleFonts.cairo(fontSize: 13)),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(hintText: rtl ? 'سبب الإلغاء…' : 'Reason (optional)…'),
            style: GoogleFonts.cairo(),
            onChanged: (v) => reason = v,
            maxLines: 2,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text(s.t('back'), style: GoogleFonts.cairo())),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text(rtl ? 'إلغاء الطلب' : 'Cancel Request',
              style: GoogleFonts.cairo(color: RqwstColors.rose, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ApiService.call('requests.cancel', {'request_id': widget.req.id, 'reason': reason});
      await s.loadMyReqs();
      widget.onDismiss();
      s.toast(s.t('reqCancelled'), 'warning');
    } catch (_) {}
  }

  Future<void> _completeReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(rtl ? 'الطلب خلص؟' : 'Request complete?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
        content: Text(rtl ? 'هتأكد إن كل حاجة تمت' : 'Confirm everything went well', style: GoogleFonts.cairo()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text(rtl ? 'أيوه، خلص' : 'Yes, done',
              style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final myId = s.user?.id ?? 0;
      final j = await ApiService.call('requests.complete', {'request_id': widget.req.id});
      await s.loadMyReqs();
      widget.onDismiss();
      s.toast(s.t('reqCompleted'), 'success');
      // Open rating if I'm the requester and there's a provider
      final srvReq = j['data']?['req'] ?? {};
      final providerId = srvReq['provider_id'] as int?;
      final requesterId = srvReq['user_id'] as int?;
      if (mounted && myId == requesterId && providerId != null && providerId != myId) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: s,
              child: RatingSheet(requestId: widget.req.id, toUserId: providerId),
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _openDetail() {
    widget.onDismiss();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppState>(),
        child: RequestDetailSheet(req: widget.req),
      ),
    );
  }

  void _openChat(int threadId) {
    widget.onDismiss();
    final s = context.read<AppState>();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: s,
        child: ChatDetailScreen(
          threadId: threadId,
          requestId: widget.req.id,
          peerName: widget.req.requesterName ?? '',
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;
    final stage = _arStage(widget.req);
    final isSearching = stage == 'searching';
    final isAccepted = stage == 'accepted';
    final isProvider = widget.isProvider;

    final accentColor = isProvider ? RqwstColors.invert : RqwstColors.brand;
    final bgColor1 = isProvider ? const Color(0xFF0A1628) : const Color(0xFF0A1628);
    final bgColor2 = isProvider ? const Color(0xFF0D2240) : const Color(0xFF0D2A1A);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor1, bgColor2, bgColor1],
            stops: const [0, 0.6, 1],
          ),
        ),
        child: Stack(children: [
          // ── Animated rings (InDrive style) ──────────────────────────────
          _AnimatedRings(ctrl: _ringCtrl, color: accentColor, count: isSearching ? 4 : 3),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Column(children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  // Dismiss
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 7, height: 7,
                        decoration: BoxDecoration(color: isSearching ? RqwstColors.brand : accentColor, shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Text(
                        isSearching
                            ? s.t('searching')
                            : isProvider
                                ? (rtl ? 'جاري التنفيذ' : 'In Progress')
                                : (rtl ? 'قبل المزود طلبك ✓' : 'Provider accepted ✓'),
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ]),
              ),

              // ── Center section ─────────────────────────────────────────
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Stack(alignment: Alignment.center, children: [
                      // Outer pulse ring
                      Container(
                        width: 120 + _pulseCtrl.value * 10,
                        height: 120 + _pulseCtrl.value * 10,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.08 + _pulseCtrl.value * 0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Icon box
                      Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 40)],
                        ),
                        child: Icon(
                          isSearching ? Icons.search
                              : isProvider ? Icons.bolt
                              : Icons.check,
                          color: Colors.white, size: 38,
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 22),

                  // Stage title
                  Text(
                    isProvider
                        ? (rtl ? 'جاري التنفيذ' : 'In Progress')
                        : isSearching
                            ? (_offers.isNotEmpty ? s.t('gotOffers') : s.t('searching'))
                            : s.t('providerAccepted'),
                    style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSearching
                        ? (_offers.isNotEmpty
                            ? '${_offers.length} ${rtl ? 'مزودين أبدوا اهتمامهم' : 'providers are interested'}'
                            : (rtl ? 'كل الناس القريبة بتشوف الطلب' : 'Everyone nearby can see your request'))
                        : (widget.req.requesterName ?? ''),
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withOpacity(0.55)),
                    textAlign: TextAlign.center,
                  ),

                  // Timer bar (searching only)
                  if (isSearching && _secondsLeft > 0) ...[
                    const SizedBox(height: 24),
                    SizedBox(width: 300, child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(s.t('timeLeft'),
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                        Text(_fmtTime(_secondsLeft),
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.9))),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _secondsLeft / _totalSeconds,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(RqwstColors.brand),
                          minHeight: 5,
                        ),
                      ),
                    ])),
                  ],

                  // Offer dots (bidding with offers)
                  if (isSearching && _offers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ..._offers.take(5).map((o) => Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: RqwstColors.brand.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: RqwstColors.brand.withOpacity(0.4)),
                        ),
                        child: Center(child: Text('${o['price']}',
                          style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: RqwstColors.brand))),
                      )),
                      if (_offers.length > 5)
                        Text('+${_offers.length - 5}',
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                    ]),
                  ],

                  // Stage progress strip
                  const SizedBox(height: 28),
                  _StageStrip(stage: stage, isProvider: isProvider, s: s),
                ],
              )),

              // ── Bottom section ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
                child: Column(children: [
                  // Safety disclaimer (searching)
                  if (isSearching) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: RqwstColors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RqwstColors.amber.withOpacity(0.25)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('⚠️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          rtl
                              ? 'تحقق من تقييم المزود وشاراته. لا تشارك معلوماتك الشخصية.'
                              : 'Always check provider rating and badges. Never share personal info.',
                          style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withOpacity(0.7), height: 1.5),
                        )),
                      ]),
                    ),
                  ],

                  // Request card
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.req.description,
                        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
                      const SizedBox(height: 5),
                      Row(children: [
                        if (widget.req.area != null) ...[
                          Text('📍 ${widget.req.area}',
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(width: 12),
                        ],
                        Text('${widget.req.finalPrice > 0 ? widget.req.finalPrice : widget.req.price} ${s.t('egp')}',
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                            color: RqwstColors.brand.withOpacity(0.9))),
                      ]),
                    ]),
                  ),

                  // Primary action button
                  if (!isProvider) ...[
                    if (isSearching && _offers.isNotEmpty)
                      _DarkBtn(
                        label: '${s.t('viewOffers')} (${_offers.length})',
                        icon: Icons.search,
                        color: RqwstColors.brand,
                        onTap: _openDetail,
                        full: true,
                      )
                    else if (isAccepted && widget.req.threadId != null)
                      _DarkBtn(
                        label: s.t('openChatNow'),
                        icon: Icons.chat_bubble_outline,
                        color: RqwstColors.invert,
                        onTap: () => _openChat(widget.req.threadId!),
                        full: true,
                      ),
                  ] else ...[
                    if (widget.req.threadId != null)
                      _DarkBtn(
                        label: s.t('openChat'),
                        icon: Icons.chat_bubble_outline,
                        color: RqwstColors.invert,
                        onTap: () => _openChat(widget.req.threadId!),
                        full: true,
                      ),
                    if (_canComplete(widget.req)) ...[
                      const SizedBox(height: 8),
                      _DarkBtn(
                        label: rtl ? 'الطلب اكتمل' : s.t('markDone'),
                        icon: Icons.check,
                        color: RqwstColors.brand.withOpacity(0.7),
                        onTap: _completeReq,
                        full: true,
                        outlined: true,
                      ),
                    ],
                  ],

                  // Cancel button
                  if (_canCancel(widget.req)) ...[
                    const SizedBox(height: 8),
                    _DarkBtn(
                      label: s.t('cancelReq'),
                      icon: Icons.close,
                      color: RqwstColors.rose.withOpacity(0.8),
                      onTap: _cancelReq,
                      full: true,
                      outlined: true,
                    ),
                  ],
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  String _fmtTime(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

// ── Animated concentric rings ─────────────────────────────────────────────────
class _AnimatedRings extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  final int count;
  const _AnimatedRings({required this.ctrl, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Center(
        child: Stack(alignment: Alignment.center, children: [
          for (int i = 0; i < count; i++)
            _Ring(
              size: 120.0 + i * 80,
              opacity: math.max(0, 0.22 - i * 0.05 + math.sin(ctrl.value * 2 * math.pi + i * 0.4) * 0.05),
              color: color,
            ),
        ]),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _Ring({required this.size, required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color.withOpacity(opacity), width: 1),
    ),
  );
}

// ── Stage progress strip ──────────────────────────────────────────────────────
class _StageStrip extends StatelessWidget {
  final String stage;
  final bool isProvider;
  final AppState s;
  const _StageStrip({required this.stage, required this.isProvider, required this.s});

  @override
  Widget build(BuildContext context) {
    final accentColor = isProvider ? RqwstColors.invert : RqwstColors.brand;
    final activeIdx = stage == 'accepted' ? 2 : 1;
    final stages = [s.t('stagePosted'), s.t('stageBidding'), s.t('stageAccepted'), s.t('stageDone')];

    return SizedBox(
      width: 320,
      child: Row(
        children: List.generate(stages.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final idx = (i - 1) ~/ 2;
            return Expanded(child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 20),
              color: idx < activeIdx ? accentColor : Colors.white.withOpacity(0.1),
            ));
          } else {
            final idx = i ~/ 2;
            final active = idx <= activeIdx;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: active ? accentColor : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('${idx + 1}',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800,
                    color: active ? Colors.white : Colors.white.withOpacity(0.3)))),
              ),
              const SizedBox(height: 5),
              Text(stages[idx],
                style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700,
                  color: active ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.3))),
            ]);
          }
        }),
      ),
    );
  }
}

// ── Dark-themed action button ─────────────────────────────────────────────────
class _DarkBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool full;
  final bool outlined;

  const _DarkBtn({
    required this.label, required this.icon, required this.color,
    required this.onTap, this.full = false, this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: full ? double.infinity : null,
      height: outlined ? 44 : 52,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: outlined ? color.withOpacity(0.12) : color,
            borderRadius: BorderRadius.circular(16),
            border: outlined ? Border.all(color: color.withOpacity(0.4)) : null,
            boxShadow: outlined ? null : [BoxShadow(color: color.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white.withOpacity(outlined ? 0.9 : 1), size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.cairo(fontSize: outlined ? 14 : 16, fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(outlined ? 0.9 : 1))),
          ]),
        ),
      ),
    );
  }
}
