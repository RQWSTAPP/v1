import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'auth_sheet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadWallet());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('wallet'), style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 1,
      ),
      body: s.user == null
          ? EmptyState(emoji: '🔒', label: rtl ? 'سجّل دخولك الأول' : 'Login required',
              action: BrandButton(label: s.t('login'), onTap: () =>
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AuthSheet())))
          : s.walletLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    // Balance grid
                    Row(children: [
                      Expanded(child: RqwstCard(
                        background: RqwstColors.brand.withOpacity(0.08),
                        child: Column(children: [
                          Text(s.t('balance'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          const SizedBox(height: 4),
                          Text('${s.walletBalance}', style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: RqwstColors.brand)),
                          Text(s.t('egp'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        ], mainAxisAlignment: MainAxisAlignment.center),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: RqwstCard(
                        background: RqwstColors.invert.withOpacity(0.08),
                        child: Column(children: [
                          Text(s.t('earned'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          const SizedBox(height: 4),
                          Text('${s.walletEarned}', style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: RqwstColors.invert)),
                          Text(s.t('egp'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        ], mainAxisAlignment: MainAxisAlignment.center),
                      )),
                    ]),
                    const SizedBox(height: 20),
                    Text(
                      rtl ? 'ميزات المحفظة قريباً 💳' : 'Wallet features coming soon 💳',
                      style: GoogleFonts.cairo(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ]),
                ),
    );
  }
}
