import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

// ── Brand button (port of .btn-brand) ─────────────────────────────────────────
class BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool full;
  final bool small;
  final bool ghost;
  final bool danger;
  final bool invert;
  final IconData? icon;

  const BrandButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.full = false,
    this.small = false,
    this.ghost = false,
    this.danger = false,
    this.invert = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg = Colors.white;
    if (ghost) {
      bg = Theme.of(context).colorScheme.surfaceContainerHighest;
      fg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    } else if (danger) {
      bg = RqwstColors.rose;
    } else if (invert) {
      bg = RqwstColors.invert;
    } else {
      bg = RqwstColors.brand;
    }

    final child = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
        ],
        Text(label, style: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          fontSize: small ? 13 : 14,
          color: fg,
        )),
      ],
    );

    return SizedBox(
      width: full ? double.infinity : null,
      height: small ? 36 : 46,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: small ? 14 : 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: child,
      ),
    );
  }
}

// ── Status pill (port of .pill-*) ─────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  final String label;
  final String color; // 'green'|'sky'|'amber'|'red'|'slate'|'invert'

  const StatusPill({super.key, required this.label, this.color = 'slate'});

  @override
  Widget build(BuildContext context) {
    final configs = {
      'green': (const Color(0xFF16A34A), const Color(0x1F35B54B)),
      'sky':   (const Color(0xFF0369A1), const Color(0x1F0EA5E9)),
      'amber': (const Color(0xFFB45309), const Color(0x1FF59E0B)),
      'red':   (const Color(0xFFBE123C), const Color(0x1FF43F5E)),
      'invert':(const Color(0xFF6366F1), const Color(0x1A6366F1)),
      'slate': (const Color(0xFF475569), const Color(0x1A64748B)),
    };
    final c = configs[color] ?? configs['slate']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c.$2, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: GoogleFonts.cairo(
        fontSize: 12, fontWeight: FontWeight.w700, color: c.$1,
      )),
    );
  }
}

// ── Shimmer loading placeholder ────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double height;
  const ShimmerBox({super.key, this.height = 80});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: base.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String label;
  final Widget? action;

  const EmptyState({super.key, required this.emoji, required this.label, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(label, style: GoogleFonts.cairo(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ]),
      ),
    );
  }
}

// ── RqwstCard (port of .card) ──────────────────────────────────────────────────
class RqwstCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? background;

  const RqwstCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: background ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFF0F172A).withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Expanded(child: Text(title, style: GoogleFonts.cairo(
          fontSize: 17, fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.onSurface,
        ))),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

// ── Mode switcher (port of .mode-sw) ──────────────────────────────────────────
class ModeSwitcher extends StatelessWidget {
  final bool isProvider;
  final String requesterLabel;
  final String providerLabel;
  final VoidCallback onRequester;
  final VoidCallback onProvider;

  const ModeSwitcher({
    super.key,
    required this.isProvider,
    this.requesterLabel = 'Requester',
    this.providerLabel = 'Provider',
    required this.onRequester,
    required this.onProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Expanded(child: _ModeBtn(
          label: requesterLabel,
          active: !isProvider,
          activeColor: RqwstColors.brand,
          onTap: onRequester,
        )),
        Expanded(child: _ModeBtn(
          label: providerLabel,
          active: isProvider,
          activeColor: RqwstColors.invert,
          onTap: onProvider,
        )),
      ]),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _ModeBtn({required this.label, required this.active, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: active ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

extension ReadContext on BuildContext {
  // Proper provider access - screens import provider directly
}

// ── Warning banner ─────────────────────────────────────────────────────────────
class WarningBanner extends StatelessWidget {
  final String text;
  final Color color;
  final Color borderColor;
  final Widget? trailing;

  const WarningBanner({
    super.key,
    required this.text,
    this.color = const Color(0x1FF59E0B),
    this.borderColor = const Color(0x40F59E0B),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        Expanded(child: Text(text, style: GoogleFonts.cairo(fontSize: 13))),
        if (trailing != null) trailing!,
      ]),
    );
  }
}
