import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/app_state.dart';
import '../services/api.dart';
import '../services/location_service.dart';
import '../services/voice_route_service.dart';
import '../utils/theme.dart';
import '../utils/config.dart';
import '../widgets/common.dart';
import 'voice_route_dialog.dart';

// ── Category data ─────────────────────────────────────────────────────────────
// Port of topCats() / otherCats() from app.js
const _topCats = [
  (id: 'توصيل', label: 'توصيل', labelEn: 'Delivery', icon: '🚗', hint: 'وصّل حاجة لحد', hintEn: 'Deliver something'),
  (id: 'مشوار',  label: 'مشوار',  labelEn: 'Errand',   icon: '🏃', hint: 'روّح معاك مكان', hintEn: 'Run an errand'),
];
const _otherCats = [
  (id: 'عام',    label: 'عام',    labelEn: 'General',   icon: '⚡', hint: '', hintEn: ''),
  (id: 'مساعدة', label: 'مساعدة', labelEn: 'Help',      icon: '🤝', hint: '', hintEn: ''),
  (id: 'قانون',  label: 'قانون',  labelEn: 'Legal',     icon: '⚖️', hint: '', hintEn: ''),
  (id: 'طب',     label: 'طب',     labelEn: 'Medical',   icon: '🩺', hint: '', hintEn: ''),
  (id: 'تعليم',  label: 'تعليم',  labelEn: 'Education', icon: '📚', hint: '', hintEn: ''),
  (id: 'صيانة',  label: 'صيانة',  labelEn: 'Repair',    icon: '🔧', hint: '', hintEn: ''),
];

const _deliveryTypes = {'توصيل', 'مشوار'};

const _areas = [
  'مدينة نصر','مصر الجديدة','المعادي','الزمالك','وسط البلد','الهرم',
  'التجمع الخامس','6 أكتوبر','العبور','شبرا','بولاق','الدقي','الجيزة',
  'المنصورة','الإسكندرية','أسيوط','طنطا','الزقازيق','الفيوم',
];

// ── Haversine distance (port of haversineKm from app.js) ─────────────────────
double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = (lng2 - lng1) * math.pi / 180;
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.pow(math.sin(dLng / 2), 2);
  return (r * 2 * math.atan2(math.sqrt(a.toDouble()), math.sqrt(1 - a.toDouble())) * 1.3);
}

// ── Price suggestion (port of suggestDeliveryPrice from app.js) ───────────────
int _suggestPrice(double km) => (15 + km * 8).round();

// ── New request sheet ─────────────────────────────────────────────────────────
class NewRequestSheet extends StatefulWidget {
  const NewRequestSheet({super.key});

  @override
  State<NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends State<NewRequestSheet> {
  int _step = 1;           // 1 = type, 2 = map OR desc, 3 = price/submit
  String _type = '';       // selected category id
  bool _isDelivery = false;// توصيل or مشوار

  // Delivery fields
  final _pickupCtrl  = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  double? _pickupLat, _pickupLng, _dropoffLat, _dropoffLng;
  double _deliveryKm = 0;
  int _suggestedPrice = 0;
  List<Map<String, dynamic>> _pickupSuggestions = [];
  List<Map<String, dynamic>> _dropoffSuggestions = [];
  bool _pickupConfirmed = false;
  bool _dropoffConfirmed = false;

  // General fields
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _area = '';
  bool _shareLocation = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────────────
  void _nextStep() {
    if (_step == 1) {
      if (_type.isEmpty) { _toast('اختار نوع الطلب / Pick a type'); return; }
      setState(() { _isDelivery = _deliveryTypes.contains(_type); _step = 2; });
    } else if (_step == 2) {
      if (_isDelivery) {
        if (_pickupLat == null || _dropoffLat == null) {
          _toast(_isRTL ? 'حدد نقطتي الانطلاق والوصول' : 'Set both pickup & dropoff');
          return;
        }
      } else {
        if (_descCtrl.text.trim().isEmpty) { _toast(_isRTL ? 'أدخل وصف الطلب' : 'Enter description'); return; }
      }
      setState(() => _step = 3);
    }
  }

  void _prevStep() => setState(() => _step--);

  void _selectType(String id) {
    setState(() { _type = id; });
    _nextStep();
  }

  bool get _isRTL => context.read<AppState>().isRTL;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: GoogleFonts.cairo()), duration: const Duration(seconds: 2)));

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final s = context.read<AppState>();
    setState(() { _submitting = true; _error = null; });

    double? lat, lng;
    if (_shareLocation) {
      final pos = await LocationService.getForRequest();
      lat = pos?.lat;
      lng = pos?.lng;
    }

    final params = <String, dynamic>{
      'description': _isDelivery
          ? (_descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : '${_type} - ${_pickupCtrl.text} → ${_dropoffCtrl.text}')
          : _descCtrl.text.trim(),
      'type': _type,
      'area': _area,
      'price': _priceCtrl.text.trim().isNotEmpty ? _priceCtrl.text.trim()
          : (_suggestedPrice > 0 ? _suggestedPrice.toString() : '0'),
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (lat != null) 'share_location': '1',
    };
    if (_isDelivery) {
      params['pickup_address']  = _pickupCtrl.text;
      params['pickup_lat']      = _pickupLat;
      params['pickup_lng']      = _pickupLng;
      params['dropoff_address'] = _dropoffCtrl.text;
      params['dropoff_lat']     = _dropoffLat;
      params['dropoff_lng']     = _dropoffLng;
      params['delivery_km']     = _deliveryKm;
    }

    final err = await s.postRequest(params);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      s.toast(s.isRTL ? 'اتنشر الركوست 🚀' : 'Request posted 🚀', 'success');
    } else {
      setState(() { _error = err; _submitting = false; });
    }
  }

  // ── Nominatim search (free, no API key) ─────────────────────────────────────
  Future<void> _searchPickup(String q) async {
    if (q.trim().length < 2) { setState(() => _pickupSuggestions = []); return; }
    final results = await _nominatimSearch(q);
    if (mounted) setState(() => _pickupSuggestions = results);
  }

  Future<void> _searchDropoff(String q) async {
    if (q.trim().length < 2) { setState(() => _dropoffSuggestions = []); return; }
    final results = await _nominatimSearch(q);
    if (mounted) setState(() => _dropoffSuggestions = results);
  }

  Future<List<Map<String, dynamic>>> _nominatimSearch(String q) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent('$q مصر')}&format=json&limit=5&accept-language=ar&countrycodes=eg');
      final res = await http.get(uri, headers: {'User-Agent': 'RqwstApp/1.0'});
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (_) {}
    return [];
  }

  void _selectPickup(Map<String, dynamic> s) {
    final lat = double.tryParse(s['lat']?.toString() ?? '') ?? 0;
    final lng = double.tryParse(s['lon']?.toString() ?? '') ?? 0;
    final name = (s['display_name'] as String? ?? '').split(',').first;
    setState(() {
      _pickupLat = lat; _pickupLng = lng;
      _pickupCtrl.text = name;
      _pickupConfirmed = true;
      _pickupSuggestions = [];
    });
    _recalcRoute();
  }

  void _selectDropoff(Map<String, dynamic> s) {
    final lat = double.tryParse(s['lat']?.toString() ?? '') ?? 0;
    final lng = double.tryParse(s['lon']?.toString() ?? '') ?? 0;
    final name = (s['display_name'] as String? ?? '').split(',').first;
    setState(() {
      _dropoffLat = lat; _dropoffLng = lng;
      _dropoffCtrl.text = name;
      _dropoffConfirmed = true;
      _dropoffSuggestions = [];
    });
    _recalcRoute();
  }

  void _recalcRoute() {
    if (_pickupLat != null && _dropoffLat != null) {
      final km = _haversineKm(_pickupLat!, _pickupLng!, _dropoffLat!, _dropoffLng!);
      setState(() {
        _deliveryKm = double.parse(km.toStringAsFixed(1));
        _suggestedPrice = _suggestPrice(_deliveryKm);
      });
    }
  }

  void _openVoiceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceRouteDialog(
        currentLat: _pickupLat,
        currentLng: _pickupLng,
        currentAddress: _pickupCtrl.text.isNotEmpty ? _pickupCtrl.text : null,
        onConfirm: ({
          required String pickup, required double pickupLat, required double pickupLng,
          required String dropoff, required double dropoffLat, required double dropoffLng,
        }) {
          setState(() {
            _pickupCtrl.text = pickup;
            _pickupLat = pickupLat; _pickupLng = pickupLng;
            _pickupConfirmed = true;
            _dropoffCtrl.text = dropoff;
            _dropoffLat = dropoffLat; _dropoffLng = dropoffLng;
            _dropoffConfirmed = true;
          });
          _recalcRoute();
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    // Progress: delivery types have 2 steps total, others have 3
    final totalSteps = _isDelivery ? 2 : 3;
    final progress = _step / totalSteps;

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // ── Progress bar (port of the gradient progress bar) ──────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 3,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation(RqwstColors.brand),
                minHeight: 3,
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Column(children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 10),
              Row(children: [
                // Back button
                if (_step > 1)
                  GestureDetector(
                    onTap: _prevStep,
                    child: Container(width: 34, height: 34,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, size: 15)),
                  )
                else
                  const SizedBox(width: 34),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    _step == 1 ? '🎯 ${rtl ? 'نوع الطلب' : 'Request Type'}'
                      : _step == 2 && _isDelivery
                          ? '🗺️ ${_type == 'توصيل' ? (rtl ? 'نقطة الانطلاق والوصول' : 'Pickup & Dropoff') : (rtl ? 'تفاصيل المشوار' : 'Trip Details')}'
                      : _step == 2
                          ? '📝 ${rtl ? 'وصف الطلب' : 'Request Details'}'
                      : '💰 ${rtl ? 'السعر والتفاصيل' : 'Price & Details'}',
                    style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  // Step dots
                  const SizedBox(height: 5),
                  Row(children: List.generate(totalSteps, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: const ElasticOutCurve(0.9),
                    width: _step == i + 1 ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: _step >= i + 1 ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ))),
                ])),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                    child: Center(child: Text('✕', style: GoogleFonts.cairo(fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))))),
                ),
              ]),
            ]),
          ),

          // ── Step content ──────────────────────────────────────────────────────
          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: anim, child: child)),
              child: KeyedSubtree(
                key: ValueKey('step_$_step'),
                child: _step == 1 ? _Step1(rtl: rtl, selectedType: _type, onSelect: _selectType)
                  : _step == 2 && _isDelivery ? _Step2Delivery(
                      rtl: rtl,
                      type: _type,
                      pickupCtrl: _pickupCtrl,
                      dropoffCtrl: _dropoffCtrl,
                      pickupLat: _pickupLat, pickupLng: _pickupLng,
                      dropoffLat: _dropoffLat, dropoffLng: _dropoffLng,
                      pickupConfirmed: _pickupConfirmed,
                      dropoffConfirmed: _dropoffConfirmed,
                      pickupSuggestions: _pickupSuggestions,
                      dropoffSuggestions: _dropoffSuggestions,
                      deliveryKm: _deliveryKm,
                      suggestedPrice: _suggestedPrice,
                      onSearchPickup: _searchPickup,
                      onSearchDropoff: _searchDropoff,
                      onSelectPickup: _selectPickup,
                      onSelectDropoff: _selectDropoff,
                      onClearPickup: () => setState(() {
                        _pickupCtrl.clear(); _pickupLat = null; _pickupLng = null;
                        _pickupConfirmed = false; _deliveryKm = 0; _suggestedPrice = 0; _pickupSuggestions = [];
                      }),
                      onClearDropoff: () => setState(() {
                        _dropoffCtrl.clear(); _dropoffLat = null; _dropoffLng = null;
                        _dropoffConfirmed = false; _deliveryKm = 0; _suggestedPrice = 0; _dropoffSuggestions = [];
                      }),
                      onGetMyLocation: () async {
                        final pos = await LocationService.getForRequest();
                        if (pos == null) return;
                        final res = await _nominatimSearch('${pos.lat},${pos.lng}');
                        if (res.isNotEmpty) {
                          setState(() {
                            _pickupLat = pos.lat; _pickupLng = pos.lng;
                            _pickupCtrl.text = (res.first['display_name'] as String? ?? '').split(',').first;
                            _pickupConfirmed = true;
                          });
                          _recalcRoute();
                        }
                      },
                      onVoiceTap: _openVoiceDialog,
                      onNext: _nextStep,
                    )
                  : _step == 2 ? _Step2General(
                      rtl: rtl,
                      descCtrl: _descCtrl,
                      area: _area,
                      shareLocation: _shareLocation,
                      onAreaTap: () => _showAreaPicker(context, rtl),
                      onShareLocationChanged: (v) => setState(() => _shareLocation = v),
                      onNext: _nextStep,
                    )
                  : _isDelivery ? _Step3Delivery(
                      rtl: rtl,
                      pickup: _pickupCtrl.text,
                      dropoff: _dropoffCtrl.text,
                      deliveryKm: _deliveryKm,
                      suggestedPrice: _suggestedPrice,
                      priceCtrl: _priceCtrl,
                      descCtrl: _descCtrl,
                      area: _area,
                      submitting: _submitting,
                      error: _error,
                      onAreaTap: () => _showAreaPicker(context, rtl),
                      onApplySuggested: () => setState(() => _priceCtrl.text = _suggestedPrice.toString()),
                      onSubmit: _submit,
                    )
                  : _Step3General(
                      rtl: rtl,
                      priceCtrl: _priceCtrl,
                      submitting: _submitting,
                      error: _error,
                      onSkipAndSend: () { _priceCtrl.clear(); _submit(); },
                      onSubmit: _submit,
                    ),
              ),
            ),
          )),
        ]),
      ),
    );
  }

  Future<void> _showAreaPicker(BuildContext context, bool rtl) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AreaPicker(rtl: rtl, selected: _area),
    );
    if (chosen != null) setState(() => _area = chosen);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 1: Type selection
// ══════════════════════════════════════════════════════════════════════════════
class _Step1 extends StatelessWidget {
  final bool rtl;
  final String selectedType;
  final void Function(String) onSelect;
  const _Step1({required this.rtl, required this.selectedType, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Illustration
      Center(child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text('🚗  🏃  ⚡  🤝', style: TextStyle(fontSize: 28, letterSpacing: 8)),
      )),
      Text(rtl ? 'اختار نوع الطلب عشان نساعدك أحسن' : 'Choose type for the best experience',
        style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        textAlign: TextAlign.center),
      const SizedBox(height: 16),

      // ── Top categories — large 2-col cards ────────────────────────────────
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1,
        children: _topCats.map((cat) {
          final selected = selectedType == cat.id;
          return _TopCatCard(
            icon: cat.icon,
            label: rtl ? cat.label : cat.labelEn,
            hint: rtl ? cat.hint : cat.hintEn,
            selected: selected,
            onTap: () => onSelect(cat.id),
          );
        }).toList(),
      ),
      const SizedBox(height: 14),

      // OR divider
      Row(children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(rtl ? 'أو' : 'OR', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)))),
        const Expanded(child: Divider()),
      ]),
      const SizedBox(height: 12),

      // ── Other categories — compact 2-col rows ──────────────────────────────
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 3.0,
        children: _otherCats.map((cat) {
          final selected = selectedType == cat.id;
          return _OtherCatCard(
            icon: cat.icon,
            label: rtl ? cat.label : cat.labelEn,
            selected: selected,
            onTap: () => onSelect(cat.id),
          );
        }).toList(),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

class _TopCatCard extends StatelessWidget {
  final String icon, label, hint;
  final bool selected;
  final VoidCallback onTap;
  const _TopCatCard({required this.icon, required this.label, required this.hint, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? RqwstColors.brandL : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withOpacity(0.1), width: 2),
        boxShadow: selected
            ? [BoxShadow(color: RqwstColors.brand.withOpacity(0.18), blurRadius: 24)]
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900,
          color: selected ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface)),
        if (hint.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(hint, style: GoogleFonts.cairo(fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45)), textAlign: TextAlign.center),
        ],
      ]),
    ),
  );
}

class _OtherCatCard extends StatelessWidget {
  final String icon, label;
  final bool selected;
  final VoidCallback onTap;
  const _OtherCatCard({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? RqwstColors.brandL : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? RqwstColors.brand : Colors.transparent, width: 2),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800,
          color: selected ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface)),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 2 — Delivery/Errand: Pickup + Dropoff search + map placeholder + route
// ══════════════════════════════════════════════════════════════════════════════
class _Step2Delivery extends StatelessWidget {
  final bool rtl;
  final String type;
  final TextEditingController pickupCtrl, dropoffCtrl;
  final double? pickupLat, pickupLng, dropoffLat, dropoffLng;
  final bool pickupConfirmed, dropoffConfirmed;
  final List<Map<String, dynamic>> pickupSuggestions, dropoffSuggestions;
  final double deliveryKm;
  final int suggestedPrice;
  final Future<void> Function(String) onSearchPickup, onSearchDropoff;
  final void Function(Map<String, dynamic>) onSelectPickup, onSelectDropoff;
  final VoidCallback onClearPickup, onClearDropoff, onGetMyLocation, onVoiceTap, onNext;

  const _Step2Delivery({
    required this.rtl, required this.type,
    required this.pickupCtrl, required this.dropoffCtrl,
    this.pickupLat, this.pickupLng, this.dropoffLat, this.dropoffLng,
    required this.pickupConfirmed, required this.dropoffConfirmed,
    required this.pickupSuggestions, required this.dropoffSuggestions,
    required this.deliveryKm, required this.suggestedPrice,
    required this.onSearchPickup, required this.onSearchDropoff,
    required this.onSelectPickup, required this.onSelectDropoff,
    required this.onClearPickup, required this.onClearDropoff,
    required this.onGetMyLocation, required this.onVoiceTap, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bothSet = pickupLat != null && dropoffLat != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // My location button
      GestureDetector(
        onTap: onGetMyLocation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: RqwstColors.brand.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RqwstColors.brand.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.my_location, color: RqwstColors.brand, size: 16),
            const SizedBox(width: 8),
            Text(rtl ? 'استخدم موقعي كنقطة انطلاق' : 'Use my location as pickup',
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: RqwstColors.brand)),
          ]),
        ),
      ),

      // ── Voice route button (AI) ────────────────────────────────────────────
      GestureDetector(
        onTap: onVoiceTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2918), Color(0xFF1A4028), Color(0xFF0F2918)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RqwstColors.brand.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: RqwstColors.brand.withOpacity(0.25), blurRadius: 20)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: RqwstColors.brand,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: RqwstColors.brand.withOpacity(0.4), blurRadius: 10)],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🎤 ${rtl ? 'قول رايح فين' : 'Voice Route'}',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w900,
                  color: const Color(0xFF6EE7B7))),
              Text(rtl ? 'اضغط وقول وجهتك' : 'Tap and say your destination',
                style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600,
                  color: const Color(0x996EE7B7))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [RqwstColors.brand, Color(0xFF22C55E)]),
                borderRadius: BorderRadius.circular(999)),
              child: const Text('AI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                color: Colors.white, letterSpacing: 0.5)),
            ),
          ]),
        ),
      ),

      // ── Pickup + Dropoff combined card ────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          // Pickup row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(children: [
              Container(width: 12, height: 12,
                decoration: BoxDecoration(
                  color: RqwstColors.brand,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: RqwstColors.brand.withOpacity(0.3), blurRadius: 6)],
                )),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: pickupCtrl,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: rtl ? 'نقطة الانطلاق...' : 'Pickup location...',
                  hintStyle: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  border: InputBorder.none, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                onChanged: onSearchPickup,
              )),
              if (pickupCtrl.text.isNotEmpty)
                GestureDetector(onTap: onClearPickup, child: const Icon(Icons.close, size: 16, color: Colors.grey)),
              if (pickupConfirmed)
                Container(margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                  child: const Text('✓', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D)))),
            ]),
          ),

          // Connector line
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              const SizedBox(width: 5),
              Container(width: 1.5, height: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15)),
              const SizedBox(width: 10),
              Expanded(child: Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07))),
            ])),

          // Dropoff row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(children: [
              Container(width: 12, height: 12,
                decoration: BoxDecoration(
                  color: RqwstColors.rose,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: RqwstColors.rose.withOpacity(0.3), blurRadius: 6)],
                )),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: dropoffCtrl,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: rtl ? 'نقطة الوصول...' : 'Dropoff location...',
                  hintStyle: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  border: InputBorder.none, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                onChanged: onSearchDropoff,
              )),
              if (dropoffCtrl.text.isNotEmpty)
                GestureDetector(onTap: onClearDropoff, child: const Icon(Icons.close, size: 16, color: Colors.grey)),
              if (dropoffConfirmed)
                Container(margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                  child: const Text('✓', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D)))),
            ]),
          ),
        ]),
      ),

      // ── Suggestions dropdown ──────────────────────────────────────────────
      if (pickupSuggestions.isNotEmpty) _SuggestionList(
        suggestions: pickupSuggestions,
        color: RqwstColors.brand,
        label: rtl ? 'نقاط الانطلاق المقترحة' : 'PICKUP SUGGESTIONS',
        onSelect: onSelectPickup,
      ),
      if (dropoffSuggestions.isNotEmpty) _SuggestionList(
        suggestions: dropoffSuggestions,
        color: RqwstColors.rose,
        label: rtl ? 'نقاط الوصول المقترحة' : 'DROPOFF SUGGESTIONS',
        onSelect: onSelectDropoff,
      ),

      const SizedBox(height: 14),

      // ── Map placeholder (route visual) ────────────────────────────────────
      if (bothSet)
        _RouteCard(
          pickup: pickupCtrl.text, dropoff: dropoffCtrl.text,
          km: deliveryKm, suggestedPrice: suggestedPrice, rtl: rtl,
          pickupLat: pickupLat, pickupLng: pickupLng,
          dropoffLat: dropoffLat, dropoffLng: dropoffLng,
        )
      else
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07)),
          ),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.map_outlined, size: 36, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25)),
            const SizedBox(height: 8),
            Text(
              pickupLat == null
                  ? (rtl ? 'اكتب نقطة الانطلاق' : 'Enter pickup location')
                  : (rtl ? 'اكتب نقطة الوصول' : 'Enter dropoff location'),
              style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ),
          ])),
        ),

      const SizedBox(height: 16),

      // Next button
      BrandButton(
        label: bothSet
            ? (rtl ? 'التالي — تفاصيل الطلب ←' : 'Next — Request Details →')
            : (rtl ? 'حدد الموقعين أولاً' : 'Set both locations first'),
        full: true,
        onTap: bothSet ? onNext : null,
      ),
    ]);
  }
}

class _SuggestionList extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Color color;
  final String label;
  final void Function(Map<String, dynamic>) onSelect;
  const _SuggestionList({required this.suggestions, required this.color, required this.label, required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)],
    ),
    child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Text(label, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), letterSpacing: 0.5))),
      ...suggestions.take(5).map((s) {
        final name = (s['display_name'] as String? ?? '').split(',');
        return GestureDetector(
          onTap: () => onSelect(s),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06)))),
            child: Row(children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.location_on, color: color, size: 16)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name.first.trim(),
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                if (name.length > 1)
                  Text(name.skip(1).take(2).join('،'),
                    style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45)),
                    overflow: TextOverflow.ellipsis),
              ])),
            ]),
          ),
        );
      }),
    ]),
  );
}

// Route visualization using Google Maps (replaces the static dark card)
class _RouteCard extends StatefulWidget {
  final String pickup, dropoff;
  final double km;
  final int suggestedPrice;
  final bool rtl;
  final double? pickupLat, pickupLng, dropoffLat, dropoffLng;

  const _RouteCard({
    required this.pickup, required this.dropoff,
    required this.km, required this.suggestedPrice, required this.rtl,
    this.pickupLat, this.pickupLng, this.dropoffLat, this.dropoffLng,
  });

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> {
  GoogleMapController? _mapCtrl;

  @override
  void didUpdateWidget(_RouteCard old) {
    super.didUpdateWidget(old);
    if (widget.pickupLat != old.pickupLat || widget.dropoffLat != old.dropoffLat) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    final ctrl = _mapCtrl;
    if (ctrl == null) return;
    if (widget.pickupLat == null || widget.dropoffLat == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(widget.pickupLat!, widget.dropoffLat!),
        math.min(widget.pickupLng!, widget.dropoffLng!)),
      northeast: LatLng(
        math.max(widget.pickupLat!, widget.dropoffLat!),
        math.max(widget.pickupLng!, widget.dropoffLng!)),
    );
    ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};
    if (widget.pickupLat != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.pickupLat!, widget.pickupLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.pickup),
      ));
    }
    if (widget.dropoffLat != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(widget.dropoffLat!, widget.dropoffLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.dropoff),
      ));
    }
    return markers;
  }

  Set<Polyline> get _polylines {
    if (widget.pickupLat == null || widget.dropoffLat == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(widget.pickupLat!, widget.pickupLng!),
          LatLng(widget.dropoffLat!, widget.dropoffLng!),
        ],
        color: RqwstColors.brand,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.pickupLat != null
        ? LatLng(widget.pickupLat!, widget.pickupLng!)
        : const LatLng(30.0444, 31.2357); // Cairo default

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 260,
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: center, zoom: 12),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (c) {
              _mapCtrl = c;
              _fitBounds();
            },
          ),
          // Distance + price overlay at bottom
          if (widget.km > 0)
            Positioned(bottom: 0, left: 0, right: 0, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent]),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999)),
                  child: Text('📏 ${widget.km.toStringAsFixed(1)} ${widget.rtl ? 'كم' : 'km'}',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const Spacer(),
                Text('≈ ${widget.suggestedPrice} ${widget.rtl ? 'ج' : 'EGP'}',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
              ]),
            )),
          // Hint overlay when locations not set
          if (widget.pickupLat == null || widget.dropoffLat == null)
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.touch_app, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.pickupLat == null
                      ? (widget.rtl ? 'اكتب نقطة الانطلاق' : 'Enter pickup above')
                      : (widget.rtl ? 'اكتب نقطة الوصول' : 'Enter dropoff above'),
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 2 — General: Description + Area + share location
// ══════════════════════════════════════════════════════════════════════════════
class _Step2General extends StatelessWidget {
  final bool rtl;
  final TextEditingController descCtrl;
  final String area;
  final bool shareLocation;
  final VoidCallback onAreaTap, onNext;
  final void Function(bool) onShareLocationChanged;
  const _Step2General({required this.rtl, required this.descCtrl, required this.area, required this.shareLocation, required this.onAreaTap, required this.onShareLocationChanged, required this.onNext});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text(rtl ? 'وصف الطلب' : 'Description',
      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
    const SizedBox(height: 6),
    TextField(
      controller: descCtrl,
      maxLines: 4,
      maxLength: 180,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(hintText: rtl ? 'وصف طلبك بالتفصيل…' : 'Describe your request…',
        hintStyle: GoogleFonts.cairo()),
      style: GoogleFonts.cairo(fontSize: 15),
    ),
    const SizedBox(height: 12),

    // Area picker
    Row(children: [
      Text(rtl ? 'المنطقة' : 'Area',
        style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      const SizedBox(width: 10),
      Expanded(child: GestureDetector(
        onTap: onAreaTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: area.isNotEmpty ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withOpacity(0.1), width: 1.5),
          ),
          child: Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: area.isNotEmpty ? RqwstColors.brand : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(area.isNotEmpty ? area : (rtl ? 'اضغط للاختيار' : 'Tap to select'),
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: area.isNotEmpty ? FontWeight.w700 : FontWeight.w400,
                color: area.isNotEmpty ? Theme.of(context).colorScheme.onSurface : Colors.grey))),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          ]),
        ),
      )),
    ]),
    const SizedBox(height: 12),

    // Share location toggle
    GestureDetector(
      onTap: () => onShareLocationChanged(!shareLocation),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.07)),
        ),
        child: Row(children: [
          Checkbox(value: shareLocation, onChanged: (v) => onShareLocationChanged(v ?? false),
            activeColor: RqwstColors.brand),
          const Icon(Icons.location_on, color: RqwstColors.brand, size: 16),
          const SizedBox(width: 8),
          Text(rtl ? 'شارك موقعك مع الطلب' : 'Share location with request',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
    const SizedBox(height: 20),
    BrandButton(label: rtl ? 'التالي ←' : 'Next →', full: true, onTap: onNext),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 3 — Delivery: route summary + price + optional desc + area + submit
// ══════════════════════════════════════════════════════════════════════════════
class _Step3Delivery extends StatelessWidget {
  final bool rtl;
  final String pickup, dropoff, area;
  final double deliveryKm;
  final int suggestedPrice;
  final TextEditingController priceCtrl, descCtrl;
  final bool submitting;
  final String? error;
  final VoidCallback onAreaTap, onApplySuggested, onSubmit;
  const _Step3Delivery({required this.rtl, required this.pickup, required this.dropoff, required this.area, required this.deliveryKm, required this.suggestedPrice, required this.priceCtrl, required this.descCtrl, required this.submitting, this.error, required this.onAreaTap, required this.onApplySuggested, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    // Route summary pill
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RqwstColors.brandL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RqwstColors.brand.withOpacity(0.4), width: 1.5),
      ),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(pickup, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        const Icon(Icons.arrow_forward, size: 14, color: RqwstColors.brand),
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: RqwstColors.rose, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(dropoff, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: RqwstColors.brand, borderRadius: BorderRadius.circular(999)),
          child: Text('${deliveryKm.toStringAsFixed(1)} ${rtl ? 'كم' : 'km'}',
            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ]),
    ),
    const SizedBox(height: 16),

    // Price
    Text('💰 ${rtl ? 'السعر المطلوب' : 'Requested Price'} (${rtl ? 'اختياري' : 'optional'})',
      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
    const SizedBox(height: 6),
    TextField(
      controller: priceCtrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: suggestedPrice > 0 ? suggestedPrice.toString() : '0',
        suffixText: rtl ? 'ج' : 'EGP',
        suffixStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: RqwstColors.brand),
      ),
      style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w900),
    ),
    if (suggestedPrice > 0) ...[
      const SizedBox(height: 6),
      Center(child: GestureDetector(
        onTap: onApplySuggested,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: RqwstColors.brandL, borderRadius: BorderRadius.circular(999)),
          child: Text('${rtl ? 'السعر المقترح' : 'Suggested'}: $suggestedPrice ${rtl ? 'ج' : 'EGP'} ← ${rtl ? 'اضغط للتطبيق' : 'tap to apply'}',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: RqwstColors.brand)),
        ),
      )),
    ],
    const SizedBox(height: 14),

    // Optional desc
    Text(rtl ? 'تفاصيل إضافية (اختياري)' : 'Extra Details (optional)',
      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
    const SizedBox(height: 6),
    TextField(controller: descCtrl, maxLines: 2,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(hintText: rtl ? 'أي تفاصيل إضافية…' : 'Any extra details…', hintStyle: GoogleFonts.cairo()),
      style: GoogleFonts.cairo()),
    const SizedBox(height: 14),

    // Area
    _AreaRow(rtl: rtl, area: area, onTap: onAreaTap),
    const SizedBox(height: 18),

    if (error != null) ...[
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: RqwstColors.roseL, borderRadius: BorderRadius.circular(12)),
        child: Text(error!, style: GoogleFonts.cairo(color: RqwstColors.rose, fontSize: 13))),
      const SizedBox(height: 12),
    ],
    BrandButton(label: rtl ? 'ابعت الركوست 🚀' : 'Post Request 🚀', full: true, loading: submitting, onTap: onSubmit),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
// Step 3 — General: large price input + skip + send
// ══════════════════════════════════════════════════════════════════════════════
class _Step3General extends StatelessWidget {
  final bool rtl;
  final TextEditingController priceCtrl;
  final bool submitting;
  final String? error;
  final VoidCallback onSkipAndSend, onSubmit;
  const _Step3General({required this.rtl, required this.priceCtrl, required this.submitting, this.error, required this.onSkipAndSend, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    // Coin illustration
    Center(child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        const Text('💰', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 6),
        Text(rtl ? 'حدد سعرك أو اتركه مفتوح للعروض' : 'Set your price or leave open for bids',
          style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        const SizedBox(height: 6),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(color: RqwstColors.brandL, borderRadius: BorderRadius.circular(999)),
          child: Text(rtl ? 'اختياري' : 'Optional',
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: RqwstColors.brand))),
      ]),
    )),

    // Big price input
    Center(child: SizedBox(width: 200,
      child: TextField(
        controller: priceCtrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0',
          suffixText: rtl ? 'ج' : 'EGP',
          suffixStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: RqwstColors.brand),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: RqwstColors.brand, width: 2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: RqwstColors.brand, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: RqwstColors.brand, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        style: GoogleFonts.cairo(fontSize: 38, fontWeight: FontWeight.w900),
      ),
    )),
    const SizedBox(height: 20),

    if (error != null) ...[
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: RqwstColors.roseL, borderRadius: BorderRadius.circular(12)),
        child: Text(error!, style: GoogleFonts.cairo(color: RqwstColors.rose, fontSize: 13))),
      const SizedBox(height: 12),
    ],

    Row(children: [
      Expanded(child: BrandButton(label: rtl ? 'تخطي وإرسال' : 'Skip & Send', ghost: true, loading: submitting, onTap: onSkipAndSend)),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: BrandButton(label: rtl ? 'ابعت الركوست 🚀' : 'Post Request 🚀', loading: submitting, onTap: onSubmit)),
    ]),
  ]);
}

// ── Area row widget ───────────────────────────────────────────────────────────
class _AreaRow extends StatelessWidget {
  final bool rtl;
  final String area;
  final VoidCallback onTap;
  const _AreaRow({required this.rtl, required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(rtl ? 'المنطقة' : 'Area',
      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
    const SizedBox(width: 10),
    Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: area.isNotEmpty ? RqwstColors.brand : Colors.transparent, width: 1.5),
        ),
        child: Row(children: [
          Icon(Icons.location_on_outlined, size: 13, color: area.isNotEmpty ? RqwstColors.brand : Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(area.isNotEmpty ? area : (rtl ? 'اضغط للاختيار' : 'Tap to select'),
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: area.isNotEmpty ? FontWeight.w700 : FontWeight.w400,
              color: area.isNotEmpty ? Theme.of(context).colorScheme.onSurface : Colors.grey))),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ]),
      ),
    )),
  ]);
}

// ── Area picker bottom sheet ──────────────────────────────────────────────────
class _AreaPicker extends StatelessWidget {
  final bool rtl;
  final String selected;
  const _AreaPicker({required this.rtl, required this.selected});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
      Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(rtl ? 'اختار المنطقة' : 'Choose Area',
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900))),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: _areas.map((a) => GestureDetector(
          onTap: () => Navigator.pop(context, a),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected == a ? RqwstColors.brandL : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected == a ? RqwstColors.brand : Colors.transparent, width: 1.5),
            ),
            child: Row(children: [
              Icon(Icons.location_on_outlined, size: 16, color: selected == a ? RqwstColors.brand : Colors.grey),
              const SizedBox(width: 10),
              Text(a, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600,
                color: selected == a ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              if (selected == a) const Icon(Icons.check, size: 16, color: RqwstColors.brand),
            ]),
          ),
        )).toList(),
      )),
    ]),
  );
}
