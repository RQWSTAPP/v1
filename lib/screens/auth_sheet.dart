import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';

class AuthSheet extends StatefulWidget {
  const AuthSheet({super.key});

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  bool _isLogin = true;
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() { _name.dispose(); _mobile.dispose(); _pw.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final s = context.read<AppState>();
    setState(() { _loading = true; _error = null; });
    String? err;
    if (_isLogin) {
      err = await s.login(_mobile.text.trim(), _pw.text);
    } else {
      err = await s.register(_name.text.trim(), _mobile.text.trim(), _pw.text);
    }
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
    } else {
      setState(() { _error = err; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final rtl = s.isRTL;

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Logo
          Center(child: Container(width: 52, height: 52,
            decoration: BoxDecoration(color: RqwstColors.brand, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: RqwstColors.brand.withOpacity(0.3), blurRadius: 16)]),
            child: const Icon(Icons.diamond, color: Colors.white, size: 24))),
          const SizedBox(height: 14),

          // Title
          Text(_isLogin ? s.t('login') : s.t('register'),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),

          // Name field (register only)
          if (!_isLogin) ...[
            _Label(text: s.t('name')),
            TextField(controller: _name,
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(hintText: rtl ? 'الاسم كامل' : 'Full name'),
              style: GoogleFonts.cairo()),
            const SizedBox(height: 12),
          ],

          // Mobile
          _Label(text: s.t('mobile')),
          TextField(controller: _mobile,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(hintText: '01XXXXXXXXX'),
            style: GoogleFonts.cairo()),
          const SizedBox(height: 12),

          // Password
          _Label(text: s.t('password')),
          TextField(
            controller: _pw,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            style: GoogleFonts.cairo(),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 6),

          // Demo hint
          Text(s.t('demoPw'), textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 16),

          // Error
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: RqwstColors.roseL, borderRadius: BorderRadius.circular(12)),
              child: Text(_error!, style: GoogleFonts.cairo(fontSize: 13, color: RqwstColors.rose), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
          ],

          // Submit button
          BrandButton(label: _isLogin ? s.t('login') : s.t('register'), full: true, loading: _loading, onTap: _submit),
          const SizedBox(height: 12),

          // Switch mode
          Center(child: TextButton(
            onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
            child: Text(
              _isLogin
                  ? (rtl ? 'مش عندك حساب؟ سجّل دلوقتي' : "Don't have an account? Register")
                  : (rtl ? 'عندك حساب؟ سجّل دخول' : 'Already have an account? Login'),
              style: GoogleFonts.cairo(fontSize: 13, color: RqwstColors.brand, fontWeight: FontWeight.w600),
            ),
          )),
        ])),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(text, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
  );
}
