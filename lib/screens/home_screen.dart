import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'auth_sheet.dart';
import 'new_request_sheet.dart';
import 'notif_sheets.dart';

const _bbSlides = [
  (icon: '🏃', tag: 'مشوار',    tagEn: 'Errand',     main: 'حد يروحلي مشوار',          mainEn: 'Run an errand for me',          sub: 'مشوار صغير.. حد قريب ينجزه بدل ما تتعب ✌️',       subEn: 'A small errand nearby ✌️'),
  (icon: '💊', tag: 'صيدلية',   tagEn: 'Pharmacy',   main: 'حد يجيبلي دواء',            mainEn: 'Get me medicine',               sub: 'من الصيدلية القريبة.. بسرعة وبأمان 💊',           subEn: 'From the nearby pharmacy, fast & safe 💊'),
  (icon: '🩺', tag: 'طب',       tagEn: 'Medical',    main: 'حد دكتور يكشف',             mainEn: 'Quick doctor consult',          sub: 'استشارة طبية سريعة.. من غير زحمة 🏥',             subEn: 'Fast medical advice, no hassle 🏥'),
  (icon: '🛒', tag: 'بيع وشراء', tagEn: 'Buy & Sell', main: 'عايز أبيع حاجة',            mainEn: 'I want to sell something',      sub: 'اكتبها واحنا نجيبلك مشترين قريبين 📦',           subEn: 'Post it, we bring nearby buyers 📦'),
  (icon: '🔧', tag: 'فني',      tagEn: 'Technician', main: 'حد يساعد في البيت',          mainEn: 'Help at home',                  sub: 'سباكة أو كهرباء أو نظافة.. في أي وقت 🔧',        subEn: 'Plumbing, electric, cleaning any time 🔧'),
  (icon: '🚗', tag: 'مواصلات',  tagEn: 'Ride',       main: 'حد يوصّلني',                mainEn: 'Take me somewhere',              sub: 'رحلة من أو لأي مكان.. بسهولة وأمان 🚗',          subEn: 'A ride anywhere, safe & easy 🚗'),
  (icon: '🏠', tag: 'عقارات',   tagEn: 'Real Estate',main: 'حد يأجّرني شقة',            mainEn: 'Find me an apartment',          sub: 'عايز تأجر؟ لقي أحسن عروض في منطقتك 🏠',          subEn: 'Find the best deals near you 🏠'),
  (icon: '⚖️', tag: 'قانون',    tagEn: 'Legal',      main: 'حد محامي',                  mainEn: 'Need a lawyer',                 sub: 'استشارة قانونية.. حد فاهم يخلصها بسرعة ⚖️',      subEn: 'Legal advice, done fast ⚖️'),
  (icon: '📚', tag: 'تعليم',    tagEn: 'Education',  main: 'حد مدرّس',                  mainEn: 'I need a tutor',                sub: 'درس خصوصي أو كورس.. في البيت أو أونلاين 📚',     subEn: 'Private lesson or course, home or online 📚'),
  (icon: '📱', tag: 'صيانة',    tagEn: 'Repair',     main: 'حد يصلّح موبايلي',          mainEn: 'Fix my phone',                  sub: 'صيانة سريعة.. تيجي عندك أو إنت تمشي 📱',        subEn: 'Fast repair, on-site or drop-off 📱'),
  (icon: '✈️', tag: 'سفر',      tagEn: 'Travel',     main: 'حد يسافر معايا',             mainEn: 'Travel companion',              sub: 'رحلة أو سفرية.. لقي رفيق قريب 🧳',               subEn: 'Trip or travel, find a nearby companion 🧳'),
  (icon: '✨', tag: 'ركوست',    tagEn: 'Rqwst',      main: 'أي حاجة تانية',             mainEn: 'Anything else',                 sub: 'فكر فيها.. واكتبها.. وإحنا نلقطلك حد 💫',        subEn: 'Think it, post it, we find someone 💫'),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            toolbarHeight: 60,
            title: Row(children: [
              // Logo box
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: RqwstColors.brand,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.3), blurRadius: 10)],
                ),
                child: const Icon(Icons.diamond, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 9),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(s.t('appName'), style: GoogleFonts.cairo(
                    fontSize: 17, fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: RqwstColors.amber,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(rtl ? 'تجريبي' : 'BETA', style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white,
                    )),
                  ),
                ]),
                Text(
                  s.user != null
                      ? (rtl ? 'أهلاً، ${s.user!.name.split(' ').first}' : s.user!.name.split(' ').first)
                      : (rtl ? 'اطلب أي حاجة' : 'Request anything'),
                  style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ]),
            ]),
            actions: [
              TextButton(
                onPressed: s.toggleLang,
                child: Text(s.lang == 'ar' ? 'EN' : 'ع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              IconButton(
                onPressed: s.toggleTheme,
                icon: Icon(s.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined, size: 20),
              ),
              if (s.user == null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => _openAuth(context),
                    child: Text(s.t('login'), style: GoogleFonts.cairo(
                      color: Colors.white, fontWeight: FontWeight.w700,
                    )),
                    style: TextButton.styleFrom(
                      backgroundColor: RqwstColors.brand,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => NotifSheet(
                      notifs: const [],      // TODO: wire s.notifs when AppState adds them
                      notifPerm: 'default',
                      rtl: s.isRTL,
                      onMarkAllRead: () => Navigator.pop(context),
                      onTap: (_) => Navigator.pop(context),
                    ),
                  ),
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(14),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // ── Billboard ─────────────────────────────────────────────────
              _Billboard(s: s),
              const SizedBox(height: 12),

              // ── Main CTA ──────────────────────────────────────────────────
              BrandButton(
                label: s.t('newReq'),
                full: true,
                onTap: () => s.user != null ? _openNewReq(context) : _openAuth(context),
              ),
              const SizedBox(height: 12),

              // ── How it works (requester) ───────────────────────────────────
              RqwstCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.bolt, size: 14, color: RqwstColors.brand),
                  const SizedBox(width: 6),
                  Text(rtl ? 'إزاي بيشتغل؟' : 'How it works',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                ]),
                const SizedBox(height: 12),
                ...[ for (final item in (rtl
                    ? [('1','سجّل واكتب طلبك بالتفصيل'),('2','مزودو الخدمة القريبين يشوفوا طلبك'),('3','اختار أحسن عرض وابدأ الشغل')]
                    : [('1','Register and post your request'),('2','Nearby providers see it instantly'),('3','Pick an offer and get it done')]))
                  _StepRow(n: item.$1, text: item.$2),
                ],
              ])),
              const SizedBox(height: 12),

              // ── Provider CTA card ─────────────────────────────────────────
              RqwstCard(
                background: RqwstColors.invert.withValues(alpha: 0.05),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.bolt, size: 14, color: RqwstColors.invert),
                    const SizedBox(width: 6),
                    Text(rtl ? 'كن مزود خدمة واكسب فلوس' : 'Become a provider & earn',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
                  ]),
                  const SizedBox(height: 12),
                  ...[ for (final item in (rtl
                      ? [('1','فعّل وضع المزود من حسابك وابقى متاح'),('2','شوف الطلبات القريبة منك واقبل اللي يناسبك'),('3','اكمّل الطلب واستلم تقييمك وابني سمعتك')]
                      : [('1','Enable provider mode in your profile'),('2','Browse nearby requests and accept what suits you'),('3','Complete the job, get rated and build your reputation')]))
                    _StepRow(n: item.$1, text: item.$2, color: RqwstColors.invert),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.bolt, size: 13, color: RqwstColors.invert),
                      label: Text(rtl ? 'ابدأ كمزود دلوقتي' : 'Start as a provider',
                        style: GoogleFonts.cairo(color: RqwstColors.invert, fontWeight: FontWeight.w800, fontSize: 13)),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: RqwstColors.invert.withValues(alpha: 0.3)),
                        backgroundColor: RqwstColors.invert.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ])),
          ),
        ],
      ),
    );
  }

  void _openAuth(BuildContext ctx) =>
      showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const AuthSheet());

  void _openNewReq(BuildContext ctx) =>
      showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => const NewRequestSheet());
}

// ── Billboard widget ───────────────────────────────────────────────────────────
class _Billboard extends StatelessWidget {
  final AppState s;
  const _Billboard({required this.s});

  @override
  Widget build(BuildContext context) {
    final slide = _bbSlides[s.bbIdx % _bbSlides.length];
    final rtl = s.isRTL;

    return RqwstCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: RqwstColors.brandL,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(rtl ? slide.tag : slide.tagEn,
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
              ]),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Text(slide.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(child: Text(rtl ? slide.main : slide.mainEn,
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, height: 1.3))),
            ]),
            const SizedBox(height: 5),
            Text(rtl ? slide.sub : slide.subEn,
              style: GoogleFonts.cairo(fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ]),
        ),
        // Dots
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int i = 0; i < _bbSlides.length; i++)
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: i == s.bbIdx ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i == s.bbIdx ? RqwstColors.brand : Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String n, text;
  final Color? color;
  const _StepRow({required this.n, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? RqwstColors.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: c.withValues(alpha: 0.15), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(n, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w900, color: c)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: GoogleFonts.cairo(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ))),
      ]),
    );
  }
}
