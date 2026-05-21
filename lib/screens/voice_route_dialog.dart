import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/voice_route_service.dart';
import '../utils/theme.dart';

/// Port of the S.showVoiceDialog bottom sheet from app.js.
/// States: idle → recording → processing → result → error
/// On confirm: calls onConfirm with pickup/dropoff name + lat/lng.
class VoiceRouteDialog extends StatefulWidget {
  /// Called when the user confirms a parsed route
  final void Function({
    required String pickup, required double pickupLat, required double pickupLng,
    required String dropoff, required double dropoffLat, required double dropoffLng,
  }) onConfirm;

  /// Optional: current GPS pickup to use as fallback if no pickup spoken
  final double? currentLat;
  final double? currentLng;
  final String? currentAddress;

  const VoiceRouteDialog({
    super.key,
    required this.onConfirm,
    this.currentLat,
    this.currentLng,
    this.currentAddress,
  });

  @override
  State<VoiceRouteDialog> createState() => _VoiceRouteDialogState();
}

class _VoiceRouteDialogState extends State<VoiceRouteDialog>
    with SingleTickerProviderStateMixin {
  // Waveform animation
  late AnimationController _waveCtrl;

  // Rotating examples
  int _exampleIdx = 0;
  Timer? _exampleTimer;
  double _exampleProgress = 0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    VoiceRouteService.onStateChanged = () {
      if (mounted) setState(() {});
    };

    _startExampleRotation();

    // Auto-start recording (matches the original: openVoiceDialog + startVoiceRecording immediately)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), _startRecording);
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _exampleTimer?.cancel();
    _progressTimer?.cancel();
    VoiceRouteService.onStateChanged = null;
    super.dispose();
  }

  void _startExampleRotation() {
    // Port of startVoiceExamples() — rotates every 5 seconds
    _exampleProgress = 0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() { _exampleProgress += 0.01; });
      if (_exampleProgress >= 1.0) {
        setState(() {
          _exampleIdx = (_exampleIdx + 1) % voiceExamples.length;
          _exampleProgress = 0;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    await VoiceRouteService.startRecording();
    if (mounted) setState(() {});
  }

  Future<void> _stopRecording() async {
    await VoiceRouteService.stopRecording();
    if (mounted) setState(() {});
  }

  void _reset() {
    VoiceRouteService.reset();
    Future.delayed(const Duration(milliseconds: 200), _startRecording);
  }

  void _confirm() {
    final r = VoiceRouteService.result;
    if (r == null || !r.dropoffFound) return;

    double pLat = r.pickupLat ?? widget.currentLat ?? 0;
    double pLng = r.pickupLng ?? widget.currentLng ?? 0;
    String pName = r.pickup.isNotEmpty ? r.pickup : (widget.currentAddress ?? 'موقعي الحالي');

    widget.onConfirm(
      pickup: pName, pickupLat: pLat, pickupLng: pLng,
      dropoff: r.dropoff, dropoffLat: r.dropoffLat!, dropoffLng: r.dropoffLng!,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = VoiceRouteService.state;
    final result = VoiceRouteService.result;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 16, bottom: 20),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2)))),

        // ── Header: logo + title ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(children: [
            // Rqwst logo box
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: RqwstColors.brand,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.35), blurRadius: 16)],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('قول رايح فين', style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(
                  color: RqwstColors.brand, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('RQWST AI · مجاني', style: GoogleFonts.cairo(
                  fontSize: 10, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
              ]),
            ]),
          ]),
        ),

        // ── Rotating examples box ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('جرّب تقول:', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(voiceExamples[_exampleIdx],
                      key: ValueKey(_exampleIdx),
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
              // 5-second progress bar at bottom
              Positioned(bottom: 0, left: 0, right: 0, child: LinearProgressIndicator(
                value: _exampleProgress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(RqwstColors.brand),
                minHeight: 2,
              )),
            ]),
          ),
        ),
        const SizedBox(height: 4),

        // ── State content ────────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(state),
            child: switch (state) {
              VoiceRouteState.idle       => _IdleState(onTap: _startRecording),
              VoiceRouteState.recording  => _RecordingState(
                  transcript: VoiceRouteService.transcript,
                  waveCtrl: _waveCtrl,
                  onStop: _stopRecording),
              VoiceRouteState.processing => _ProcessingState(
                  transcript: VoiceRouteService.transcript),
              VoiceRouteState.result     => _ResultState(
                  result: result!,
                  onRetry: _reset,
                  onConfirm: _confirm),
              VoiceRouteState.error      => _ErrorState(
                  msg: result?.errorMsg ?? 'حصل خطأ',
                  onRetry: _startRecording),
            },
          ),
        ),
      ]),
    );
  }
}

// ── Idle: big pulsing mic button ──────────────────────────────────────────────
class _IdleState extends StatefulWidget {
  final VoidCallback onTap;
  const _IdleState({required this.onTap});

  @override
  State<_IdleState> createState() => _IdleStateState();
}

class _IdleStateState extends State<_IdleState> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: RqwstColors.brand,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: RqwstColors.brand.withValues(alpha: 0.35 + _pulse.value * 0.2),
                blurRadius: 32 + _pulse.value * 16,
                spreadRadius: _pulse.value * 8,
              )],
            ),
            child: child,
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: const Center(child: Text('🎤', style: TextStyle(fontSize: 40))),
          ),
        ),
        const SizedBox(height: 16),
        Text('اضغط وتكلم', style: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      ]),
    );
  }
}

// ── Recording: waveform + stop button ────────────────────────────────────────
class _RecordingState extends StatelessWidget {
  final String transcript;
  final AnimationController waveCtrl;
  final VoidCallback onStop;
  const _RecordingState({required this.transcript, required this.waveCtrl, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Column(children: [
        // Waveform bars (port of 9-bar waveform animation)
        AnimatedBuilder(
          animation: waveCtrl,
          builder: (_, __) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (i) {
              final t = (waveCtrl.value + i * 0.11) % 1.0;
              final h = 8.0 + 32.0 * (0.5 + 0.5 * Math.sin(t * Math.pi * 2));
              return Container(
                width: 4, height: h,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(color: RqwstColors.brand, borderRadius: BorderRadius.circular(2)),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Stop button
        GestureDetector(
          onTap: onStop,
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: RqwstColors.rose,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: RqwstColors.rose.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 8)],
            ),
            child: const Center(child: Text('⏹', style: TextStyle(fontSize: 32))),
          ),
        ),
        const SizedBox(height: 16),

        // Live transcript
        if (transcript.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14)),
            child: Text(transcript, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          )
        else
          Text('جاري الاستماع...', style: GoogleFonts.cairo(
            fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ── Processing: spinner ───────────────────────────────────────────────────────
class _ProcessingState extends StatelessWidget {
  final String transcript;
  const _ProcessingState({required this.transcript});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(children: [
        const Text('🔍', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 12),
        Text('جاري تحليل المسار...', style: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 6),
        Text('"$transcript"', style: GoogleFonts.cairo(
          fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
          textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const CircularProgressIndicator(color: RqwstColors.brand, strokeWidth: 2),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ── Result: parsed pickup + dropoff with confirm/retry ────────────────────────
class _ResultState extends StatelessWidget {
  final VoiceRouteResult result;
  final VoidCallback onRetry, onConfirm;
  const _ResultState({required this.result, required this.onRetry, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // What was heard
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14)),
          child: Text('🎤 "${result.transcript}"',
            style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ),
        const SizedBox(height: 14),

        // Parsed result card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [RqwstColors.brandL, RqwstColors.brand.withValues(alpha: 0.04)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(children: [
            // Pickup row
            Row(children: [
              Container(width: 10, height: 10,
                decoration: BoxDecoration(
                  color: RqwstColors.brand, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 2)])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('نقطة الانطلاق', style: GoogleFonts.cairo(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                const SizedBox(height: 2),
                Text(result.pickup.isNotEmpty ? result.pickup : 'موقعي الحالي (GPS)',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
              ])),
              Text(result.pickupFound ? '✓' : '⚠️',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: result.pickupFound ? RqwstColors.brand : RqwstColors.rose)),
            ]),

            // Connector
            Padding(padding: const EdgeInsets.only(left: 4, top: 6, bottom: 6),
              child: Container(width: 1, height: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15))),

            // Dropoff row
            Row(children: [
              Container(width: 10, height: 10,
                decoration: BoxDecoration(
                  color: RqwstColors.rose, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: RqwstColors.rose.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 2)])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('نقطة الوصول', style: GoogleFonts.cairo(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                const SizedBox(height: 2),
                Text(result.dropoff.isNotEmpty ? result.dropoff : 'لم يُحدد',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800,
                    color: result.dropoffFound ? null : RqwstColors.rose)),
              ])),
              Text(result.dropoffFound ? '✓' : '⚠️',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: result.dropoffFound ? RqwstColors.brand : RqwstColors.rose)),
            ]),
          ]),
        ),

        // Warning if dropoff not found
        if (!result.dropoffFound) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10)),
            child: Text('لم يتم التعرف على نقطة الوصول — حاول مرة أخرى',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                color: const Color(0xFFB91C1C))),
          ),
        ],
        const SizedBox(height: 16),

        // Action buttons
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('🔄 حاول تاني', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: ElevatedButton(
            onPressed: result.dropoffFound ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: RqwstColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('✅ تأكيد المسار', style: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          )),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorState({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(children: [
        const Text('❌', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 12),
        Text(msg, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: RqwstColors.rose),
          textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: RqwstColors.brand, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('🔄 حاول مرة أخرى', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white)),
        )),
      ]),
    );
  }
}

// Simple math helper (avoid dart:math import in widget file)
class Math {
  static double sin(double x) => math.sin(x);
  static const double pi = math.pi;
}
