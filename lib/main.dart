import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/app_state.dart';
import 'services/push_service.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'screens/notif_sheets.dart';
import 'screens/tasks_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/new_request_sheet.dart';
import 'screens/auth_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Init Firebase + push notifications
  try { await PushService.init(); } catch (_) {}

  final state = AppState();
  await state.init();
  runApp(ChangeNotifierProvider.value(value: state, child: const RqwstApp()));
}

class RqwstApp extends StatelessWidget {
  const RqwstApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: 'Rqwst',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: s.isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (ctx, child) => Directionality(
        textDirection: s.isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const MainShell(),
    );
  }
}

// ── Bottom-nav shell ───────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _screens = [
    HomeScreen(),
    TasksScreen(),
    ChatScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  void _onTab(int i, AppState s) {
    setState(() => _tab = i);
    switch (i) {
      case 1: s.isProv ? s.loadFeed() : s.loadMyReqs(); break;
      case 2: s.loadThreads(); break;
      case 3: s.loadWallet(); break;
      case 4: s.loadStats(); break;
    }
  }

  void _fabTap(BuildContext ctx, AppState s) =>
      showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => s.user == null ? const AuthSheet() : const NewRequestSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      body: Stack(children: [
        IndexedStack(index: _tab, children: _screens),
        if (s.toastMsg != null)
          Positioned(
            bottom: 96, left: 20, right: 20,
            child: _Toast(msg: s.toastMsg!, type: s.toastType),
          ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.07),
              width: 0.5,
            )),
          ),
          child: Row(children: [
            _NavBtn(Icons.home_outlined, Icons.home, s.t('home'), _tab == 0, () => _onTab(0, s)),
            _NavBtn(Icons.assignment_outlined, Icons.assignment, s.t('tasks'), _tab == 1, () => _onTab(1, s)),
            // Center FAB
            Expanded(child: GestureDetector(
              onTap: () => _fabTap(context, s),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52, height: 52,
                  transform: Matrix4.translationValues(0, -14, 0),
                  decoration: BoxDecoration(
                    color: s.isProv ? RqwstColors.invert : RqwstColors.brand,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: (s.isProv ? RqwstColors.invert : RqwstColors.brand).withValues(alpha: 0.35),
                      blurRadius: 20, offset: const Offset(0, 6),
                    )],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text(s.isRTL ? 'جديد' : 'New',
                    style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                ),
              ]),
            )),
            _NavBtn(Icons.chat_bubble_outline, Icons.chat_bubble, s.t('chat'), _tab == 2, () => _onTab(2, s)),
            _NavBtn(Icons.person_outline, Icons.person, s.t('profile'), _tab == 4, () => _onTab(4, s)),
          ]),
        ),
      ),
    );
  }
}

// ── Bottom nav button ─────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn(this.icon, this.activeIcon, this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    final color = active ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    return Expanded(child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(active ? activeIcon : icon, size: 22, color: color),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
    ));
  }
}

// ── Toast ─────────────────────────────────────────────────────────────────────
class _Toast extends StatelessWidget {
  final String msg, type;
  const _Toast({required this.msg, required this.type});

  @override
  Widget build(BuildContext context) {
    final fgMap = {
      'success': RqwstColors.brand, 'error': RqwstColors.rose,
      'warning': RqwstColors.amber, 'info': RqwstColors.sky,
    };
    final bgMap = {
      'success': RqwstColors.brandL, 'error': RqwstColors.roseL,
      'warning': RqwstColors.amberL, 'info': RqwstColors.skyL,
    };
    final fg = fgMap[type] ?? RqwstColors.sky;
    final bg = bgMap[type] ?? RqwstColors.skyL;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fg.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16)],
        ),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: fg))),
        ]),
      ),
    );
  }
}
