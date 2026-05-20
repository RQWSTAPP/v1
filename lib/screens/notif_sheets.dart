import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/api.dart';
import '../services/push_service.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';

// ── In-app notification model ──────────────────────────────────────────────────
class AppNotif {
  final String id, title, body, time;
  bool read;
  final Map<String, dynamic>? action;
  AppNotif({required this.id, required this.title, required this.body, required this.time, this.read = false, this.action});
}

// ── Notification center sheet ─────────────────────────────────────────────────
// Port of S.overlay === 'notifs'
class NotifSheet extends StatefulWidget {
  final List<AppNotif> notifs;
  final String notifPerm;       // 'default'|'granted'|'denied'
  final bool rtl;
  final void Function() onMarkAllRead;
  final void Function(AppNotif) onTap;

  const NotifSheet({
    super.key,
    required this.notifs,
    required this.notifPerm,
    required this.rtl,
    required this.onMarkAllRead,
    required this.onTap,
  });

  @override
  State<NotifSheet> createState() => _NotifSheetState();
}

class _NotifSheetState extends State<NotifSheet> {
  String _perm = '';
  bool _enabling = false;

  @override
  void initState() {
    super.initState();
    _perm = widget.notifPerm;
  }

  Future<void> _enablePush() async {
    setState(() => _enabling = true);
    final result = await PushService.requestPermission();
    if (mounted) setState(() { _perm = result; _enabling = false; });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = widget.rtl;
    final unread = widget.notifs.where((n) => !n.read).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2)))),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              const Icon(Icons.notifications_outlined, size: 18),
              const SizedBox(width: 8),
              Text(rtl ? 'الإشعارات' : 'Notifications',
                style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                StatusPill(label: '$unread', color: 'red'),
              ],
              const Spacer(),
              TextButton(
                onPressed: widget.onMarkAllRead,
                child: Text(rtl ? 'تعليم الكل مقروء' : 'Mark all read',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),

          // List
          Expanded(child: widget.notifs.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.notifications_none, size: 44, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(rtl ? 'مفيش إشعارات لحد دلوقتي' : 'No notifications yet',
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey)),
                ]))
              : ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.notifs.length,
                  itemBuilder: (_, i) {
                    final n = widget.notifs[i];
                    return GestureDetector(
                      onTap: () => widget.onTap(n),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.read
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : RqwstColors.brandL,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: n.read
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.07)
                                : RqwstColors.brand.withOpacity(0.2)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(n.body, style: GoogleFonts.cairo(fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(n.time, style: GoogleFonts.cairo(fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                            if (!n.read) ...[
                              const SizedBox(height: 6),
                              Container(width: 7, height: 7,
                                decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
                            ],
                          ]),
                        ]),
                      ),
                    );
                  },
                )),

          // Push permission row
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07))),
              child: Row(children: [
                const Icon(Icons.notifications_outlined, size: 14),
                const SizedBox(width: 7),
                Expanded(child: Text(
                  _perm == 'granted'
                      ? (rtl ? 'الإشعارات مفعّلة ✓' : 'Notifications enabled ✓')
                      : _perm == 'denied'
                          ? (rtl ? 'الإشعارات متوقفة' : 'Notifications blocked')
                          : (rtl ? 'فعّل الإشعارات' : 'Enable Notifications'),
                  style: GoogleFonts.cairo(fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
                if (_perm == 'granted')
                  Text('✓', style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w800))
                else if (_perm == 'denied')
                  Text(rtl ? 'مغلق من الإعدادات' : 'Blocked in settings',
                    style: GoogleFonts.cairo(fontSize: 12, color: RqwstColors.rose))
                else
                  TextButton(
                    onPressed: _enabling ? null : _enablePush,
                    child: _enabling
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(rtl ? 'فعّل' : 'Enable',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: RqwstColors.brand)),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Edit name sheet ────────────────────────────────────────────────────────────
// Port of S.overlay === 'editName'
class EditNameSheet extends StatefulWidget {
  final String currentName;
  const EditNameSheet({super.key, required this.currentName});

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {
  late TextEditingController _ctrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final s = context.read<AppState>();
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService.call('user.update_name', {'name': name});
      // Reload user
      await s.loadMyReqs(); // triggers user reload
      if (mounted) {
        Navigator.pop(context);
        s.toast(s.isRTL ? 'تم تغيير الاسم ✓' : 'Name updated ✓', 'success');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final rtl = s.isRTL;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('✏️ ${rtl ? 'تغيير الاسم' : 'Edit Name'}',
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Text(rtl ? 'الاسم الجديد' : 'New Name',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: rtl ? 'اكتب اسمك الجديد' : 'Enter new name',
              hintStyle: GoogleFonts.cairo()),
            style: GoogleFonts.cairo(),
            autofocus: true,
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.cairo(fontSize: 13, color: RqwstColors.rose)),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: BrandButton(label: s.t('cancel'), ghost: true, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: BrandButton(
              label: rtl ? 'حفظ' : 'Save',
              loading: _saving,
              onTap: _save,
            )),
          ]),
        ]),
      ),
    );
  }
}

// ── Change password sheet ──────────────────────────────────────────────────────
// Port of S.overlay === 'changePw'
class ChangePwSheet extends StatefulWidget {
  const ChangePwSheet({super.key});

  @override
  State<ChangePwSheet> createState() => _ChangePwSheetState();
}

class _ChangePwSheetState extends State<ChangePwSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  String? _error;
  bool _obscure1 = true, _obscure2 = true, _obscure3 = true;

  @override
  void dispose() { _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = rtl ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match');
      return;
    }
    if (_newCtrl.text.length < 6) {
      setState(() => _error = rtl ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : 'Min 6 characters');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService.call('user.change_password', {
        'current': _currentCtrl.text,
        'new': _newCtrl.text,
      });
      if (mounted) {
        Navigator.pop(context);
        s.toast(rtl ? 'تم تغيير كلمة المرور ✓' : 'Password changed ✓', 'success');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final rtl = s.isRTL;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('🔑 ${rtl ? 'تغيير كلمة المرور' : 'Change Password'}',
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _PwField(ctrl: _currentCtrl, label: rtl ? 'كلمة المرور الحالية' : 'Current Password',
            hint: rtl ? 'كلمة المرور الحالية' : 'Current password',
            obscure: _obscure1, onToggle: () => setState(() => _obscure1 = !_obscure1)),
          const SizedBox(height: 10),
          _PwField(ctrl: _newCtrl, label: rtl ? 'كلمة المرور الجديدة' : 'New Password',
            hint: rtl ? '6 أحرف على الأقل' : 'Min 6 characters',
            obscure: _obscure2, onToggle: () => setState(() => _obscure2 = !_obscure2)),
          const SizedBox(height: 10),
          _PwField(ctrl: _confirmCtrl, label: rtl ? 'تأكيد كلمة المرور' : 'Confirm Password',
            hint: rtl ? 'أعد كتابة كلمة المرور' : 'Repeat new password',
            obscure: _obscure3, onToggle: () => setState(() => _obscure3 = !_obscure3),
            onSubmit: _save),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: RqwstColors.roseL, borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: GoogleFonts.cairo(fontSize: 13, color: RqwstColors.rose))),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: BrandButton(label: s.t('cancel'), ghost: true, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: BrandButton(
              label: rtl ? 'تغيير' : 'Change',
              loading: _saving,
              onTap: _save,
            )),
          ]),
        ]),
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback? onSubmit;
  const _PwField({required this.ctrl, required this.label, required this.hint, required this.obscure, required this.onToggle, this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
    const SizedBox(height: 5),
    TextField(
      controller: ctrl, obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.cairo(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
          onPressed: onToggle)),
      style: GoogleFonts.cairo(),
      onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
    ),
  ]);
}
