import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'auth_sheet.dart';
import 'new_request_sheet.dart';
import 'active_request_overlay.dart';
import 'request_detail_sheet.dart';
import 'chat_screen.dart' as chat_screen;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<AppState>();
      if (s.isProv) s.loadFeed(); else s.loadMyReqs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 1,
            toolbarHeight: 56,
            title: Text(s.isProv ? s.t('nearbyReqs') : s.t('tasks'),
              style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
            actions: [
              if (s.isProv)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AvailToggle(s: s),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                    label: Text(rtl ? 'جديد' : 'New', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const NewRequestSheet()),
                    style: TextButton.styleFrom(backgroundColor: RqwstColors.brand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 12)),
                  ),
                ),
            ],
          ),

          // ── Active request banner (tap to reopen AR overlay) ─────────
          if (s.user != null) ...[
            () {
              final active = s.myReqs.where((r) => r.isMine &&
                (r.state == 'bidding' || r.state == 'open' || r.state == 'accepted' || r.state == 'in_progress')).toList();
              if (active.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              final req = active.first;
              return SliverToBoxAdapter(child: GestureDetector(
                onTap: () => Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
                    value: s,
                    child: ActiveRequestOverlay(req: req, isProvider: false, onDismiss: () => Navigator.pop(context)),
                  ),
                  transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                )),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0D2A1A), Color(0xFF0A1628)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.25), blurRadius: 16)],
                  ),
                  child: Row(children: [
                    Container(width: 10, height: 10,
                      decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      s.isRTL ? '${req.description} • اضغط لتتابع الطلب' : '${req.description} • Tap to track',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    )),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white54),
                  ]),
                ),
              ));
            }(),
          ],

          // ── Mode switch ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _ModeSwitch(s: s),
          )),

          // ── Body ────────────────────────────────────────────────────────────
          if (s.user == null)
            SliverFillRemaining(child: EmptyState(
              emoji: '🔒',
              label: rtl ? 'سجّل دخولك الأول' : 'Login required',
              action: BrandButton(label: s.t('login'), onTap: () =>
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AuthSheet())),
            ))
          else if (s.isProv)
            _ProviderFeed(s: s)
          else
            _RequesterList(s: s),
        ],
      ),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────
class _ModeSwitch extends StatelessWidget {
  final AppState s;
  const _ModeSwitch({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        _Btn(label: s.t('requesterMode'), active: !s.isProv, color: RqwstColors.brand, onTap: () => s.setMode('requester')),
        _Btn(label: s.t('providerMode'), active: s.isProv, color: RqwstColors.invert, onTap: () => s.setMode('provider')),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _Btn({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext ctx) => Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: active ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
    child: Text(label, textAlign: TextAlign.center,
      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
        color: active ? Colors.white : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.5))),
  )));
}

// ── Availability toggle ───────────────────────────────────────────────────────
class _AvailToggle extends StatelessWidget {
  final AppState s;
  const _AvailToggle({required this.s});

  @override
  Widget build(BuildContext context) {
    final on = s.providerAvailable == 1;
    return GestureDetector(
      onTap: s.toggleAvail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? RqwstColors.brand : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(
            color: on ? Colors.white : Colors.grey,
            shape: BoxShape.circle,
          )),
          const SizedBox(width: 6),
          Text(on ? s.t('available') : s.t('unavailable'),
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: on ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ]),
      ),
    );
  }
}

// ── Requester: My requests ────────────────────────────────────────────────────
class _RequesterList extends StatelessWidget {
  final AppState s;
  const _RequesterList({required this.s});

  static const _done = {'completed', 'done', 'cancelled', 'canceled'};

  @override
  Widget build(BuildContext context) {
    if (s.myReqsLoading && s.myReqs.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(14),
        sliver: SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerBox(height: 88)),
          childCount: 3,
        )),
      );
    }

    final active = s.myReqs.where((r) => r.isMine && !_done.contains(r.state)).toList();

    if (active.isEmpty) {
      return SliverFillRemaining(child: EmptyState(
        emoji: '📋',
        label: s.t('noRequests'),
        action: BrandButton(label: s.t('newReq'), small: true, onTap: () =>
          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const NewRequestSheet())),
      ));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      sliver: SliverList(delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ReqCard(req: active[i], s: s),
        ),
        childCount: active.length,
      )),
    );
  }
}

class _ReqCard extends StatelessWidget {
  final Request req;
  final AppState s;
  const _ReqCard({required this.req, required this.s});

  @override
  Widget build(BuildContext context) {
    return RqwstCard(
      onTap: () {
        final isActive = req.state == 'accepted' || req.state == 'in_progress' || req.state == 'bidding' || req.state == 'open';
        if (isActive) {
          Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
              value: s,
              child: ActiveRequestOverlay(req: req, isProvider: false, onDismiss: () => Navigator.pop(context)),
            ),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          ));
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(value: s, child: RequestDetailSheet(req: req)),
          );
        }
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(req.description, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, height: 1.35))),
          const SizedBox(width: 8),
          StatusPill(label: _statusLabel(req, s), color: _statusColor(req)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 12, children: [
          if (req.area != null)
            _Meta(icon: Icons.location_on_outlined, text: req.area!),
          _Meta(icon: Icons.attach_money, text: '${req.finalPrice} ${s.t('egp')}', color: RqwstColors.brand),
          if (req.offerCount > 0)
            _Meta(icon: Icons.chat_bubble_outline, text: '${req.offerCount} ${s.t('offers')}'),
        ]),
        if (req.threadId != null) ...[
          const SizedBox(height: 10),
          BrandButton(label: s.t('openChat'), small: true, icon: Icons.chat_bubble_outline, onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: s,
                child: chat_screen.ChatDetailScreen(threadId: req.threadId!, requestId: req.id, peerName: ''),
              ),
            ));
          }),
        ],
      ]),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon; final String text; final Color? color;
  const _Meta({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
    const SizedBox(width: 3),
    Text(text, style: GoogleFonts.cairo(fontSize: 12,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      fontWeight: color != null ? FontWeight.w700 : FontWeight.w400)),
  ]);
}

String _statusLabel(Request r, AppState s) {
  switch (r.state) {
    case 'bidding': return s.t('bidding');
    case 'accepted': case 'in_progress': return s.t('accepted');
    case 'completed': case 'done': return s.t('completed');
    case 'cancelled': case 'canceled': return s.t('cancelled');
    default: return r.state;
  }
}

String _statusColor(Request r) {
  switch (r.state) {
    case 'bidding': return 'amber';
    case 'accepted': case 'in_progress': return 'invert';
    case 'completed': case 'done': return 'green';
    case 'cancelled': case 'canceled': return 'red';
    default: return 'slate';
  }
}

// ── Provider: Feed ─────────────────────────────────────────────────────────────
class _ProviderFeed extends StatelessWidget {
  final AppState s;
  const _ProviderFeed({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;

    if (s.feedLoading && s.feed.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(14),
        sliver: SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerBox(height: 100)),
          childCount: 3,
        )),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      sliver: SliverList(delegate: SliverChildListDelegate([
        // Warnings
        if (s.feedBusy)
          WarningBanner(text: s.t('alreadyActive'), color: RqwstColors.amberL,
            borderColor: RqwstColors.amber.withValues(alpha: 0.25)),
        if (s.providerAvailable == 0)
          WarningBanner(
            text: s.t('providerAvailableHint'),
            color: RqwstColors.roseL,
            borderColor: RqwstColors.rose.withValues(alpha: 0.2),
            trailing: TextButton(
              onPressed: s.toggleAvail,
              child: Text(s.t('available'), style: GoogleFonts.cairo(color: RqwstColors.brand, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),

        if (s.feed.isEmpty)
          EmptyState(
            emoji: '🔍',
            label: rtl ? 'مفيش ركوستات قريبة' : 'No nearby requests',
          )
        else
          ...s.feed.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: _FeedCard(req: req, s: s),
          )),
      ])),
    );
  }
}

class _FeedCard extends StatefulWidget {
  final Request req;
  final AppState s;
  const _FeedCard({required this.req, required this.s});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _showOffer = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    final s = widget.s;
    final rtl = s.isRTL;

    return RqwstCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(req.description, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, height: 1.35)),
          const SizedBox(height: 5),
          Wrap(spacing: 10, children: [
            if (req.requesterName != null)
              _Meta(icon: Icons.person_outline, text: req.requesterName!),
            if (req.area != null)
              _Meta(icon: Icons.location_on_outlined, text: req.area!),
          ]),
        ])),
        const SizedBox(width: 10),
        Text('${req.price}', style: GoogleFonts.cairo(fontSize: 21, fontWeight: FontWeight.w900, color: RqwstColors.brand)),
      ]),

      // Delivery extra info
      if (req.type == 'توصيل' && req.pickupAddress != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Row(children: [const Text('📍 ', style: TextStyle(fontSize: 12)), Expanded(child: Text(req.pickupAddress!, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: RqwstColors.brand), overflow: TextOverflow.ellipsis))]),
            const SizedBox(height: 4),
            Row(children: [const Text('🏁 ', style: TextStyle(fontSize: 12)), Expanded(child: Text(req.dropoffAddress ?? '', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))]),
          ]),
        ),
      ],

      const SizedBox(height: 10),

      // Actions
      if (!s.feedBusy) Row(children: [
        Expanded(child: BrandButton(
          label: s.t('acceptReq'),
          small: true,
          onTap: s.providerAvailable == 1 ? () => s.acceptReq(req.id) : null,
        )),
        const SizedBox(width: 8),
        Expanded(child: BrandButton(
          label: s.t('makeOffer'),
          small: true,
          ghost: true,
          onTap: s.providerAvailable == 1 ? () => setState(() => _showOffer = !_showOffer) : null,
        )),
      ]),

      // My offer badge
      if (req.myOffer != null) ...[
        const SizedBox(height: 8),
        StatusPill(
          label: req.myOffer!['status'] == 'accepted'
              ? (rtl ? 'قُبل عرضك ✓' : 'Offer accepted ✓')
              : req.myOffer!['status'] == 'rejected'
              ? (rtl ? 'رُفض عرضك' : 'Offer rejected')
              : (rtl ? 'في انتظار الموافقة…' : 'Waiting for approval…'),
          color: req.myOffer!['status'] == 'accepted' ? 'green'
              : req.myOffer!['status'] == 'rejected' ? 'red' : 'amber',
        ),
      ],

      // Inline offer input
      if (_showOffer) ...[
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: s.t('offerPrice')),
            style: GoogleFonts.cairo(),
          )),
          const SizedBox(width: 8),
          BrandButton(
            label: s.t('submitOffer'),
            small: true,
            onTap: () {
              final price = num.tryParse(_ctrl.text);
              if (price != null) {
                s.makeOffer(req.id, price);
                setState(() => _showOffer = false);
              }
            },
          ),
        ]),
      ],
    ]));
  }
}
