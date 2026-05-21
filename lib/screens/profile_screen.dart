import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/media_service.dart';
import '../services/push_service.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'auth_sheet.dart';
import 'notif_sheets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('profile'), style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 1,
        actions: s.user != null ? [
          TextButton.icon(
            icon: const Icon(Icons.logout, size: 14, color: Color(0xFFF43F5E)),
            label: Text(s.t('logout'), style: GoogleFonts.cairo(color: const Color(0xFFF43F5E), fontWeight: FontWeight.w700, fontSize: 13)),
            onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                title: Text(rtl ? 'تأكيد الخروج' : 'Confirm logout', style: GoogleFonts.cairo()),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('cancel'), style: GoogleFonts.cairo())),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text(s.t('logout'), style: GoogleFonts.cairo(color: RqwstColors.rose))),
                ],
              ));
              if (ok == true) s.logout();
            },
          ),
        ] : null,
      ),
      body: s.user == null
          ? EmptyState(emoji: '🔒', label: rtl ? 'سجّل دخولك الأول' : 'Login required',
              action: BrandButton(label: s.t('login'), onTap: () =>
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AuthSheet())))
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 40),
              children: [
                // ── Profile card ─────────────────────────────────────────────
                _ProfileCard(s: s),
                const SizedBox(height: 12),

                // ── Stats grid ────────────────────────────────────────────────
                _StatsGrid(s: s),
                const SizedBox(height: 12),

                // ── Provider toggle ───────────────────────────────────────────
                _ProviderToggle(s: s),
                const SizedBox(height: 12),

                // ── Identity & Verification ───────────────────────────────────
                _IdentityCard(s: s),
                const SizedBox(height: 12),

                // ── Delivery / Vehicle settings ───────────────────────────────
                _VehicleCard(s: s),
                const SizedBox(height: 12),

                // ── App settings ──────────────────────────────────────────────
                _SettingsCard(s: s),
              ],
            ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final AppState s;
  const _ProfileCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final user = s.user!;
    return RqwstCard(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        // Avatar
        Stack(children: [
          GestureDetector(
            onTap: () async {
              final file = await MediaService.pickAvatar();
              if (file != null) {
                final url = await MediaService.uploadAvatar(file);
                if (url != null) s.loadStats();
              }
            },
            child: Container(
              width: 88, height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: RqwstColors.brand,
              boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.3), blurRadius: 28)],
            ),
            child: user.profilePhoto != null || user.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(user.profilePhoto ?? user.photoUrl!, fit: BoxFit.cover))
                : const Icon(Icons.person, color: Colors.white, size: 38),
            ),
          ),
          Positioned(bottom: -4, left: -4,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2)),
              child: const Icon(Icons.edit, color: Colors.white, size: 12),
            )),
        ]),
        const SizedBox(height: 14),
        Text(user.name, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900)),
        Text(user.mobile, style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        if (user.badge != null) ...[const SizedBox(height: 4), Text(user.badge!, style: const TextStyle(fontSize: 16))],
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          if (user.isVerified) StatusPill(label: s.t('verified'), color: 'green'),
          if (user.ratingAvg > 0) StatusPill(label: '⭐ ${user.ratingAvg}', color: 'amber'),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          OutlinedButton(
            onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => ChangeNotifierProvider.value(value: s, child: EditNameSheet(currentName: user.name))),
            child: Text('✏️ ${s.isRTL ? 'تغيير الاسم' : 'Edit Name'}', style: GoogleFonts.cairo(fontSize: 12)),
          ),
          OutlinedButton(
            onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => ChangeNotifierProvider.value(value: s, child: const ChangePwSheet())),
            child: Text('🔑 ${s.isRTL ? 'تغيير كلمة المرور' : 'Change Password'}', style: GoogleFonts.cairo(fontSize: 12)),
          ),
        ]),
      ]),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final AppState s;
  const _StatsGrid({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    return Row(children: [
      Expanded(child: _StatBox(value: '${s.statsReqCount}', label: rtl ? 'طلبات مكتملة' : 'Completed', sub: rtl ? 'كطالب خدمة' : 'as requester', color: RqwstColors.brand)),
      const SizedBox(width: 8),
      Expanded(child: _StatBox(value: '${s.statsProvCount}', label: rtl ? 'طلبات نفذتها' : 'Delivered', sub: rtl ? 'كمزود خدمة' : 'as provider', color: RqwstColors.invert)),
      const SizedBox(width: 8),
      Expanded(child: _StatBox(value: s.statsRatingAvg > 0 ? '${s.statsRatingAvg}' : '—', label: rtl ? 'متوسط التقييم' : 'Avg Rating', sub: '${s.statsRatingCount} ${rtl ? 'تقييم' : 'reviews'}', color: RqwstColors.amber)),
    ]);
  }
}

class _StatBox extends StatelessWidget {
  final String value, label, sub;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => RqwstCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
    child: Column(children: [
      Text(value, style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)), textAlign: TextAlign.center),
      Text(sub, style: GoogleFonts.cairo(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)), textAlign: TextAlign.center),
    ]),
  );
}

// ── Provider toggle ───────────────────────────────────────────────────────────
class _ProviderToggle extends StatelessWidget {
  final AppState s;
  const _ProviderToggle({required this.s});

  @override
  Widget build(BuildContext context) {
    final on = s.providerAvailable == 1;
    return RqwstCard(
      background: RqwstColors.invertL,
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.bolt, size: 15, color: RqwstColors.invert),
            const SizedBox(width: 6),
            Text(s.t('providerMode'), style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 3),
          Text(on ? s.t('available') : s.t('unavailable'),
            style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ])),
        GestureDetector(
          onTap: s.toggleAvail,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 50, height: 28,
            decoration: BoxDecoration(
              color: on ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment: on ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22, height: 22,
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Identity verification ─────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final AppState s;
  const _IdentityCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final u = s.user!;
    final rtl = s.isRTL;
    return RqwstCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('🛡️ ${rtl ? 'التوثيق والهوية' : 'Identity & Verification'}',
        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(rtl ? 'الشارات دي بتظهر لطالب الخدمة وبتزيد ثقتهم' : 'These badges show on your offers and build trust',
        style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      const SizedBox(height: 14),
      _DocRow(
        icon: '🪪',
        title: rtl ? 'بطاقة الهوية / جواز السفر' : 'National ID / Passport',
        status: u.idVerifyStatus,
        rtl: rtl,
        onUpload: () async {
          final status = await MediaService.pickAndUploadIdDoc(isCriminal: false);
          if (status != null) s.notifyListeners();
        },
      ),
      const SizedBox(height: 10),
      _DocRow(
        icon: '📋',
        title: rtl ? 'ملف الحالة الجنائية' : 'Criminal Record',
        status: u.criminalVerifyStatus,
        rtl: rtl,
        onUpload: () async {
          final status = await MediaService.pickAndUploadIdDoc(isCriminal: true);
          if (status != null) s.notifyListeners();
        },
      ),
    ]));
  }
}

class _DocRow extends StatelessWidget {
  final String icon, title;
  final String? status;
  final bool rtl;
  final VoidCallback onUpload;
  const _DocRow({required this.icon, required this.title, this.status, required this.rtl, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    Widget badge;
    if (status == 'approved') {
      badge = StatusPill(label: rtl ? '✅ موثق' : '✅ Verified', color: 'green');
    } else if (status == 'pending') {
      badge = StatusPill(label: rtl ? '⏳ قيد المراجعة' : '⏳ Pending', color: 'amber');
    } else if (status == 'rejected') {
      badge = StatusPill(label: rtl ? '❌ مرفوض' : '❌ Rejected', color: 'red');
    } else {
      badge = Text(rtl ? 'لم يُرفع بعد' : 'Not uploaded yet',
        style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)));
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$icon $title', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          badge,
        ])),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: RqwstColors.brand, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.upload, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(rtl ? 'رفع' : 'Upload', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Vehicle card ──────────────────────────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  final AppState s;
  const _VehicleCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    return RqwstCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('🚗 ${rtl ? 'إعدادات التوصيل' : 'Delivery Settings'}',
        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(rtl ? 'أكمل بيانات مركبتك لقبول طلبات التوصيل' : 'Complete vehicle info to accept delivery requests',
        style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      const SizedBox(height: 14),

      // Delivery toggle
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rtl ? 'متاح لطلبات التوصيل' : 'Accept Delivery Requests',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(s.vehicleDeliveryEnabled ? (rtl ? 'مفعّل' : 'Enabled') : (rtl ? 'معطّل' : 'Disabled'),
              style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ])),
          // Toggle
          _Toggle(value: s.vehicleDeliveryEnabled, onTap: () { s.vehicleDeliveryEnabled = !s.vehicleDeliveryEnabled; s.notifyListeners(); }),
        ]),
      ),
      const SizedBox(height: 14),

      // Vehicle type buttons
      Text(rtl ? 'نوع المركبة' : 'Vehicle Type',
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      const SizedBox(height: 8),
      Row(children: [
        for (final vt in [('car', '🚗', rtl ? 'عربية' : 'Car'), ('motorcycle', '🛵', rtl ? 'موتوسيكل' : 'Motorcycle')])
          Expanded(child: Padding(
            padding: EdgeInsets.only(right: vt.$1 == 'car' ? 6 : 0),
            child: _VehicleTypeBtn(id: vt.$1, icon: vt.$2, label: vt.$3, selected: s.vehicleType == vt.$1,
              onTap: () { s.vehicleType = vt.$1; s.notifyListeners(); }),
          )),
      ]),
      const SizedBox(height: 16),

      // Make dropdown
      Text(rtl ? 'الماركة' : 'Make',
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: s.vehicleMake.isEmpty ? null : s.vehicleMake,
        items: ['Toyota','Hyundai','Kia','Nissan','Mitsubishi','Suzuki','Honda','Chevrolet','Lada','Bajaj','TVS','Lifan','Daewoo','MG','BYD']
            .map((m) => DropdownMenuItem(value: m, child: Text(m, style: GoogleFonts.cairo()))).toList(),
        onChanged: (v) { s.vehicleMake = v ?? ''; s.vehicleModel = ''; s.notifyListeners(); },
        hint: Text(rtl ? '-- اختار الماركة --' : '-- Select Make --', style: GoogleFonts.cairo()),
        style: GoogleFonts.cairo(),
      ),
      const SizedBox(height: 14),

      // Plate number
      Text(rtl ? 'رقم اللوحة' : 'Plate Number',
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      const SizedBox(height: 6),
      TextFormField(
        initialValue: s.vehiclePlate,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4),
        decoration: InputDecoration(hintText: 'أ ب ج 1234', hintStyle: GoogleFonts.cairo()),
        onChanged: (v) { s.vehiclePlate = v; },
      ),
      const SizedBox(height: 16),

      // Save button
      BrandButton(
        label: '💾 ${rtl ? 'حفظ بيانات المركبة' : 'Save Vehicle Info'}',
        full: true,
        loading: s.vehicleSaving,
        onTap: () {},
      ),
    ]));
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  const _Toggle({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 50, height: 28,
      decoration: BoxDecoration(
        color: value ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(width: 22, height: 22, margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
      ),
    ),
  );
}

class _VehicleTypeBtn extends StatelessWidget {
  final String id, icon, label;
  final bool selected;
  final VoidCallback onTap;
  const _VehicleTypeBtn({required this.id, required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15), width: 2),
        borderRadius: BorderRadius.circular(14),
        color: selected ? RqwstColors.brandL : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 5),
        Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? RqwstColors.brand : null)),
      ]),
    ),
  );
}

// ── Settings card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final AppState s;
  const _SettingsCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    return RqwstCard(child: Column(children: [
      Row(children: [
        const Icon(Icons.settings_outlined, size: 14),
        const SizedBox(width: 6),
        Text(rtl ? 'الإعدادات' : 'Settings', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 14),
      _SettingRow(
        label: rtl ? 'المظهر' : 'Theme',
        trailing: TextButton(
          onPressed: s.toggleTheme,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(s.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined, size: 14),
            const SizedBox(width: 4),
            Text(s.isDark ? (rtl ? 'فاتح' : 'Light') : (rtl ? 'داكن' : 'Dark'),
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
      const Divider(height: 1),
      _SettingRow(
        label: rtl ? 'الإشعارات' : 'Notifications',
        trailing: TextButton(
          onPressed: () async {
            final result = await PushService.requestPermission();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result == 'granted'
                    ? (rtl ? 'الإشعارات مفعّلة ✓' : 'Notifications enabled ✓')
                    : (rtl ? 'الإشعارات متوقفة' : 'Notifications blocked'),
                  style: GoogleFonts.cairo()),
                duration: const Duration(seconds: 2),
              ));
            }
          },
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.notifications_outlined, size: 14),
            const SizedBox(width: 4),
            Text(rtl ? 'تفعيل' : 'Enable', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
      const Divider(height: 1),
      _SettingRow(
        label: rtl ? 'اللغة' : 'Language',
        trailing: TextButton(
          onPressed: s.toggleLang,
          child: Text(s.lang == 'ar' ? 'English' : 'عربي', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        ),
      ),
    ]));
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: GoogleFonts.cairo(fontSize: 14))),
      trailing,
    ]),
  );
}
