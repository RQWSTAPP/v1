import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

// ── Voice state ────────────────────────────────────────────────────────────────
enum VoiceRouteState { idle, recording, processing, result, error }

class VoiceRouteResult {
  final String transcript;
  final String pickup;
  final String dropoff;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? errorMsg;

  const VoiceRouteResult({
    this.transcript = '',
    this.pickup = '',
    this.dropoff = '',
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.errorMsg,
  });

  bool get pickupFound => pickupLat != null && pickupLng != null;
  bool get dropoffFound => dropoffLat != null && dropoffLng != null;
}

// ── Route patterns — direct port of ROUTE_PATTERNS from app.js ────────────────
// Pattern 1: من X لـ/إلى/لحد Y  (from X to Y)
final _pat1 = RegExp(
    r'(?:من|من عند|من هنا|خد من)\s+(.+?)\s+(?:لـ|ل |إلى|الى|لحد|وروح|ووديني|ووديني ل)\s+(.+?)$',
    unicode: true);

// Pattern 2: روح/وديني/ايصلني X  (dropoff only)
final _pat2 = RegExp(
    r'(?:روح|وديني|ايصلني|خدني|ودني)\s+(?:لـ|ل |إلى|الى)?\s*(.+?)$',
    unicode: true);

// Pattern 3: رايح X  (dropoff only)
final _pat3 = RegExp(
    r'(?:رايح|رايح لـ|رايح إلى|رايح الى)\s+(.+?)$',
    unicode: true);

// Pattern 4: X لـ Y  (generic)
final _pat4 = RegExp(
    r'^(.+?)\s+(?:لـ|ل |إلى|الى|لحد)\s+(.+?)$',
    unicode: true);

// ── Filler word cleaner — port of clean() from app.js ────────────────────────
String _clean(String t) {
  return t
      .replaceFirst(RegExp(r'^(في|ف|بـ|هنا|عندي|عند)\s+', unicode: true), '')
      .replaceFirst(RegExp(r'\s+(بتاعي|ده|دي)$', unicode: true), '')
      .trim();
}

// ── Voice route example sentences shown in the dialog ─────────────────────────
const voiceExamples = [
  'رايح من المعادي لـ مول العرب',
  'روح مطار القاهرة',
  'خد من الزمالك ووديني مدينة نصر',
  'رايح مول مصر في 6 أكتوبر',
  'من هنا لـ شارع التحرير وسط البلد',
];

// ── Voice route service ────────────────────────────────────────────────────────
class VoiceRouteService {
  static final SpeechToText _speech = SpeechToText();
  static bool _initialized = false;

  static VoiceRouteState state = VoiceRouteState.idle;
  static String transcript = '';
  static VoiceRouteResult? result;
  static Function()? onStateChanged;

  // ── Init ──────────────────────────────────────────────────────────────────────
  static Future<bool> init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (state == VoiceRouteState.recording) {
            state = VoiceRouteState.processing;
            onStateChanged?.call();
            _parse(transcript);
          }
        }
      },
      onError: (e) {
        state = VoiceRouteState.error;
        result = VoiceRouteResult(
          errorMsg: e.errorMsg == 'not-allowed' ? 'اسمح بالوصول للميكروفون' : 'حصل خطأ في التسجيل',
        );
        onStateChanged?.call();
      },
    );
    return _initialized;
  }

  // ── Start recording — port of startVoiceRecording() ───────────────────────────
  static Future<void> startRecording() async {
    final ok = await init();
    if (!ok) {
      state = VoiceRouteState.error;
      result = VoiceRouteResult(errorMsg: 'المتصفح لا يدعم التسجيل الصوتي');
      onStateChanged?.call();
      return;
    }

    state = VoiceRouteState.recording;
    transcript = '';
    result = null;
    onStateChanged?.call();

    await _speech.listen(
      localeId: 'ar_EG',   // ar-EG — same as original _voiceRecog.lang='ar-EG'
      listenMode: ListenMode.confirmation,
      onResult: (r) {
        transcript = r.recognizedWords;
        onStateChanged?.call();
      },
      cancelOnError: false,
      partialResults: true,
    );
  }

  // ── Stop — port of stopVoiceRecording() ───────────────────────────────────────
  static Future<void> stopRecording() async {
    await _speech.stop();
    state = VoiceRouteState.processing;
    onStateChanged?.call();
    await _parse(transcript);
  }

  static void reset() {
    _speech.cancel();
    state = VoiceRouteState.idle;
    transcript = '';
    result = null;
    onStateChanged?.call();
  }

  // ── Parse — port of parseVoiceRoute(text) ────────────────────────────────────
  static Future<void> _parse(String text) async {
    if (text.trim().isEmpty) {
      state = VoiceRouteState.error;
      result = VoiceRouteResult(errorMsg: 'لم يتم التعرف على الصوت');
      onStateChanged?.call();
      return;
    }

    String pickup = '';
    String dropoff = '';

    // Try patterns in order — exact port of ROUTE_PATTERNS loop
    final t = text.trim();

    Match? m;
    if ((m = _pat1.firstMatch(t)) != null) {
      pickup  = _clean(m!.group(1) ?? '');
      dropoff = _clean(m.group(2) ?? '');
    } else if ((m = _pat2.firstMatch(t)) != null) {
      dropoff = _clean(m!.group(1) ?? '');
    } else if ((m = _pat3.firstMatch(t)) != null) {
      dropoff = _clean(m!.group(1) ?? '');
    } else if ((m = _pat4.firstMatch(t)) != null) {
      pickup  = _clean(m!.group(1) ?? '');
      dropoff = _clean(m.group(2) ?? '');
    } else {
      // Entire phrase treated as dropoff
      dropoff = _clean(t);
    }

    // Search both locations — Google Places first, Nominatim fallback
    double? pLat, pLng, dLat, dLng;
    String pName = pickup, dName = dropoff;

    if (pickup.isNotEmpty) {
      final r = await _searchPlace(pickup);
      if (r != null) { pLat = r.$1; pLng = r.$2; pName = r.$3; }
    }
    if (dropoff.isNotEmpty) {
      final r = await _searchPlace(dropoff);
      if (r != null) { dLat = r.$1; dLng = r.$2; dName = r.$3; }
    }

    state = VoiceRouteState.result;
    result = VoiceRouteResult(
      transcript: text,
      pickup: pName,
      dropoff: dName,
      pickupLat: pLat,
      pickupLng: pLng,
      dropoffLat: dLat,
      dropoffLng: dLng,
    );
    onStateChanged?.call();
  }

  // ── Search a place — Google Places first, Nominatim fallback ─────────────────
  static Future<(double, double, String)?> _searchPlace(String query) async {
    // Try Google Places Autocomplete + Details (uses the same key as the web app)
    final googleResult = await _googlePlaces(query, AppConfig.googleMapsApiKey);
    if (googleResult != null) return googleResult;
    // Fallback: Nominatim (free, no key needed)
    return await _nominatim(query);
  }

  // ── Nominatim fallback ─────────────────────────────────────────────────────────
  static Future<(double, double, String)?> _nominatim(String query) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent('$query مصر')}&format=json&limit=1&accept-language=ar&countrycodes=eg');
      final res = await http.get(uri, headers: {'User-Agent': 'RqwstApp/1.0'})
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          final item = data.first as Map<String, dynamic>;
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lng = double.tryParse(item['lon']?.toString() ?? '');
          final name = (item['display_name'] as String? ?? query).split(',').first.trim();
          if (lat != null && lng != null) return (lat, lng, name);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Google Places geocoding via server.php proxy ──────────────────────────────
  // The server.php can expose a places.search action to keep the API key server-side
  static Future<(double, double, String)?> _googlePlaces(String query, String apiKey) async {
    try {
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&components=country:eg&language=ar&key=$apiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final predictions = data['predictions'] as List?;
        if (predictions != null && predictions.isNotEmpty) {
          final placeId = predictions.first['place_id'] as String?;
          if (placeId != null) {
            final details = await _googlePlaceDetails(placeId, apiKey);
            return details;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<(double, double, String)?> _googlePlaceDetails(String placeId, String apiKey) async {
    try {
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,geometry&language=ar&key=$apiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;
        if (result != null) {
          final loc = result['geometry']?['location'] as Map<String, dynamic>?;
          final name = result['name'] as String? ?? '';
          final lat = (loc?['lat'] as num?)?.toDouble();
          final lng = (loc?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) return (lat, lng, name);
        }
      }
    } catch (_) {}
    return null;
  }
}
