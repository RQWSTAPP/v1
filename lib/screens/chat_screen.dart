import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../services/api.dart';
import '../services/call_service.dart';
import '../services/voice_service.dart';
import '../services/location_service.dart';
import '../services/media_service.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'auth_sheet.dart';
import 'rating_sheet.dart';

// ── Chat list screen ───────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadThreads());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('chat'), style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined, size: 20), onPressed: s.loadThreads),
        ],
      ),
      body: s.user == null
          ? EmptyState(
              emoji: '🔒',
              label: rtl ? 'سجّل دخولك الأول' : 'Login required',
              action: BrandButton(label: s.t('login'), onTap: () =>
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (_) => const AuthSheet())))
          : s.threadsLoading && s.threads.isEmpty
              ? ListView.builder(padding: const EdgeInsets.all(14), itemCount: 4,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: ShimmerBox(height: 72)))
              : RefreshIndicator(
                  onRefresh: s.loadThreads,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                    itemCount: s.threads.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 0) return _SupportBtn(s: s);
                      return Padding(padding: const EdgeInsets.only(bottom: 8),
                        child: _ThreadTile(thread: s.threads[i - 1], s: s));
                    },
                  ),
                ),
    );
  }
}

class _SupportBtn extends StatelessWidget {
  final AppState s;
  const _SupportBtn({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RqwstCard(
        onTap: () => _openSupport(context, s),
        background: RqwstColors.invert.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: RqwstColors.invert, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rtl ? 'تواصل مع الدعم' : 'Contact Support',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
            Text(rtl ? 'بلّغ عن مشكلة أو اسأل سؤال' : 'Report a problem or ask a question',
              style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ])),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final ChatThread thread;
  final AppState s;
  const _ThreadTile({required this.thread, required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    final isDone = ['completed', 'done'].contains(thread.requestState);
    final isActive = ['accepted', 'in_progress'].contains(thread.requestState);
    final isCancelled = ['cancelled', 'canceled'].contains(thread.requestState);

    String statusLabel = '';
    String statusColor = 'slate';
    if (isDone) { statusLabel = rtl ? '✓ مكتمل' : '✓ Done'; statusColor = 'green'; }
    else if (isActive) { statusLabel = rtl ? '⚡ نشط' : '⚡ Active'; statusColor = 'invert'; }
    else if (isCancelled) { statusLabel = rtl ? 'ملغي' : 'Cancelled'; statusColor = 'red'; }
    else if (thread.requestState != null) { statusLabel = rtl ? 'جاري' : 'Active'; statusColor = 'amber'; }

    String preview = thread.lastMsgType == 'voice'
        ? (rtl ? '🎙️ رسالة صوتية' : '🎙️ Voice note')
        : (thread.lastMessage ?? thread.requestDescription ?? '');

    Color avatarBg = thread.isRequester ? RqwstColors.brand : RqwstColors.invert.withValues(alpha: 0.85);
    if (thread.isSupport) avatarBg = RqwstColors.invert;

    return RqwstCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: s,
          child: ChatDetailScreen(
            threadId: thread.id,
            requestId: thread.requestId,
            peerName: thread.peerName,
            isSupport: thread.isSupport,
          ),
        ),
      )),
      padding: const EdgeInsets.all(13),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
          child: Icon(thread.isSupport ? Icons.support_agent : Icons.person, color: Colors.white, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Row(children: [
              Flexible(child: Text(thread.peerName,
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
              if (!thread.isSupport) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: thread.isRequester ? RqwstColors.brandL : RqwstColors.invertL,
                    borderRadius: BorderRadius.circular(999)),
                  child: Text(thread.isRequester ? (rtl ? 'طالب' : 'Client') : (rtl ? 'مزود' : 'Provider'),
                    style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w800,
                      color: thread.isRequester ? RqwstColors.brand : RqwstColors.invert)),
                ),
              ],
            ])),
            if (statusLabel.isNotEmpty) StatusPill(label: statusLabel, color: statusColor),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            Expanded(child: Text(preview,
              style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              overflow: TextOverflow.ellipsis)),
            if (thread.finalPrice != null)
              Text('${thread.finalPrice} ${rtl ? 'ج' : 'EGP'}',
                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: RqwstColors.brand)),
          ]),
        ])),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
      ]),
    );
  }
}

// ── Support chat opener ────────────────────────────────────────────────────────
void _openSupport(BuildContext context, AppState s) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: s,
      child: const _SupportSheet(),
    ),
  );
}

class _SupportSheet extends StatefulWidget {
  const _SupportSheet();
  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<_SupportSheet> {
  final _msgCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _msgs = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() { _msgCtrl.dispose(); _subjectCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final j = await ApiService.call('support.get');
      if (mounted) setState(() => _msgs = List<Map<String, dynamic>>.from(j['data']?['messages'] ?? []));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
    _scrollBottom();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ApiService.call('support.send', {
        'message': text,
        if (_msgs.isEmpty) 'subject': _subjectCtrl.text.trim(),
      });
      _msgCtrl.clear();
      await _load();
    } catch (_) {}
    setState(() => _sending = false);
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: RqwstColors.invert, shape: BoxShape.circle),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rtl ? 'الدعم الفني' : 'Support', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900)),
              Text(rtl ? 'فريقنا هنا يساعدك' : 'Our team is here to help',
                style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            ]),
          ]),
        ),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: RqwstColors.invert))
            : _msgs.isEmpty
                ? Center(child: Text(rtl ? 'ابعت رسالتك وهنرد عليك في أقرب وقت' : 'Send your message and we will reply soon',
                    style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    textAlign: TextAlign.center))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) {
                      final m = _msgs[i];
                      final isAdmin = m['sender'] == 'admin';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : RqwstColors.invert,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isAdmin ? const Radius.circular(4) : const Radius.circular(16),
                                bottomRight: isAdmin ? const Radius.circular(16) : const Radius.circular(4),
                              ),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              if (isAdmin) Text(rtl ? '👮 الدعم' : '👮 Support',
                                style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
                              Text(m['body'] as String? ?? '',
                                style: GoogleFonts.cairo(fontSize: 14, color: isAdmin ? null : Colors.white)),
                              const SizedBox(height: 3),
                              Text((m['created_at'] as String? ?? '').length >= 16
                                  ? (m['created_at'] as String).substring(11, 16) : '',
                                style: GoogleFonts.cairo(fontSize: 10,
                                  color: isAdmin
                                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.55))),
                            ]),
                          ),
                        ),
                      );
                    },
                  )),

        // Subject (first message only)
        if (_msgs.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _subjectCtrl,
              decoration: InputDecoration(hintText: rtl ? 'موضوع المشكلة أو السؤال' : 'Subject of your issue',
                hintStyle: GoogleFonts.cairo()),
              style: GoogleFonts.cairo(),
            ),
          ),

        // Input bar
        Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
          ),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              maxLines: 3, minLines: 1,
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(hintText: rtl ? 'اكتب رسالتك هنا…' : 'Type your message here…',
                hintStyle: GoogleFonts.cairo()),
              style: GoogleFonts.cairo(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(width: 42, height: 42,
                decoration: BoxDecoration(color: RqwstColors.invert, borderRadius: BorderRadius.circular(12)),
                child: _sending
                    ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white, size: 18)),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Chat detail screen — full port of the chat overlay from app.js
// ══════════════════════════════════════════════════════════════════════════════
class ChatDetailScreen extends StatefulWidget {
  final int threadId;
  final int? requestId;
  final String peerName;
  final bool isSupport;

  const ChatDetailScreen({
    super.key,
    required this.threadId,
    this.requestId,
    required this.peerName,
    this.isSupport = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  List<ChatMessage> _msgs = [];
  Map<String, dynamic>? _summary;   // request summary card
  Map<String, dynamic>? _thread;    // thread info (closed state)
  bool _loading = false;
  bool _sending = false;
  int _lastSigId = 0;
  Timer? _poll;

  // Voice state
  bool _recording = false;
  int _recSec = 0;
  String? _recPath;  // path after stopping, before sending

  // Call state mirror
  late CallState _call;

  @override
  void initState() {
    super.initState();
    _call = CallService.state;
    CallService.onStateChanged = () { if (mounted) setState(() => _call = CallService.state); };
    VoiceService.onTick = () { if (mounted) setState(() => _recSec = VoiceService.recSec); };
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _fetch());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _poll?.cancel();
    CallService.onStateChanged = null;
    VoiceService.onTick = null;
    super.dispose();
  }

  // ── Fetch messages (port of fetchChat()) ──────────────────────────────────
  Future<void> _fetch() async {
    if (_loading) return;
    _loading = true;
    try {
      final s = context.read<AppState>();
      final j = await ApiService.call('chat.messages', {
        'thread_id': widget.threadId,
        'after_signal': _lastSigId,
      });
      final uid = s.user?.id ?? 0;
      final raw = (j['data']?['messages'] ?? []) as List;

      // Parse system messages (port of parseSysMsg)
      final newMsgs = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final sId = int.tryParse(m['sender_id']?.toString() ?? '') ?? -1;
        if (sId == 0 && (m['body'] as String? ?? '').trim().startsWith('{')) {
          try {
            final parsed = jsonDecode(m['body'] as String);
            m['_sys'] = parsed['sys'] ?? parsed['t'];
            m['_duration'] = parsed['duration'];
          } catch (_) {}
        }
        m['_mine'] = sId == uid;
        return m;
      }).toList();

      bool added = false;
      for (final m in newMsgs) {
        if (!_msgs.any((x) => x.id == (m['id'] as int? ?? 0))) {
          _msgs.add(_mapToMsg(m, uid));
          added = true;
        }
      }

      if (j['data']?['last_signal_id'] != null) {
        _lastSigId = j['data']['last_signal_id'];
      }
      _summary = j['data']?['request'] as Map<String, dynamic>?;
      _thread = j['data']?['thread'] as Map<String, dynamic>?;

      // Handle WebRTC signals
      await CallService.handleSignals(
        newMsgs.where((m) => (m['signal_type'] as String? ?? '').isNotEmpty).toList(),
        widget.threadId, uid,
      );

      if (mounted && added) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
        });
      }
    } catch (_) {}
    _loading = false;
  }

  // ── Send text ──────────────────────────────────────────────────────────────
  Future<void> _sendText() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      await ApiService.call('chat.send', {'thread_id': widget.threadId, 'message': text});
      await _fetch();
    } catch (_) {}
    setState(() => _sending = false);
  }

  // ── Voice note ─────────────────────────────────────────────────────────────
  Future<void> _startVoice() async {
    final ok = await VoiceService.startRecording();
    if (ok) setState(() { _recording = true; _recSec = 0; });
    else _toast(context.read<AppState>().t('micBlocked'));
  }

  Future<void> _stopVoice() async {
    final path = await VoiceService.stopRecording();
    setState(() { _recording = false; _recPath = path; });
  }

  Future<void> _sendVoice() async {
    if (_recPath == null) return;
    setState(() => _sending = true);
    try {
      await MediaService.sendVoiceNote(widget.threadId, _recPath!);
      setState(() => _recPath = null);
      await _fetch();
    } catch (_) {}
    setState(() => _sending = false);
  }

  void _clearVoice() {
    VoiceService.clearRecording();
    setState(() { _recPath = null; _recording = false; });
  }

  // ── Send location ──────────────────────────────────────────────────────────
  Future<void> _sendLocation() async {
    final s = context.read<AppState>();
    _toast(s.isRTL ? 'جاري تحديد موقعك…' : 'Getting your location…');
    final loc = await LocationService.getForChat();
    if (loc == null) { _toast(s.isRTL ? 'تعذّر تحديد الموقع' : 'Could not get location'); return; }
    try {
      await ApiService.call('chat.send', {
        'thread_id': widget.threadId,
        'message': jsonEncode({'type': 'location', 'lat': loc.lat.toStringAsFixed(6), 'lng': loc.lng.toStringAsFixed(6)}),
        'msg_type': 'location',
      });
      await _fetch();
      _toast(s.isRTL ? 'اتبعت الموقع ✓' : 'Location sent ✓');
    } catch (_) {}
  }

  // ── Send image ─────────────────────────────────────────────────────────────
  Future<void> _sendImage() async {
    final file = await MediaService.pickChatImage();
    if (file == null) return;
    setState(() => _sending = true);
    try {
      await MediaService.sendChatImage(widget.threadId, file);
      await _fetch();
    } catch (_) {}
    setState(() => _sending = false);
  }

  // ── Complete request ───────────────────────────────────────────────────────
  Future<void> _complete() async {
    final s = context.read<AppState>();
    final rid = _summary?['id'] as int? ?? widget.requestId;
    if (rid == null) return;
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
      final j = await ApiService.call('requests.complete', {'request_id': rid});
      await s.loadMyReqs();
      _toast(s.t('reqCompleted'));
      await _fetch();
      final srvReq = j['data']?['req'] ?? {};
      final providerId = srvReq['provider_id'] as int?;
      final requesterId = srvReq['user_id'] as int?;
      if (mounted && myId == requesterId && providerId != null && providerId != myId) {
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => ChangeNotifierProvider.value(value: s,
            child: RatingSheet(requestId: rid, toUserId: providerId)));
      }
    } catch (_) {}
  }

  // ── Delivery status update ─────────────────────────────────────────────────
  Future<void> _updateDeliveryStatus(String status) async {
    final rid = _summary?['id'] as int? ?? widget.requestId;
    if (rid == null) return;
    try {
      await ApiService.call('requests.update_delivery_status', {'request_id': rid, 'delivery_status': status});
      await _fetch();
    } catch (_) {}
  }

  void _toast(String msg) => context.read<AppState>().toast(msg, 'info');

  bool get _isClosed => _thread?['status'] == 'closed';
  bool get _isDelivery => _summary?['type'] == 'توصيل';
  bool get _isProvider => context.read<AppState>().isProv;
  bool get _canComplete {
    final state = _summary?['state'] as String? ?? '';
    return state == 'accepted' || state == 'in_progress';
  }

  static ChatMessage _mapToMsg(Map<String, dynamic> m, int uid) {
    return ChatMessage.fromJson(m, uid);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [
        // ── Header ────────────────────────────────────────────────────────────
        _ChatHeader(
          peerName: widget.peerName,
          summary: _summary,
          isClosed: _isClosed,
          isProvider: _isProvider,
          canComplete: _canComplete,
          call: _call,
          rtl: rtl,
          s: s,
          onBack: () => Navigator.pop(context),
          onStartCall: () => CallService.startCall(widget.threadId),
          onEndCall: () => CallService.endCall(widget.threadId),
          onComplete: _complete,
        ),

        // ── Delivery status bar ────────────────────────────────────────────────
        if (_isDelivery && !_isClosed && _summary != null)
          _DeliveryStatusBar(
            summary: _summary!,
            isProvider: _isProvider,
            rtl: rtl,
            onUpdate: _updateDeliveryStatus,
          ),

        // ── Full-screen call overlay ───────────────────────────────────────────
        if (_call.active)
          _CallOverlay(
            call: _call,
            peerName: widget.peerName,
            threadId: widget.threadId,
            rtl: rtl,
            s: s,
          ),

        // ── Request summary card ───────────────────────────────────────────────
        if (_summary != null && (_summary!['description'] as String? ?? '').isNotEmpty && !_call.active)
          _RequestSummaryCard(summary: _summary!, rtl: rtl, s: s),

        // ── Messages ─────────────────────────────────────────────────────────────
        if (!_call.active)
          Expanded(child: _msgs.isEmpty
              ? Center(child: Text(rtl ? 'ابعت أول رسالة!' : 'Send the first message!',
                  style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) => _MsgBubble(msg: _msgs[i], s: s, threadId: widget.threadId, onComplete: _complete, summary: _summary),
                )),

        if (!_call.active) ...[
          // ── Voice preview bar (after recording, before send) ─────────────────
          if (_recPath != null)
            _VoicePreviewBar(path: _recPath!, rtl: rtl, s: s, sending: _sending, onSend: _sendVoice, onClear: _clearVoice),

          // ── Recording bar ──────────────────────────────────────────────────────
          if (_recording)
            _RecordingBar(recSec: _recSec, rtl: rtl, onStop: _stopVoice, s: s),

          // ── Chat closed banner ─────────────────────────────────────────────────
          if (_isClosed)
            _ClosedBanner(thread: _thread, rtl: rtl),

          // ── Input bar ──────────────────────────────────────────────────────────
          if (!_isClosed && !_recording && _recPath == null)
            _InputBar(
              ctrl: _ctrl,
              rtl: rtl,
              sending: _sending,
              s: s,
              onSend: _sendText,
              onVoice: _startVoice,
              onImage: _sendImage,
              onLocation: _sendLocation,
            ),
        ],
      ]),
    );
  }
}

// ── Chat header ────────────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final String peerName;
  final Map<String, dynamic>? summary;
  final bool isClosed, isProvider, canComplete;
  final CallState call;
  final bool rtl;
  final AppState s;
  final VoidCallback onBack, onComplete;
  final Future<void> Function() onStartCall, onEndCall;

  const _ChatHeader({
    required this.peerName, this.summary, required this.isClosed,
    required this.isProvider, required this.canComplete, required this.call,
    required this.rtl, required this.s, required this.onBack,
    required this.onStartCall, required this.onEndCall, required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final state = summary?['state'] as String? ?? '';
    final isActive = state == 'accepted' || state == 'in_progress';
    final isDone = state == 'completed' || state == 'done';

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
        ),
        child: Row(children: [
          // Back
          IconButton(icon: Icon(rtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, size: 18),
            onPressed: onBack, padding: const EdgeInsets.all(8)),
          // Peer name + description
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(peerName, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis),
            if (summary?['description'] != null)
              Row(children: [
                Flexible(child: Text((summary!['description'] as String).substring(0,
                    (summary!['description'] as String).length.clamp(0, 40)),
                  style: GoogleFonts.cairo(fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  overflow: TextOverflow.ellipsis)),
                if (isDone) ...[
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(color: RqwstColors.brandL, borderRadius: BorderRadius.circular(999)),
                    child: Text(rtl ? '✓ مكتمل' : '✓ Done',
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: RqwstColors.brand))),
                ],
              ]),
          ])),

          // Call button (not in call, not closed)
          if (!isClosed && !call.active)
            GestureDetector(
              onTap: onStartCall,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: RqwstColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.25)),
                ),
                child: Column(children: [
                  const Icon(Icons.call, color: RqwstColors.brand, size: 17),
                  const SizedBox(height: 2),
                  Text(rtl ? 'مجاني' : 'Call', style: GoogleFonts.cairo(
                    fontSize: 9, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
                ]),
              ),
            ),

          // Mark done button (in-call hidden too)
          if (!isClosed && !call.active && canComplete && isActive) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onComplete,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: RqwstColors.invert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RqwstColors.invert.withValues(alpha: 0.25)),
                ),
                child: Column(children: [
                  const Icon(Icons.check, color: RqwstColors.invert, size: 17),
                  const SizedBox(height: 2),
                  Text(rtl ? 'اكتمل الطلب' : 'Done', style: GoogleFonts.cairo(
                    fontSize: 9, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Delivery status bar ────────────────────────────────────────────────────────
class _DeliveryStatusBar extends StatelessWidget {
  final Map<String, dynamic> summary;
  final bool isProvider, rtl;
  final Future<void> Function(String) onUpdate;
  const _DeliveryStatusBar({required this.summary, required this.isProvider, required this.rtl, required this.onUpdate});

  static const _stages = [
    (id: 'pickup',     label: 'استلام',     icon: '📦'),
    (id: 'on_the_way', label: 'في الطريق',  icon: '🚗'),
    (id: 'delivered',  label: 'تم التسليم', icon: '✅'),
  ];

  bool _isReached(String current, String stage) {
    final order = ['pickup', 'on_the_way', 'delivered'];
    return order.indexOf(current) >= order.indexOf(stage);
  }

  @override
  Widget build(BuildContext context) {
    final pickup = summary['pickup_address'] as String? ?? '';
    final dropoff = summary['dropoff_address'] as String? ?? '';
    final km = summary['delivery_km'];
    final deliveryStatus = summary['delivery_status'] as String? ?? '';
    final state = summary['state'] as String? ?? '';
    final canUpdate = isProvider && (state == 'accepted' || state == 'in_progress') && deliveryStatus != 'delivered';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
      ),
      child: Column(children: [
        // Route line
        if (pickup.isNotEmpty) Row(children: [
          const Text('📍', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(child: Text(pickup, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          const Text('→', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          const Text('🏁', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(child: Text(dropoff, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          if (km != null)
            Container(margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: RqwstColors.brandL, borderRadius: BorderRadius.circular(999)),
              child: Text('$km كم', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: RqwstColors.brand))),
        ]),
        const SizedBox(height: 10),

        // Stage pills
        Row(children: [
          for (int i = 0; i < _stages.length; i++) ...[
            Expanded(child: GestureDetector(
              onTap: canUpdate ? () => onUpdate(_stages[i].id) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _isReached(deliveryStatus, _stages[i].id) ? RqwstColors.brand : RqwstColors.brandL.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: deliveryStatus == _stages[i].id ? RqwstColors.brand : RqwstColors.brand.withValues(alpha: 0.2)),
                ),
                child: Column(children: [
                  Text(_stages[i].icon, style: const TextStyle(fontSize: 14)),
                  Text(_stages[i].label, style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w800,
                    color: _isReached(deliveryStatus, _stages[i].id) ? Colors.white : RqwstColors.brand.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center),
                ]),
              ),
            )),
            if (i < 2)
              Container(width: 12, height: 2, margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ],
        ]),
      ]),
    );
  }
}

// ── Full-screen call overlay ───────────────────────────────────────────────────
class _CallOverlay extends StatelessWidget {
  final CallState call;
  final String peerName;
  final int threadId;
  final bool rtl;
  final AppState s;
  const _CallOverlay({required this.call, required this.peerName, required this.threadId, required this.rtl, required this.s});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: call.inCall
              ? const [Color(0xFF0F3022), Color(0xFF1A4A30)]
              : const [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Avatar
        Container(width: 90, height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2)),
          child: const Icon(Icons.person, color: Colors.white70, size: 44)),
        const SizedBox(height: 14),

        // Direction label
        if (call.ringing && !call.inCall)
          Text(rtl ? 'مكالمة واردة من' : 'INCOMING FROM',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.5)),
        if (call.outgoing && !call.inCall)
          Text(rtl ? 'جاري الاتصال بـ' : 'CALLING',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.5)),
        if (call.inCall)
          Text(rtl ? 'متصل' : 'CONNECTED',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: RqwstColors.brand.withValues(alpha: 0.8))),
        const SizedBox(height: 6),

        // Peer name
        Text(peerName, style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 8),

        // Status sub-label
        if (call.outgoing && !call.inCall)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(
              color: Colors.white.withValues(alpha: 0.7), strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(rtl ? 'في انتظار الرد…' : 'Waiting for answer…',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
          ]),
        if (call.ringing && !call.inCall)
          Text(rtl ? 'يتصل بك…' : 'is calling you…',
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
        if (call.inCall)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(CallService.fmtDur(call.duration),
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: RqwstColors.brand.withValues(alpha: 0.9))),
          ]),

        const SizedBox(height: 40),

        // Action buttons
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (call.ringing && !call.inCall) ...[
            // Incoming: reject + answer
            _CallBtn(icon: Icons.call_end, color: RqwstColors.rose, size: 66,
              onTap: () => CallService.rejectCall(threadId)),
            const SizedBox(width: 24),
            _CallBtn(icon: Icons.call, color: RqwstColors.brand, size: 72,
              onTap: () => CallService.answerCall(threadId), pulse: true),
          ] else ...[
            // Speaker toggle
            Column(children: [
              _CallBtn(
                icon: call.loudspeaker ? Icons.volume_up : Icons.volume_down,
                color: Colors.white.withValues(alpha: call.loudspeaker ? 0.25 : 0.1),
                size: 56,
                onTap: CallService.toggleSpeaker,
                border: true,
              ),
              const SizedBox(height: 6),
              Text(call.loudspeaker ? (rtl ? 'سماعة عالية' : 'Speaker') : (rtl ? 'سماعة عادية' : 'Earpiece'),
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
            ]),
            const SizedBox(width: 24),
            // End call
            Column(children: [
              _CallBtn(icon: Icons.call_end, color: RqwstColors.rose, size: 66,
                onTap: () => CallService.endCall(threadId)),
              const SizedBox(height: 6),
              Text(s.t('endCall'), style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
            ]),
          ],
        ]),
      ]),
    ));
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool pulse;
  final bool border;
  const _CallBtn({required this.icon, required this.color, required this.size, required this.onTap, this.pulse = false, this.border = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5) : null,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: pulse ? 24 : 16)],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.4),
    ),
  );
}

// ── Request summary card (top of chat) ────────────────────────────────────────
class _RequestSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final bool rtl;
  final AppState s;
  const _RequestSummaryCard({required this.summary, required this.rtl, required this.s});

  @override
  Widget build(BuildContext context) {
    final state = summary['state'] as String? ?? '';
    String statusLabel = '';
    String statusColor = 'slate';
    switch (state) {
      case 'bidding': statusLabel = s.t('bidding'); statusColor = 'amber'; break;
      case 'accepted': case 'in_progress': statusLabel = s.t('accepted'); statusColor = 'invert'; break;
      case 'completed': case 'done': statusLabel = s.t('completed'); statusColor = 'green'; break;
      case 'cancelled': case 'canceled': statusLabel = s.t('cancelled'); statusColor = 'red'; break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [RqwstColors.brandL, RqwstColors.invert.withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.assignment_outlined, size: 11, color: RqwstColors.brand),
          const SizedBox(width: 5),
          Text(rtl ? 'تفاصيل الطلب' : 'Request Details',
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
        ]),
        const SizedBox(height: 4),
        Text(summary['description'] as String? ?? '',
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Row(children: [
          Text('${summary['final_price'] ?? summary['price'] ?? 0} ${s.t('egp')}',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: RqwstColors.brand)),
          if (summary['area'] != null) ...[
            const SizedBox(width: 12),
            Text('📍 ${summary['area']}',
              style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
          if (statusLabel.isNotEmpty) ...[
            const SizedBox(width: 12),
            StatusPill(label: statusLabel, color: statusColor),
          ],
        ]),
      ]),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────────
class _MsgBubble extends StatelessWidget {
  final ChatMessage msg;
  final AppState s;
  final int threadId;
  final VoidCallback onComplete;
  final Map<String, dynamic>? summary;
  const _MsgBubble({required this.msg, required this.s, required this.threadId, required this.onComplete, this.summary});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;

    // ── System message (sender_id == 0) ──────────────────────────────────────
    if (msg.body.startsWith('{') || msg.senderName.isEmpty) {
      Map<String, dynamic>? parsed;
      try { parsed = jsonDecode(msg.body); } catch (_) {}
      final sys = parsed?['sys'] ?? parsed?['t'];
      final dur = parsed?['duration'] as int?;

      String sysText = '';
      Widget? sysAction;

      if (sys == 'offer_accepted' || sys == 'request_accepted') {
        sysText = '${sys == 'offer_accepted' ? '✅' : '⚡'} ${rtl ? (sys == 'offer_accepted' ? 'تم قبول العرض' : 'تم قبول الطلب') : (sys == 'offer_accepted' ? 'Offer accepted' : 'Request accepted')}';
      } else if (sys == 'call_ended') {
        sysText = '📞 ${rtl ? 'مكالمة' : 'Call'}${dur != null ? ' · ${CallService.fmtDur(dur)}' : ''}';
      } else if (sys == 'completed') {
        sysText = '🎉 ${rtl ? 'اكتمل الطلب' : 'Request completed'}';
      } else if (sys == 'cancelled') {
        sysText = '⛔ ${rtl ? 'اتلغى الطلب' : 'Request cancelled'}';
      } else if (sys == 'complete_pending') {
        final rid = summary?['id'] as int?;
        sysText = '🏁 ${rtl ? 'طرف أكد الإنهاء' : 'One party confirmed completion'}';
        sysAction = TextButton(
          onPressed: onComplete,
          child: Text(rtl ? 'خلّصت أنا كمان ✓' : 'Done too ✓',
            style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w800)));
      } else {
        sysText = msg.body;
      }

      if (sysText.isEmpty && sysAction == null) return const SizedBox.shrink();

      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(sysText, style: GoogleFonts.cairo(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center),
            if (sysAction != null) sysAction,
          ]),
        ),
      ));
    }

    final mine = msg.isMine;

    // ── Message content ────────────────────────────────────────────────────────
    Widget content;
    if (msg.type == 'voice' || msg.voiceUrl != null) {
      content = _VoiceBubble(url: msg.voiceUrl, mine: mine, rtl: rtl, s: s);
    } else if (msg.type == 'image' || msg.imageUrl != null) {
      content = _ImageBubble(url: msg.imageUrl ?? '', mine: mine);
    } else if (msg.type == 'location') {
      Map<String, dynamic>? loc;
      try { loc = jsonDecode(msg.body); } catch (_) {}
      if (loc != null) {
        content = _LocationBubble(lat: loc['lat'].toString(), lng: loc['lng'].toString(), mine: mine, rtl: rtl);
      } else {
        content = Text(msg.body, style: GoogleFonts.cairo(fontSize: 14, color: mine ? Colors.white : null));
      }
    } else {
      content = Text(msg.body.isNotEmpty ? msg.body : '…',
        style: GoogleFonts.cairo(fontSize: 14, color: mine ? Colors.white : null));
    }

    // Timestamp

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            Container(width: 28, height: 28, decoration: BoxDecoration(
              color: RqwstColors.invert.withValues(alpha: 0.7), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 14)),
            const SizedBox(width: 6),
          ],
          Flexible(child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: msg.type == 'image' || msg.imageUrl != null
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: mine ? RqwstColors.brand : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: mine ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: mine ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                ),
                child: content,
              ),
              const SizedBox(height: 2),
              // Timestamp (from created_at)
            ],
          )),
          if (mine) const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  final String? url;
  final bool mine, rtl;
  final AppState s;
  const _VoiceBubble({this.url, required this.mine, required this.rtl, required this.s});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: url != null ? () => VoiceService.playVoice(url!) : null,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.play_circle_filled, size: 28, color: mine ? Colors.white : RqwstColors.brand),
      const SizedBox(width: 8),
      Text(s.isRTL ? 'رسالة صوتية' : 'Voice note',
        style: GoogleFonts.cairo(fontSize: 13, color: mine ? Colors.white : null)),
    ]),
  );
}

class _ImageBubble extends StatelessWidget {
  final String url;
  final bool mine;
  const _ImageBubble({required this.url, required this.mine});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => launchUrl(Uri.parse(url)),
    child: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: mine ? const Radius.circular(18) : const Radius.circular(4),
        bottomRight: mine ? const Radius.circular(4) : const Radius.circular(18),
      ),
      child: Image.network(url, width: 200, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200, height: 120, color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey))),
    ),
  );
}

class _LocationBubble extends StatelessWidget {
  final String lat, lng;
  final bool mine, rtl;
  const _LocationBubble({required this.lat, required this.lng, required this.mine, required this.rtl});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => launchUrl(Uri.parse('https://www.google.com/maps?q=$lat,$lng')),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mine ? Colors.white.withValues(alpha: 0.15) : RqwstColors.brandL,
        borderRadius: BorderRadius.circular(10),
        border: mine ? null : Border.all(color: RqwstColors.brand.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 34, height: 34,
          decoration: BoxDecoration(
            color: mine ? Colors.white.withValues(alpha: 0.2) : RqwstColors.brand,
            shape: BoxShape.circle),
          child: Icon(Icons.location_on, color: Colors.white, size: 18)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rtl ? 'الموقع الحالي' : 'Current Location',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
              color: mine ? Colors.white : null)),
          Text(rtl ? 'اضغط لفتح الخريطة' : 'Tap to open maps',
            style: GoogleFonts.cairo(fontSize: 11, color: mine ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ]),
        const SizedBox(width: 10),
        Icon(Icons.open_in_new, size: 14, color: mine ? Colors.white70 : RqwstColors.brand),
      ]),
    ),
  );
}

// ── Voice preview bar ─────────────────────────────────────────────────────────
class _VoicePreviewBar extends StatelessWidget {
  final String path;
  final bool rtl, sending;
  final AppState s;
  final VoidCallback onSend, onClear;
  const _VoicePreviewBar({required this.path, required this.rtl, required this.sending, required this.s, required this.onSend, required this.onClear});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
    ),
    child: Row(children: [
      // Play button
      GestureDetector(
        onTap: () => VoiceService.playVoice(path),
        child: Container(width: 36, height: 36,
          decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20)),
      ),
      const SizedBox(width: 8),
      // Waveform placeholder
      Expanded(child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: RqwstColors.brandL,
          borderRadius: BorderRadius.circular(999)),
        child: Center(child: Text(rtl ? '🎙️ جاهزة للإرسال' : '🎙️ Ready to send',
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: RqwstColors.brand))),
      )),
      const SizedBox(width: 8),
      // Clear
      GestureDetector(onTap: onClear,
        child: Container(width: 32, height: 32,
          decoration: BoxDecoration(color: RqwstColors.roseL, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.close, size: 16, color: RqwstColors.rose))),
      const SizedBox(width: 6),
      // Send voice
      BrandButton(label: s.t('sendVoice'), small: true, loading: sending, onTap: onSend),
    ]),
  );
}

// ── Recording bar ─────────────────────────────────────────────────────────────
class _RecordingBar extends StatelessWidget {
  final int recSec;
  final bool rtl;
  final VoidCallback onStop;
  final AppState s;
  const _RecordingBar({required this.recSec, required this.rtl, required this.onStop, required this.s});

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final r = sec % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
    decoration: BoxDecoration(
      color: RqwstColors.rose.withValues(alpha: 0.05),
      border: Border(top: BorderSide(color: RqwstColors.rose.withValues(alpha: 0.2))),
    ),
    child: Row(children: [
      Container(width: 8, height: 8,
        decoration: const BoxDecoration(color: RqwstColors.rose, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(_fmt(recSec), style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: RqwstColors.rose)),
      const SizedBox(width: 10),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: (recSec / 120).clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation(RqwstColors.rose),
          minHeight: 3),
      )),
      const SizedBox(width: 10),
      ElevatedButton.icon(
        onPressed: onStop,
        icon: const Icon(Icons.stop, size: 14),
        label: Text(s.t('stopRec'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: RqwstColors.rose, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: const StadiumBorder()),
      ),
    ]),
  );
}

// ── Chat closed banner ─────────────────────────────────────────────────────────
class _ClosedBanner extends StatelessWidget {
  final Map<String, dynamic>? thread;
  final bool rtl;
  const _ClosedBanner({this.thread, required this.rtl});

  @override
  Widget build(BuildContext context) {
    final isCompleted = thread?['closed_reason'] == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: isCompleted ? RqwstColors.brand.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(
          color: isCompleted ? RqwstColors.brand.withValues(alpha: 0.2) : Theme.of(context).dividerColor.withValues(alpha: 0.3))),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(isCompleted ? '🎉' : '🔒', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Column(children: [
          Text(
            isCompleted
                ? (rtl ? 'اكتمل الطلب بنجاح' : 'Request completed')
                : (rtl ? 'المحادثة اتقفلت' : 'Chat closed'),
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800,
              color: isCompleted ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          Text(rtl ? 'مش ممكن ترسل رسائل جديدة' : 'No new messages can be sent',
            style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
        ]),
      ]),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool rtl, sending;
  final AppState s;
  final VoidCallback onSend, onVoice, onImage, onLocation;
  const _InputBar({required this.ctrl, required this.rtl, required this.sending, required this.s,
    required this.onSend, required this.onVoice, required this.onImage, required this.onLocation});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      // Image
      _IconBtn(icon: Icons.image_outlined, onTap: onImage),
      const SizedBox(width: 2),
      // Location
      _IconBtn(icon: Icons.location_on_outlined, onTap: onLocation),
      const SizedBox(width: 2),
      // Voice
      _IconBtn(icon: Icons.mic_none, onTap: onVoice),
      const SizedBox(width: 6),
      // Text field (grows with content)
      Expanded(child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100),
        child: TextField(
          controller: ctrl,
          maxLines: null,
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: s.t('typeMsg'), hintStyle: GoogleFonts.cairo(),
            isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          ),
          style: GoogleFonts.cairo(fontSize: 16),
          onSubmitted: (_) => onSend(),
        ),
      )),
      const SizedBox(width: 6),
      // Send
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl,
        builder: (_, v, __) {
          final hasText = v.text.trim().isNotEmpty;
          return GestureDetector(
            onTap: hasText ? onSend : onVoice,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: RqwstColors.brand,
                borderRadius: BorderRadius.circular(12)),
              child: sending
                  ? const Padding(padding: EdgeInsets.all(9),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(hasText ? Icons.send : Icons.mic, color: Colors.white, size: 17),
            ),
          );
        },
      ),
    ]),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
    ),
  );
}
