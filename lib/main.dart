// RQWST Flutter — Single File
// 9000+ lines, all screens + services

import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Directory;
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';


// ============================================================
// SOURCE: lib/utils/theme.dart
// ============================================================


// ── Brand colors (direct port of CSS variables) ───────────────────────────────
class RqwstColors {
  static const brand    = Color(0xFF35B54B);
  static const brand2   = Color(0xFF22913A);
  static const brandL   = Color(0x2435B54B); // rgba(53,181,75,.14)
  static const sky      = Color(0xFF0EA5E9);
  static const skyL     = Color(0x1F0EA5E9);
  static const amber    = Color(0xFFF59E0B);
  static const amberL   = Color(0x1FF59E0B);
  static const rose     = Color(0xFFF43F5E);
  static const roseL    = Color(0x1FF43F5E);
  static const slate    = Color(0xFF64748B);
  static const slateL   = Color(0x1A64748B);
  static const invert   = Color(0xFF6366F1);
  static const invertL  = Color(0x1A6366F1);
}

// ── Light theme ───────────────────────────────────────────────────────────────
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: RqwstColors.brand,
    secondary: RqwstColors.invert,
    surface: const Color(0xFFFFFFFF),
    surfaceContainerHighest: const Color(0xFFF1F5F9),
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  textTheme: GoogleFonts.cairoTextTheme().apply(
    bodyColor: const Color(0xFF0F172A),
    displayColor: const Color(0xFF0F172A),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0x120F172A)),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x120F172A), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x120F172A), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: RqwstColors.brand, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RqwstColors.brand,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: RqwstColors.brandL,
    labelTextStyle: WidgetStateProperty.resolveWith((s) =>
      GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700)),
  ),
);

// ── Dark theme ────────────────────────────────────────────────────────────────
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: RqwstColors.brand,
    secondary: RqwstColors.invert,
    surface: const Color(0xFF111827),
    surfaceContainerHighest: const Color(0xFF1E2840),
  ),
  scaffoldBackgroundColor: const Color(0xFF0A0F1E),
  textTheme: GoogleFonts.cairoTextTheme().apply(
    bodyColor: const Color(0xFFF0F6FF),
    displayColor: const Color(0xFFF0F6FF),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF111827),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0x0FFFFFFF)),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2840),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x0FFFFFFF), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x0FFFFFFF), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: RqwstColors.brand, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RqwstColors.brand,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF111827),
    indicatorColor: RqwstColors.brandL,
    labelTextStyle: WidgetStateProperty.resolveWith((s) =>
      GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700)),
  ),
);


// ============================================================
// SOURCE: lib/utils/config.dart
// ============================================================

class AppConfig {
  static const googleMapsApiKey = 'AIzaSyBTtJz6qY4IaEvwGG01gM-BgaxH2oNmTzQ';
  static const serverUrl = 'https://rqwst.app/server.php';
}


// ============================================================
// SOURCE: lib/utils/i18n.dart
// ============================================================

// Direct port of the L = { ar: {...}, en: {...} } object from app.js
class L {
  static const Map<String, Map<String, String>> _strings = {
    'ar': {
      'appName': 'ركوست',
      'home': 'الرئيسية',
      'tasks': 'ركوستاتي',
      'chat': 'شات',
      'wallet': 'محفظة',
      'profile': 'حسابي',
      'login': 'دخول',
      'register': 'تسجيل',
      'logout': 'خروج',
      'name': 'الاسم',
      'mobile': 'الموبايل',
      'password': 'الباسورد',
      'newReq': 'ركوست جديد',
      'postReq': 'ابعت الركوست 🚀',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'back': 'رجوع',
      'price': 'السعر (جنيه)',
      'area': 'المنطقة',
      'descPlaceholder': 'وصف طلبك بالتفصيل…',
      'noRequests': 'مفيش ركوستات لحد دلوقتي',
      'noThreads': 'مفيش محادثات',
      'accept': 'قبول',
      'reject': 'رفض',
      'complete': 'أنهي الطلب',
      'offers': 'عروض',
      'providerMode': 'وضع مزود',
      'requesterMode': 'وضع طالب',
      'available': 'متاح الآن',
      'unavailable': 'غير متاح',
      'nearbyReqs': 'ركوستات قريبة',
      'makeOffer': 'قدم عرض',
      'acceptReq': 'اقبل بالسعر',
      'typeMsg': 'اكتب رسالة…',
      'bidding': 'مستني عروض',
      'accepted': 'قيد التنفيذ',
      'completed': 'مكتمل ✅',
      'cancelled': 'ملغي ❌',
      'egp': 'ج',
      'installApp': 'ثبّت التطبيق',
      'offerPrice': 'سعر عرضك',
      'submitOffer': 'ابعت العرض',
      'noOffers': 'مفيش عروض لسه',
      'otherParty': 'مستنيين الطرف التاني',
      'balance': 'رصيد',
      'earned': 'مكسب',
      'verified': '✓ موثق',
      'type': 'النوع',
      'demoLogin': 'دخول تجريبي',
      'demoPw': 'كلمة المرور: demo',
      'shareLocation': 'شارك موقعك',
      'alreadyActive': 'عندك طلب نشط بالفعل',
      'submitRating': 'سيب تقييم',
      'openChat': 'افتح الشات',
      'markDone': 'خلّصت',
      'reqType_general': 'عام',
      'reqType_errand': 'مشوار',
      'reqType_help': 'مساعدة',
      'reqType_delivery': 'توصيل',
      'reqType_legal': 'قانون',
      'providerAvailableHint': 'فعّل وضع المزود علشان تقدر تقبل طلبات',
      'requestFlow1': 'اكتب الطلب',
      'requestFlow2': 'مزودون يشوفوه',
      'requestFlow3': 'قبول واتفاق',
      'calling': 'جاري الاتصال…',
      'incomingCall': 'مكالمة واردة',
      'inCall': 'متصل الآن',
      'endCall': 'إنهاء',
      'answerCall': 'رد',
      'rejectCall': 'رفض',
      'callEnded': 'انتهت المكالمة',
      'micBlocked': 'افتح صلاحية الميكروفون وجرب تاني',
      'voiceNote': 'رسالة صوتية',
      'recording': 'جاري التسجيل…',
      'stopRec': 'إيقاف',
      'sendVoice': 'إرسال الصوت',
      'deleteVoice': 'حذف',
      'searching': 'بنبحثلك عن مزود…',
      'gotOffers': 'عندك عروض!',
      'inProgress': 'قيد التنفيذ',
      'timeLeft': 'الوقت المتبقي',
      'viewOffers': 'شوف العروض',
      'cancelReq': 'إلغاء الطلب',
      'requestExpired': 'انتهت مهلة الطلب',
      'repost': 'إعادة نشر',
      'providerAccepted': 'مزود قبل طلبك!',
      'openChatNow': 'افتح الشات دلوقتي',
      'stagePosted': 'نشرت',
      'stageBidding': 'عروض',
      'stageAccepted': 'اتفاق',
      'stageDone': 'تمام',
      'pushEnable': 'فعّل الإشعارات',
      'pushEnabled': 'الإشعارات مفعّلة ✓',
      'pushBlocked': 'الإشعارات متوقفة',
      'newOfferNotif': 'عرض جديد على طلبك!',
      'chatMsgNotif': 'رسالة جديدة',
      'reqAcceptedNotif': 'مزود قبل طلبك!',
      'hello': 'أهلاً،',
      'requestAnything': 'اطلب أي حاجة',
      'howItWorks': 'إزاي بيشتغل؟',
      'becomeProvider': 'كن مزود خدمة واكسب فلوس',
      'startAsProvider': 'ابدأ كمزود دلوقتي',
      'loginRequired': 'سجّل دخولك الأول',
      'noNearbyReqs': 'مفيش ركوستات قريبة',
      'contactSupport': 'تواصل مع الدعم',
      'reportProblem': 'بلّغ عن مشكلة أو اسأل سؤال',
      'problemOrQuestion': 'مشكلة أو سؤال؟',
      'betaBadge': 'تجريبي',
      'tapPhotoToChange': 'اضغط على الصورة لتغييرها',
      'completedReqs': 'طلبات مكتملة',
      'asRequester': 'كطالب خدمة',
      'delivered': 'طلبات نفذتها',
      'asProvider': 'كمزود خدمة',
      'avgRating': 'متوسط التقييم',
      'reviews': 'تقييم',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'editName': 'تغيير الاسم',
      'changePassword': 'تغيير كلمة المرور',
      'identityVerification': 'التوثيق والهوية',
      'deliverySettings': 'إعدادات التوصيل',
      'acceptDelivery': 'متاح لطلبات التوصيل',
      'vehicleType': 'نوع المركبة',
      'make': 'الماركة',
      'model': 'الموديل',
      'year': 'سنة الصنع',
      'plateNumber': 'رقم اللوحة',
      'vehiclePhotos': 'صور المركبة',
      'acceptedPayments': 'طرق الدفع المقبولة',
      'saveVehicle': 'حفظ بيانات المركبة',
      'upload': 'رفع',
      'new': 'جديد',
    },
    'en': {
      'appName': 'Rqwst',
      'home': 'Home',
      'tasks': 'My Rqwsts',
      'chat': 'Chat',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'name': 'Name',
      'mobile': 'Mobile',
      'password': 'Password',
      'newReq': 'New Request',
      'postReq': 'Post Request 🚀',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'back': 'Back',
      'price': 'Price (EGP)',
      'area': 'Area',
      'descPlaceholder': 'Describe your request…',
      'noRequests': 'No requests yet',
      'noThreads': 'No conversations yet',
      'accept': 'Accept',
      'reject': 'Reject',
      'complete': 'Mark Complete',
      'offers': 'Offers',
      'providerMode': 'Provider Mode',
      'requesterMode': 'Requester Mode',
      'available': 'Available Now',
      'unavailable': 'Unavailable',
      'nearbyReqs': 'Nearby Requests',
      'makeOffer': 'Make Offer',
      'acceptReq': 'Accept at Price',
      'typeMsg': 'Type a message…',
      'bidding': 'Awaiting offers',
      'accepted': 'In Progress',
      'completed': 'Completed ✅',
      'cancelled': 'Cancelled ❌',
      'egp': 'EGP',
      'installApp': 'Install App',
      'offerPrice': 'Your Offer Price',
      'submitOffer': 'Submit Offer',
      'noOffers': 'No offers yet',
      'otherParty': 'Waiting for other party',
      'balance': 'Balance',
      'earned': 'Earned',
      'verified': '✓ Verified',
      'type': 'Type',
      'demoLogin': 'Demo Login',
      'demoPw': 'Password: demo',
      'shareLocation': 'Share Location',
      'alreadyActive': 'You have an active request already',
      'submitRating': 'Submit Rating',
      'openChat': 'Open Chat',
      'markDone': 'Done',
      'reqType_general': 'General',
      'reqType_errand': 'Errand',
      'reqType_help': 'Help',
      'reqType_delivery': 'Delivery',
      'reqType_legal': 'Legal',
      'providerAvailableHint': 'Enable Provider Mode to accept requests',
      'requestFlow1': 'Post Request',
      'requestFlow2': 'Providers See It',
      'requestFlow3': 'Accept & Chat',
      'calling': 'Calling…',
      'incomingCall': 'Incoming Call',
      'inCall': 'Connected',
      'endCall': 'End',
      'answerCall': 'Answer',
      'rejectCall': 'Reject',
      'callEnded': 'Call ended',
      'micBlocked': 'Allow microphone access and try again',
      'voiceNote': 'Voice Note',
      'recording': 'Recording…',
      'stopRec': 'Stop',
      'sendVoice': 'Send Voice',
      'deleteVoice': 'Delete',
      'searching': 'Looking for a provider…',
      'gotOffers': 'You have offers!',
      'inProgress': 'In Progress',
      'timeLeft': 'Time left',
      'viewOffers': 'View Offers',
      'cancelReq': 'Cancel Request',
      'requestExpired': 'Request expired',
      'repost': 'Repost',
      'providerAccepted': 'Provider accepted!',
      'openChatNow': 'Open Chat Now',
      'stagePosted': 'Posted',
      'stageBidding': 'Offers',
      'stageAccepted': 'Agreed',
      'stageDone': 'Done',
      'pushEnable': 'Enable Notifications',
      'pushEnabled': 'Notifications enabled ✓',
      'pushBlocked': 'Notifications blocked',
      'newOfferNotif': 'New offer on your request!',
      'chatMsgNotif': 'New message',
      'reqAcceptedNotif': 'Provider accepted your request!',
      'hello': '',
      'requestAnything': 'Request anything',
      'howItWorks': 'How it works',
      'becomeProvider': 'Become a provider & earn',
      'startAsProvider': 'Start as a provider',
      'loginRequired': 'Login required',
      'noNearbyReqs': 'No nearby requests',
      'contactSupport': 'Contact Support',
      'reportProblem': 'Report a problem or ask a question',
      'problemOrQuestion': 'Problem or question?',
      'betaBadge': 'BETA',
      'tapPhotoToChange': 'Tap photo to change',
      'completedReqs': 'Completed',
      'asRequester': 'as requester',
      'delivered': 'Delivered',
      'asProvider': 'as provider',
      'avgRating': 'Avg Rating',
      'reviews': 'reviews',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'editName': 'Edit Name',
      'changePassword': 'Change Password',
      'identityVerification': 'Identity & Verification',
      'deliverySettings': 'Delivery Settings',
      'acceptDelivery': 'Accept Delivery Requests',
      'vehicleType': 'Vehicle Type',
      'make': 'Make',
      'model': 'Model',
      'year': 'Manufacturing Year',
      'plateNumber': 'Plate Number',
      'vehiclePhotos': 'Vehicle Photos',
      'acceptedPayments': 'Accepted Payment Methods',
      'saveVehicle': 'Save Vehicle Info',
      'upload': 'Upload',
      'new': 'New',
    },
  };

  static String get(String key, String lang) =>
      _strings[lang]?[key] ?? _strings['ar']![key] ?? key;
}


// ============================================================
// SOURCE: lib/services/api.dart
// ============================================================


class ApiService {
  static const _baseUrl = AppConfig.serverUrl;
  static String? token;

  /// Direct port of the api(action, data, files) function from app.js
  static Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> data = const {},
    Map<String, List<int>>? fileBytes,
    Map<String, String>? fileNames,
  ]) async {
    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['action'] = action;
    if (token != null) request.fields['token'] = token!;

    data.forEach((k, v) {
      if (v != null) request.fields[k] = v.toString();
    });

    if (fileBytes != null) {
      fileBytes.forEach((k, bytes) {
        request.files.add(http.MultipartFile.fromBytes(
          k,
          bytes,
          filename: fileNames?[k] ?? k,
        ));
      });
    }

    final streamed = await request.send().timeout(const Duration(seconds: 10));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 401) {
      token = null;
      throw {'ok': false, 'error': 'UNAUTHORIZED', 'message': 'Session expired'};
    }
    if (streamed.statusCode == 404) {
      throw {'ok': false, 'error': 'SERVER_NOT_FOUND', 'message': 'server.php not found'};
    }
    if (streamed.statusCode == 500) {
      throw {'ok': false, 'error': 'SERVER_ERROR', 'message': 'Server error 500'};
    }

    final Map<String, dynamic> j = jsonDecode(body);
    if (j['ok'] != true && j['success'] != true) {
      throw j['message'] ?? 'Unknown error';
    }
    return j;
  }

  /// Convenience wrapper — same as call() but named clearly for file uploads
  static Future<Map<String, dynamic>> callWithFiles(
    String action,
    Map<String, dynamic> data,
    Map<String, List<int>> fileBytes,
    Map<String, String> fileNames,
  ) => call(action, data, fileBytes, fileNames);
}


// ============================================================
// SOURCE: lib/services/app_state.dart
// ============================================================


// ── Models ─────────────────────────────────────────────────────────────────────
class AppUser {
  final int id;
  final String name, mobile;
  final String? photoUrl, profilePhoto, badge;
  final bool isVerified;
  final double ratingAvg;
  final String? idVerifyStatus, criminalVerifyStatus;
  final String? idDocument, criminalRecord;

  AppUser.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        name = j['name'] ?? '',
        mobile = j['mobile'] ?? '',
        photoUrl = j['photo_url'],
        profilePhoto = j['profile_photo'],
        badge = j['badge'],
        isVerified = j['is_verified'] == true || j['is_verified'] == 1,
        ratingAvg = (j['rating_avg'] ?? 0.0).toDouble(),
        idVerifyStatus = j['id_verify_status'],
        criminalVerifyStatus = j['criminal_verify_status'],
        idDocument = j['id_document'],
        criminalRecord = j['criminal_record'];
}

class Offer {
  final int id;
  final String providerName;
  final num price;
  final String status;
  Offer.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        providerName = j['provider_name'] ?? '',
        price = j['price'] ?? 0,
        status = j['status'] ?? 'pending';
}

class Request {
  final int id;
  final String description, state;
  final String? area, type, requesterName;
  final num price, finalPrice;
  final int offerCount;
  final int? threadId;
  final bool isMine;
  final String? pickupAddress, dropoffAddress;
  final num? deliveryKm;
  final Map<String, dynamic>? myOffer;

  Request.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        description = j['description'] ?? '',
        state = j['state'] ?? 'bidding',
        area = j['area'],
        type = j['type'],
        requesterName = j['requester_name'],
        price = j['price'] ?? 0,
        finalPrice = j['final_price'] ?? j['price'] ?? 0,
        offerCount = j['offer_count'] ?? 0,
        threadId = j['thread_id'],
        isMine = j['is_mine'] == true || j['is_mine'] == 1,
        pickupAddress = j['pickup_address'],
        dropoffAddress = j['dropoff_address'],
        deliveryKm = j['delivery_km'],
        myOffer = j['my_offer'];
}

class ChatThread {
  final int id;
  final String peerName;
  final int? requestId;
  final String? lastMessage, lastMsgType, requestDescription, requestState;
  final bool isRequester;
  final num? finalPrice;
  final bool isSupport;

  ChatThread.fromJson(Map<String, dynamic> j)
      : id = j['id'] ?? 0,
        peerName = j['peer_name'] ?? j['requester_name'] ?? '',
        requestId = j['request_id'],
        lastMessage = j['last_message'],
        lastMsgType = j['last_msg_type'],
        requestDescription = j['request_description'],
        requestState = j['request_state'],
        isRequester = j['is_requester'] == true || j['is_requester'] == 1,
        finalPrice = j['final_price'],
        isSupport = j['_support'] == true;
}

class ChatMessage {
  final int id;
  final String senderName, body, type;
  final bool isMine;
  final String? voiceUrl, imageUrl;

  ChatMessage.fromJson(Map<String, dynamic> j, int myId)
      : id = j['id'] ?? 0,
        senderName = j['sender_name'] ?? '',
        body = j['body'] ?? '',
        type = j['type'] ?? 'text',
        isMine = (j['sender_id'] ?? 0) == myId,
        voiceUrl = j['voice_url'],
        imageUrl = j['image_url'];
}

// ── AppState (port of Vue reactive S) ─────────────────────────────────────────
class AppState extends ChangeNotifier {
  // ── Prefs
  String lang = 'ar';
  bool isDark = false;
  String mode = 'requester'; // 'requester' | 'provider'

  // ── Auth
  bool booting = true;
  AppUser? user;
  int providerAvailable = 0;

  // ── Lists
  bool myReqsLoading = false;
  List<Request> myReqs = [];

  bool feedLoading = false;
  bool feedBusy = false;
  List<Request> feed = [];

  bool threadsLoading = false;
  List<ChatThread> threads = [];

  // ── Wallet
  bool walletLoading = false;
  num walletBalance = 0;
  num walletEarned = 0;

  // ── User stats
  int statsReqCount = 0, statsProvCount = 0, statsRatingCount = 0;
  double statsRatingAvg = 0;
  bool statsLoaded = false;

  // ── Chat
  int? chatTid, chatRid;
  String chatPeer = '';
  bool chatLoading = false;
  List<ChatMessage> chatMsgs = [];

  // ── Feed filters
  List<String> feedFilterTypes = [];
  List<String> feedFilterAreas = [];

  // ── Toast
  String? toastMsg;
  String toastType = 'info';
  Timer? _toastTimer;

  // ── Inline offer input
  int? inlineRid;
  String inlinePrice = '';

  // ── Billboard
  int bbIdx = 0;
  Timer? _bbTimer;

  // ── New request form
  String formDesc = '', formPrice = '', formArea = '', formType = 'عام';
  bool formLoc = false, formSubmitting = false;
  int formStep = 1;
  String formPickup = '', formDropoff = '';
  double? formPickupLat, formPickupLng, formDropoffLat, formDropoffLng;
  num formDeliveryKm = 0, formSuggestedPrice = 0;
  String formPaymentMethod = 'cash';

  // ── Vehicle
  String vehicleType = '', vehicleMake = '', vehicleModel = '', vehicleYear = '', vehiclePlate = '';
  List<String?> vehiclePhotos = [null, null, null, null];
  bool vehicleDeliveryEnabled = false;
  List<String> vehiclePaymentMethods = [];
  String vehicleInstapay = '';
  bool vehicleSaving = false;
  bool vehicleLoaded = false;

  bool get isRTL => lang == 'ar';
  bool get isProv => mode == 'provider';

  String t(String key) {
    const strings = {
      'ar': {
        'appName':'ركوست','home':'الرئيسية','tasks':'ركوستاتي','chat':'شات',
        'wallet':'محفظة','profile':'حسابي','login':'دخول','register':'تسجيل',
        'logout':'خروج','newReq':'ركوست جديد','postReq':'ابعت الركوست 🚀',
        'cancel':'إلغاء','confirm':'تأكيد','back':'رجوع','price':'السعر (جنيه)',
        'area':'المنطقة','descPlaceholder':'وصف طلبك بالتفصيل…',
        'noRequests':'مفيش ركوستات لحد دلوقتي','noThreads':'مفيش محادثات',
        'accept':'قبول','reject':'رفض','complete':'أنهي الطلب','offers':'عروض',
        'providerMode':'وضع مزود','requesterMode':'وضع طالب',
        'available':'متاح الآن','unavailable':'غير متاح',
        'nearbyReqs':'ركوستات قريبة','makeOffer':'قدم عرض',
        'acceptReq':'اقبل بالسعر','typeMsg':'اكتب رسالة…',
        'bidding':'مستني عروض','accepted':'قيد التنفيذ',
        'completed':'مكتمل ✅','cancelled':'ملغي ❌','egp':'ج',
        'offerPrice':'سعر عرضك','submitOffer':'ابعت العرض',
        'noOffers':'مفيش عروض لسه','balance':'رصيد','earned':'مكسب',
        'verified':'✓ موثق','openChat':'افتح الشات','markDone':'خلّصت',
        'providerAvailableHint':'فعّل وضع المزود علشان تقدر تقبل طلبات',
        'voiceNote':'رسالة صوتية','recording':'جاري التسجيل…',
        'stopRec':'إيقاف','sendVoice':'إرسال الصوت','deleteVoice':'حذف',
        'cancelReq':'إلغاء الطلب','repost':'إعادة نشر','settings':'الإعدادات',
        'theme':'المظهر','language':'اللغة','light':'فاتح','dark':'داكن',
      },
      'en': {
        'appName':'Rqwst','home':'Home','tasks':'My Rqwsts','chat':'Chat',
        'wallet':'Wallet','profile':'Profile','login':'Login','register':'Register',
        'logout':'Logout','newReq':'New Request','postReq':'Post Request 🚀',
        'cancel':'Cancel','confirm':'Confirm','back':'Back','price':'Price (EGP)',
        'area':'Area','descPlaceholder':'Describe your request…',
        'noRequests':'No requests yet','noThreads':'No conversations yet',
        'accept':'Accept','reject':'Reject','complete':'Mark Complete','offers':'Offers',
        'providerMode':'Provider Mode','requesterMode':'Requester Mode',
        'available':'Available Now','unavailable':'Unavailable',
        'nearbyReqs':'Nearby Requests','makeOffer':'Make Offer',
        'acceptReq':'Accept at Price','typeMsg':'Type a message…',
        'bidding':'Awaiting offers','accepted':'In Progress',
        'completed':'Completed ✅','cancelled':'Cancelled ❌','egp':'EGP',
        'offerPrice':'Your Offer Price','submitOffer':'Submit Offer',
        'noOffers':'No offers yet','balance':'Balance','earned':'Earned',
        'verified':'✓ Verified','openChat':'Open Chat','markDone':'Done',
        'providerAvailableHint':'Enable Provider Mode to accept requests',
        'voiceNote':'Voice Note','recording':'Recording…',
        'stopRec':'Stop','sendVoice':'Send Voice','deleteVoice':'Delete',
        'cancelReq':'Cancel Request','repost':'Repost','settings':'Settings',
        'theme':'Theme','language':'Language','light':'Light','dark':'Dark',
      },
    };
    return strings[lang]?[key] ?? strings['ar']![key] ?? key;
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('rqwst_lang') ?? 'ar';
    isDark = prefs.getString('rqwst_theme') == 'dark';
    mode = prefs.getString('rqwst_mode') ?? 'requester';
    final token = prefs.getString('rqwst_token');
    if (token != null && token.isNotEmpty) {
      ApiService.token = token;
      await _loadMe();
    }
    booting = false;
    _startBillboard();
    notifyListeners();
  }

  Future<void> _loadMe() async {
    try {
      final j = await ApiService.call('user.me');
      user = AppUser.fromJson(j['data']['user'] ?? j['data']);
      providerAvailable = j['data']['provider_available'] ?? 0;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('rqwst_token');
      ApiService.token = null;
    }
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  Future<String?> login(String mobile, String pw) async {
    try {
      final j = await ApiService.call('user.login', {'mobile': mobile, 'password': pw});
      final token = j['data']['token'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('rqwst_token', token);
      ApiService.token = token;
      user = AppUser.fromJson(j['data']['user']);
      providerAvailable = j['data']['provider_available'] ?? 0;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String name, String mobile, String pw) async {
    try {
      final j = await ApiService.call('user.register', {'name': name, 'mobile': mobile, 'password': pw});
      final token = j['data']['token'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('rqwst_token', token);
      ApiService.token = token;
      user = AppUser.fromJson(j['data']['user']);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    try { await ApiService.call('user.logout'); } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('rqwst_token');
    ApiService.token = null;
    user = null;
    myReqs = [];
    threads = [];
    notifyListeners();
  }

  // ── Mode ───────────────────────────────────────────────────────────────────
  Future<void> setMode(String m) async {
    mode = m;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('rqwst_mode', m);
    if (m == 'provider') await loadFeed();
    notifyListeners();
  }

  Future<void> toggleAvail() async {
    final newVal = providerAvailable == 1 ? 0 : 1;
    try {
      await ApiService.call('provider.toggle', {'available': newVal});
      providerAvailable = newVal;
      notifyListeners();
    } catch (_) {}
  }

  // ── Requests ───────────────────────────────────────────────────────────────
  Future<void> loadMyReqs() async {
    if (user == null) return;
    myReqsLoading = true;
    notifyListeners();
    try {
      final j = await ApiService.call('request.my');
      myReqs = ((j['data'] ?? []) as List).map((e) => Request.fromJson(e)).toList();
    } catch (_) {}
    myReqsLoading = false;
    notifyListeners();
  }

  Future<void> loadFeed() async {
    if (user == null) return;
    feedLoading = true;
    notifyListeners();
    try {
      final j = await ApiService.call('request.feed');
      feed = ((j['data'] ?? []) as List).map((e) => Request.fromJson(e)).toList();
      feedBusy = j['busy'] == true || j['busy'] == 1;
    } catch (_) {}
    feedLoading = false;
    notifyListeners();
  }

  Future<String?> postRequest(Map<String, dynamic> params) async {
    formSubmitting = true;
    notifyListeners();
    try {
      await ApiService.call('request.create', params);
      await loadMyReqs();
      formSubmitting = false;
      notifyListeners();
      return null;
    } catch (e) {
      formSubmitting = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> acceptReq(int reqId) async {
    try {
      await ApiService.call('request.accept', {'request_id': reqId});
      await loadFeed();
    } catch (_) {}
  }

  Future<void> makeOffer(int reqId, num price) async {
    try {
      await ApiService.call('offer.create', {'request_id': reqId, 'price': price});
      await loadFeed();
    } catch (_) {}
  }

  // ── Threads ────────────────────────────────────────────────────────────────
  Future<void> loadThreads() async {
    if (user == null) return;
    threadsLoading = true;
    notifyListeners();
    try {
      final j = await ApiService.call('chat.threads');
      threads = ((j['data'] ?? []) as List).map((e) => ChatThread.fromJson(e)).toList();
    } catch (_) {}
    threadsLoading = false;
    notifyListeners();
  }

  // ── Wallet ─────────────────────────────────────────────────────────────────
  Future<void> loadWallet() async {
    if (user == null) return;
    walletLoading = true;
    notifyListeners();
    try {
      final j = await ApiService.call('wallet.get');
      walletBalance = j['data']?['balance'] ?? 0;
      walletEarned = j['data']?['earned'] ?? 0;
    } catch (_) {}
    walletLoading = false;
    notifyListeners();
  }

  // ── User stats ─────────────────────────────────────────────────────────────
  Future<void> loadStats() async {
    if (user == null || statsLoaded) return;
    try {
      final j = await ApiService.call('user.stats');
      statsReqCount = j['data']?['req_count'] ?? 0;
      statsProvCount = j['data']?['prov_count'] ?? 0;
      statsRatingAvg = (j['data']?['rating_avg'] ?? 0.0).toDouble();
      statsRatingCount = j['data']?['rating_count'] ?? 0;
      statsLoaded = true;
      notifyListeners();
    } catch (_) {}
  }

  // ── Prefs ──────────────────────────────────────────────────────────────────
  Future<void> toggleTheme() async {
    isDark = !isDark;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('rqwst_theme', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleLang() async {
    lang = lang == 'ar' ? 'en' : 'ar';
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('rqwst_lang', lang);
    statsLoaded = false;
    notifyListeners();
  }

  // ── Toast ──────────────────────────────────────────────────────────────────
  void toast(String msg, [String type = 'info']) {
    toastMsg = msg;
    toastType = type;
    notifyListeners();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toastMsg = null;
      notifyListeners();
    });
  }

  // ── Billboard auto-advance ─────────────────────────────────────────────────
  void _startBillboard() {
    _bbTimer?.cancel();
    _bbTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      bbIdx = (bbIdx + 1) % 12;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _bbTimer?.cancel();
    super.dispose();
  }
}


// ============================================================
// SOURCE: lib/services/push_service.dart
// ============================================================


/// Push notification service using FCM v1.
/// Server: push.php with FCM HTTP v1 + VAPID dual support.
/// Flutter sends its FCM token to server as "fcm:<token>" endpoint.
class PushService {
  static final _local = FlutterLocalNotificationsPlugin();
  static String? fcmToken;

  static const _channel = AndroidNotificationChannel(
    'rqwst_main',
    'Rqwst',
    description: 'طلبات، عروض، رسائل، مكالمات',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    await Firebase.initializeApp();

    // Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Local notifications init
    await _local.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));

    // Show local notification when app is in foreground
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _local.show(
        msg.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id, _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
      );
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    // Get token and register with server
    fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _registerWithServer(fcmToken!);
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      fcmToken = token;
      _registerWithServer(token);
    });
  }

  /// Request permission (iOS needs explicit request)
  static Future<String> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) await _registerWithServer(fcmToken!);
        return 'granted';
      case AuthorizationStatus.denied:
        return 'denied';
      default:
        return 'default';
    }
  }

  /// Register FCM token with server as "fcm:<token>" subscription.
  /// Server's push.subscribe action stores it and routes via FCM v1.
  static Future<void> _registerWithServer(String token) async {
    try {
      await ApiService.call('push.subscribe', {
        'fcm_token': token,
        // Send as subscription object so server.php case 'push.subscribe' accepts it
        'subscription': '{"endpoint":"fcm:$token","keys":{}}',
      });
    } catch (_) {
      // Non-fatal — app works without push
    }
  }

  /// Show a local notification manually (e.g. from in-app polling)
  static Future<void> show(String title, String body) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


// ============================================================
// SOURCE: lib/services/location_service.dart
// ============================================================


/// Port of the geolocation usage from app.js:
/// navigator.geolocation.getCurrentPosition() calls
class LocationService {
  /// Check + request permission, then get current position.
  /// Port of the Promise wrapper around getCurrentPosition
  static Future<Position?> getCurrentPosition({bool highAccuracy = true}) async {
    // Check service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Check / request permission
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Quick location grab for the new-request form (port of form submission geo)
  static Future<({double lat, double lng})?> getForRequest() async {
    final pos = await getCurrentPosition(highAccuracy: false);
    if (pos == null) return null;
    return (lat: pos.latitude, lng: pos.longitude);
  }

  /// Get location for chat "share location" button
  static Future<({double lat, double lng})?> getForChat() async {
    final pos = await getCurrentPosition(highAccuracy: true);
    if (pos == null) return null;
    return (lat: pos.latitude, lng: pos.longitude);
  }
}

/// Permission check helper (used before voice, location, camera)
class PermissionHelper {
  static Future<bool> microphone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> camera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> location() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> notification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}


// ============================================================
// SOURCE: lib/services/media_service.dart
// ============================================================


/// Port of image/file picking from app.js:
/// pickImage(), onImagePicked(), uploadIdDoc(), uploadCriminalDoc(), onAvatarPicked()
class MediaService {
  static final _picker = ImagePicker();

  // ── Avatar ─────────────────────────────────────────────────────────────────
  /// Port of pickAvatar() + onAvatarPicked()
  static Future<File?> pickAvatar() async {
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 512);
    if (xf == null) return null;
    return File(xf.path);
  }

  /// Upload avatar to server — port of api('user.upload_avatar', ...)
  static Future<String?> uploadAvatar(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final j = await ApiService.callWithFiles('user.upload_avatar', {}, {
        'photo': bytes,
      }, {'photo': 'avatar.jpg'});
      return j['data']?['url'];
    } catch (e) {
      return null;
    }
  }

  // ── Chat image ─────────────────────────────────────────────────────────────
  /// Port of pickImage() + onImagePicked()
  static Future<File?> pickChatImage() async {
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xf == null) return null;
    return File(xf.path);
  }

  static Future<void> sendChatImage(int threadId, File file) async {
    final bytes = await file.readAsBytes();
    await ApiService.callWithFiles('chat.send', {
      'thread_id': threadId,
      'message': '',
    }, {'image': bytes}, {'image': 'img.jpg'});
  }

  // ── Voice note upload ──────────────────────────────────────────────────────
  /// Port of api('chat.send', {...}, { voice: f })
  static Future<void> sendVoiceNote(int threadId, String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    await ApiService.callWithFiles('chat.send', {
      'thread_id': threadId,
      'message': '',
    }, {'voice': bytes}, {'voice': 'voice.m4a'});
  }

  // ── ID documents ───────────────────────────────────────────────────────────
  /// Port of uploadIdDoc() — accepts image or PDF
  static Future<String?> pickAndUploadIdDoc({required bool isCriminal}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final pf = result.files.first;
    if (pf.path == null) return null;

    final file = File(pf.path!);
    final bytes = await file.readAsBytes();
    final action = isCriminal ? 'user.upload_criminal' : 'user.upload_id';
    final field = isCriminal ? 'criminal_record' : 'id_document';

    try {
      final j = await ApiService.callWithFiles(action, {}, {
        field: bytes,
      }, {field: pf.name});
      return j['data']?['status'] ?? 'pending';
    } catch (e) {
      return null;
    }
  }

  // ── Vehicle photos ─────────────────────────────────────────────────────────
  /// Port of uploadVehiclePhoto(index, file)
  static Future<String?> pickAndUploadVehiclePhoto(int index) async {
    final xf = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (xf == null) {
      // Fallback to gallery
      final g = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (g == null) return null;
      return g.path;
    }
    return xf.path;
  }
}

// callWithFiles is defined directly on ApiService in api.dart


// ============================================================
// SOURCE: lib/services/voice_service.dart
// ============================================================


/// Port of the voice note system from app.js:
/// startVoice(), stopVoice(), clearVoice(), fmtSec()
class VoiceService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final AudioPlayer _player = AudioPlayer();

  static String? _recordingPath;
  static bool _isRecording = false;
  static bool _isPlaying = false;
  static int _recSec = 0;
  static Timer? _secTimer;

  static bool get isRecording => _isRecording;
  static bool get isPlaying => _isPlaying;
  static int get recSec => _recSec;
  static String? get recordingPath => _recordingPath;

  static Function()? onTick; // called every second during recording

  /// Port of startVoice() — request mic, start recording
  static Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,  // m4a — works on both iOS and Android
        sampleRate: 44100,
        bitRate: 64000,
        noiseCancel: true,
        echoCancel: true,
      ),
      path: _recordingPath!,
    );

    _isRecording = true;
    _recSec = 0;
    _secTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recSec++;
      onTick?.call();
    });
    return true;
  }

  /// Port of stopVoice() — stop recording, get file path
  static Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    _secTimer?.cancel();
    _secTimer = null;
    _isRecording = false;

    final path = await _recorder.stop();
    _recordingPath = path;
    return path;
  }

  /// Port of clearVoice()
  static Future<void> clearRecording() async {
    _secTimer?.cancel();
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
    }
    if (_recordingPath != null) {
      try { await File(_recordingPath!).delete(); } catch (_) {}
      _recordingPath = null;
    }
    _recSec = 0;
  }

  /// Play a voice note from a URL or local path
  static Future<void> playVoice(String urlOrPath) async {
    await _player.stop();
    if (urlOrPath.startsWith('http')) {
      await _player.play(UrlSource(urlOrPath));
    } else {
      await _player.play(DeviceFileSource(urlOrPath));
    }
    _isPlaying = true;
    _player.onPlayerComplete.listen((_) => _isPlaying = false);
  }

  static Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Port of fmtSec(s)
  static String fmtSec(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }

  static Future<void> dispose() async {
    _secTimer?.cancel();
    await _recorder.dispose();
    await _player.dispose();
  }
}


// ============================================================
// SOURCE: lib/services/call_service.dart
// ============================================================


/// State of a single call
class CallState {
  bool outgoing = false;    // we placed the call
  bool ringing = false;     // incoming, not yet answered
  bool inCall = false;      // connected
  bool loudspeaker = false;
  int duration = 0;         // seconds
  Map<String, dynamic>? incomingOffer; // SDP from remote peer

  RTCPeerConnection? pc;
  MediaStream? localStream;
  MediaStream? remoteStream;
  List<RTCIceCandidate> iceBuf = []; // buffered ICE before remoteDescription set
  int lastSigId = 0;
  Timer? durTimer;

  bool get active => inCall || outgoing || ringing;
}

/// Port of the WebRTC system from app.js
/// Uses chat.send with signal_type for signalling (same as original)
class CallService {
  static final CallState state = CallState();
  static Function()? onStateChanged; // call setState in UI

  static const _iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
    {'urls': 'stun:stun.cloudflare.com:3478'},
  ];

  static final _pcConfig = {
    'iceServers': _iceServers,
    'iceCandidatePoolSize': 10,
    'iceTransportPolicy': 'all',
    'bundlePolicy': 'max-bundle',
    'sdpSemantics': 'unified-plan',
  };

  // ── Create peer connection ──────────────────────────────────────────────────
  // Port of makePeerConn()
  static Future<RTCPeerConnection> _makePc(int threadId) async {
    final pc = await createPeerConnection(_pcConfig);

    pc.onIceCandidate = (candidate) async {
      try {
        await _sendSignal(threadId, 'call_ice', {
          'candidate': candidate.toMap(),
        });
      } catch (_) {}
    };

    pc.onIceConnectionState = (state_) async {
      if (state_ == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state_ == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        if (!state.inCall && (state.outgoing || state.ringing)) {
          state.inCall = true;
          state.outgoing = false;
          state.ringing = false;
          state.durTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            state.duration++;
            onStateChanged?.call();
          });
          onStateChanged?.call();
        }
      }
      if (state_ == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        teardown();
        onStateChanged?.call();
      }
    };

    pc.onConnectionState = (s) {
      if (s == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        teardown();
        onStateChanged?.call();
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        state.remoteStream = event.streams[0];
      } else {
        state.remoteStream ??= event.track.kind == 'audio'
            ? MediaStream('remote', 'remote')
            : null;
        state.remoteStream?.addTrack(event.track);
      }
      onStateChanged?.call();
    };

    return pc;
  }

  // ── Start an outgoing call ─────────────────────────────────────────────────
  // Port of startCall()
  static Future<String?> startCall(int threadId) async {
    if (state.inCall || state.outgoing) return null;
    try {
      final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      state.localStream = stream;
      final pc = await _makePc(threadId);
      state.pc = pc;

      for (final track in stream.getTracks()) {
        await pc.addTrack(track, stream);
      }

      final offer = await pc.createOffer({'offerToReceiveAudio': true});
      await pc.setLocalDescription(offer);

      await _sendSignal(threadId, 'call_offer', {
        'sdp': {'type': offer.type, 'sdp': offer.sdp},
      });

      state.outgoing = true;
      onStateChanged?.call();
      return null;
    } catch (e) {
      state.outgoing = false;
      teardown();
      return e.toString();
    }
  }

  // ── Answer an incoming call ────────────────────────────────────────────────
  // Port of answerCall()
  static Future<String?> answerCall(int threadId) async {
    if (state.incomingOffer == null) return 'No incoming offer';
    try {
      final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      state.localStream = stream;
      final pc = await _makePc(threadId);
      state.pc = pc;

      for (final track in stream.getTracks()) {
        await pc.addTrack(track, stream);
      }

      final offerSdp = RTCSessionDescription(
        state.incomingOffer!['sdp'],
        state.incomingOffer!['type'],
      );
      await pc.setRemoteDescription(offerSdp);

      // Flush buffered ICE
      for (final c in state.iceBuf) {
        try { await pc.addCandidate(c); } catch (_) {}
      }
      state.iceBuf.clear();

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _sendSignal(threadId, 'call_answer', {
        'sdp': {'type': answer.type, 'sdp': answer.sdp},
      });

      state.ringing = false;
      state.inCall = true;
      state.durTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        state.duration++;
        onStateChanged?.call();
      });
      onStateChanged?.call();
      return null;
    } catch (e) {
      teardown();
      try { await _sendSignal(threadId, 'call_end', {'reason': 'failed'}); } catch (_) {}
      return e.toString();
    }
  }

  // ── End call ───────────────────────────────────────────────────────────────
  // Port of endCall()
  static Future<void> endCall(int threadId) async {
    final dur = state.duration;
    try {
      await _sendSignal(threadId, 'call_end', {'reason': 'hangup', 'duration': dur});
    } catch (_) {}
    if (dur > 0) {
      try {
        await ApiService.call('chat.send', {
          'thread_id': threadId,
          'message': jsonEncode({'sys': 'call_ended', 'duration': dur}),
          'signal_type': 'call_summary',
        });
      } catch (_) {}
    }
    teardown();
    onStateChanged?.call();
  }

  // ── Reject incoming call ───────────────────────────────────────────────────
  static Future<void> rejectCall(int threadId) async {
    try { await _sendSignal(threadId, 'call_end', {'reason': 'rejected'}); } catch (_) {}
    teardown();
    onStateChanged?.call();
  }

  // ── Toggle speaker (iOS/Android) ───────────────────────────────────────────
  // Port of toggleSpeaker()
  static Future<void> toggleSpeaker() async {
    state.loudspeaker = !state.loudspeaker;
    // flutter_webrtc exposes this via Helper on mobile
    try {
      await Helper.setSpeakerphoneOn(state.loudspeaker);
    } catch (_) {}
    onStateChanged?.call();
  }

  // ── Handle incoming signals (from chat polling) ────────────────────────────
  // Port of handleSignals(msgs)
  static Future<void> handleSignals(List<Map<String, dynamic>> msgs, int threadId, int myUserId) async {
    for (final m in msgs) {
      final sid = int.tryParse(m['id']?.toString() ?? '0') ?? 0;
      if (sid <= state.lastSigId) continue;
      state.lastSigId = sid;

      Map<String, dynamic> o;
      try { o = jsonDecode(m['body'] ?? '{}'); } catch (_) { continue; }

      final type = o['t'] ?? o['type'];
      final p = (o['p'] ?? {}) as Map<String, dynamic>;
      if (type == null) continue;

      // Ignore my own messages
      if (m['sender_id']?.toString() == myUserId.toString()) continue;

      switch (type) {
        case 'call_offer':
          if (state.inCall || state.outgoing) continue;
          // Ignore stale (> 90s old)
          if (o['at'] != null && DateTime.now().millisecondsSinceEpoch - (o['at'] as int) > 90000) continue;
          state.incomingOffer = p['sdp'];
          state.ringing = true;
          onStateChanged?.call();
          break;

        case 'call_answer':
          if (state.pc == null || state.inCall) continue;
          if (o['at'] != null && DateTime.now().millisecondsSinceEpoch - (o['at'] as int) > 90000) continue;
          try {
            final sdp = RTCSessionDescription(p['sdp']['sdp'], p['sdp']['type']);
            await state.pc!.setRemoteDescription(sdp);
            for (final c in state.iceBuf) {
              try { await state.pc!.addCandidate(c); } catch (_) {}
            }
            state.iceBuf.clear();
            state.inCall = true;
            state.outgoing = false;
            state.durTimer = Timer.periodic(const Duration(seconds: 1), (_) {
              state.duration++;
              onStateChanged?.call();
            });
            onStateChanged?.call();
          } catch (_) {}
          break;

        case 'call_ice':
          if (p['candidate'] == null) continue;
          final candidate = RTCIceCandidate(
            p['candidate']['candidate'],
            p['candidate']['sdpMid'],
            p['candidate']['sdpMLineIndex'],
          );
          final rd = await state.pc?.getRemoteDescription();
          if (rd?.type != null) {
            try { await state.pc!.addCandidate(candidate); } catch (_) {}
          } else {
            state.iceBuf.add(candidate);
          }
          break;

        case 'call_end':
          if (state.active) {
            teardown();
            onStateChanged?.call();
          }
          break;
      }
    }
  }

  // ── Teardown ───────────────────────────────────────────────────────────────
  // Port of teardownCall()
  static void teardown() {
    try {
      state.pc?.onIceCandidate = null;
      state.pc?.onTrack = null;
      state.pc?.close();
    } catch (_) {}
    try { state.localStream?.getTracks().forEach((t) => t.stop()); } catch (_) {}
    state.durTimer?.cancel();
    state.pc = null;
    state.localStream = null;
    state.remoteStream = null;
    state.inCall = false;
    state.outgoing = false;
    state.ringing = false;
    state.incomingOffer = null;
    state.iceBuf.clear();
    state.duration = 0;
    state.durTimer = null;
    state.loudspeaker = false;
  }

  // ── Format call duration ───────────────────────────────────────────────────
  // Port of fmtCallDur(s)
  static String fmtDur(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m > 0 ? m : 0}:${r.toString().padLeft(2, '0')}';
  }

  // ── Send a signal message via chat.send ────────────────────────────────────
  // Port of sendSignalMsg(type, payload)
  static Future<void> _sendSignal(int threadId, String type, Map<String, dynamic> payload) async {
    await ApiService.call('chat.send', {
      'thread_id': threadId,
      'message': jsonEncode({'t': type, 'p': payload, 'at': DateTime.now().millisecondsSinceEpoch}),
      'signal_type': type,
    });
  }
}


// ============================================================
// SOURCE: lib/services/voice_route_service.dart
// ============================================================


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


// ============================================================
// SOURCE: lib/widgets/common.dart
// ============================================================


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
        color: background ?? Theme.of(context).cardColor,
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

// ReadContext removed (single file)

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


// ============================================================
// SOURCE: lib/screens/auth_sheet.dart
// ============================================================


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
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Logo
          Center(child: Container(width: 52, height: 52,
            decoration: BoxDecoration(color: RqwstColors.brand, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.3), blurRadius: 16)]),
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
            style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
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
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
  );
}


// ============================================================
// SOURCE: lib/screens/rating_sheet.dart
// ============================================================


/// Port of the rating sheet from the original:
/// S.overlay === 'rating', submitRating(), S.rating = {rid, toUser, stars, msg}
class RatingSheet extends StatefulWidget {
  final int requestId;
  final int toUserId;
  const RatingSheet({super.key, required this.requestId, required this.toUserId});

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _stars = 5;
  final _msgCtrl = TextEditingController();
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final s = context.read<AppState>();
    setState(() => _submitting = true);
    try {
      await ApiService.call('ratings.submit', {
        'request_id': widget.requestId,
        'to_user': widget.toUserId,
        'stars': _stars,
        'message': _msgCtrl.text.trim(),
      });
      setState(() => _done = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      s.toast(e.toString(), 'error');
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),

        if (_done) ...[
          // Success state
          const Text('🎉', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(rtl ? 'شكراً على تقييمك!' : 'Thanks for your rating!',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
        ] else ...[
          // Star icon
          const Text('⭐', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(s.t('submitRating'),
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Star selector
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
            final filled = i < _stars;
            return GestureDetector(
              onTap: () => setState(() => _stars = i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('⭐', style: TextStyle(
                  fontSize: 36,
                  color: filled ? null : Colors.grey.withValues(alpha: 0.3),
                )),
              ),
            );
          })),
          const SizedBox(height: 6),

          // Star label
          Text(_starLabel(_stars, rtl),
            style: GoogleFonts.cairo(fontSize: 13, color: RqwstColors.amber, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
          const SizedBox(height: 18),

          // Optional message
          TextField(
            controller: _msgCtrl,
            maxLines: 2,
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            decoration: InputDecoration(
              hintText: rtl ? 'اكتب تجربتك (اختياري)' : 'Your experience (optional)',
              hintStyle: GoogleFonts.cairo(),
            ),
            style: GoogleFonts.cairo(),
          ),
          const SizedBox(height: 18),

          // Buttons
          Row(children: [
            Expanded(child: BrandButton(label: s.t('cancel'), ghost: true, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 10),
            Expanded(child: BrandButton(label: s.t('submitRating'), loading: _submitting, onTap: _submit)),
          ]),
        ],
      ]),
    );
  }

  String _starLabel(int stars, bool rtl) {
    if (rtl) {
      switch (stars) {
        case 1: return 'سيء جداً';
        case 2: return 'سيء';
        case 3: return 'مقبول';
        case 4: return 'كويس';
        case 5: return 'ممتاز!';
      }
    } else {
      switch (stars) {
        case 1: return 'Very poor';
        case 2: return 'Poor';
        case 3: return 'OK';
        case 4: return 'Good';
        case 5: return 'Excellent!';
      }
    }
    return '';
  }
}


// ============================================================
// SOURCE: lib/screens/notif_sheets.dart
// ============================================================


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
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
                                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)
                                : RqwstColors.brand.withValues(alpha: 0.2)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(n.body, style: GoogleFonts.cairo(fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(n.time, style: GoogleFonts.cairo(fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
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
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07))),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
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
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('✏️ ${rtl ? 'تغيير الاسم' : 'Edit Name'}',
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Text(rtl ? 'الاسم الجديد' : 'New Name',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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


// ============================================================
// SOURCE: lib/screens/wallet_screen.dart
// ============================================================


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
                        background: RqwstColors.brand.withValues(alpha: 0.08),
                        child: Column(children: [
                          Text(s.t('balance'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                          const SizedBox(height: 4),
                          Text('${s.walletBalance}', style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: RqwstColors.brand)),
                          Text(s.t('egp'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                        ], mainAxisAlignment: MainAxisAlignment.center),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: RqwstCard(
                        background: RqwstColors.invert.withValues(alpha: 0.08),
                        child: Column(children: [
                          Text(s.t('earned'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                          const SizedBox(height: 4),
                          Text('${s.walletEarned}', style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: RqwstColors.invert)),
                          Text(s.t('egp'), style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                        ], mainAxisAlignment: MainAxisAlignment.center),
                      )),
                    ]),
                    const SizedBox(height: 20),
                    Text(
                      rtl ? 'ميزات المحفظة قريباً 💳' : 'Wallet features coming soon 💳',
                      style: GoogleFonts.cairo(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ]),
                ),
    );
  }
}


// ============================================================
// SOURCE: lib/screens/voice_route_dialog.dart
// ============================================================


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


// ============================================================
// SOURCE: lib/screens/new_request_sheet.dart
// ============================================================


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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
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
                      color: _step >= i + 1 ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ))),
                ])),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                    child: Center(child: Text('✕', style: GoogleFonts.cairo(fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))))),
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
        style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)))),
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
        border: Border.all(color: selected ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 2),
        boxShadow: selected
            ? [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.18), blurRadius: 24)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900,
          color: selected ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface)),
        if (hint.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(hint, style: GoogleFonts.cairo(fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)), textAlign: TextAlign.center),
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
            color: RqwstColors.brand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.3)),
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
            border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.25), blurRadius: 20)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: RqwstColors.brand,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.4), blurRadius: 10)],
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
                  boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.3), blurRadius: 6)],
                )),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: pickupCtrl,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: rtl ? 'نقطة الانطلاق...' : 'Pickup location...',
                  hintStyle: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
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
              Container(width: 1.5, height: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
              const SizedBox(width: 10),
              Expanded(child: Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07))),
            ])),

          // Dropoff row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(children: [
              Container(width: 12, height: 12,
                decoration: BoxDecoration(
                  color: RqwstColors.rose,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: RqwstColors.rose.withValues(alpha: 0.3), blurRadius: 6)],
                )),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: dropoffCtrl,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: rtl ? 'نقطة الوصول...' : 'Dropoff location...',
                  hintStyle: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
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
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)),
          ),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.map_outlined, size: 36, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 8),
            Text(
              pickupLat == null
                  ? (rtl ? 'اكتب نقطة الانطلاق' : 'Enter pickup location')
                  : (rtl ? 'اكتب نقطة الوصول' : 'Enter dropoff location'),
              style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
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
      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16)],
    ),
    child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Text(label, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 0.5))),
      ...suggestions.take(5).map((s) {
        final name = (s['display_name'] as String? ?? '').split(',');
        return GestureDetector(
          onTap: () => onSelect(s),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)))),
            child: Row(children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.location_on, color: color, size: 16)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name.first.trim(),
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                if (name.length > 1)
                  Text(name.skip(1).take(2).join('،'),
                    style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)),
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
        // patterns: not available on web
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
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5),
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
                color: Colors.black.withValues(alpha: 0.6),
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
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
            border: Border.all(color: area.isNotEmpty ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 1.5),
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
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07)),
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
        border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.4), width: 1.5),
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
          style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
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
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
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


// ============================================================
// SOURCE: lib/screens/request_detail_sheet.dart
// ============================================================


class RequestDetailSheet extends StatefulWidget {
  final Request req;
  const RequestDetailSheet({super.key, required this.req});

  @override
  State<RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends State<RequestDetailSheet> {
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;
  late Request _req;

  @override
  void initState() {
    super.initState();
    _req = widget.req;
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _loading = true);
    try {
      final j = await ApiService.call('offers.for_request', {'request_id': _req.id});
      if (mounted) setState(() => _offers = List<Map<String, dynamic>>.from(j['data']?['offers'] ?? []));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  Future<void> _acceptOffer(int offerId) async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'تقبل العرض ده؟' : 'Accept this offer?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Text(rtl ? 'هيفتح شات بينك وبين المزود' : 'A chat will open with the provider', style: GoogleFonts.cairo()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(s.t('accept'), style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      final j = await ApiService.call('offers.accept', {'offer_id': offerId});
      s.toast(rtl ? 'تم القبول 🤝' : 'Accepted 🤝', 'success');
      await s.loadMyReqs();
      final tid = j['data']?['thread_id'] as int?;
      if (!mounted) return;
      Navigator.pop(context); // close sheet
      if (tid != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: s,
              child: ChatDetailScreen(threadId: tid, requestId: _req.id, peerName: ''),
            ),
          ));
        }
      }
    } catch (e) {
      s.toast(e.toString(), 'error');
    }
  }

  Future<void> _rejectOffer(int offerId) async {
    try {
      await ApiService.call('offers.reject', {'offer_id': offerId});
      await _loadOffers();
      if (mounted) context.read<AppState>().toast(context.read<AppState>().isRTL ? 'تم الرفض' : 'Rejected', 'info');
    } catch (_) {}
  }

  Future<void> _cancelReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    String reason = '';
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'تلغي الطلب؟' : 'Cancel Request?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(rtl ? 'ممكن تسيب سبب بسيط (اختياري)' : 'You can leave a reason (optional)', style: GoogleFonts.cairo(fontSize: 13)),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(hintText: rtl ? 'سبب الإلغاء…' : 'Reason (optional)…'),
          style: GoogleFonts.cairo(),
          onChanged: (v) => reason = v,
          maxLines: 2,
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(rtl ? 'إلغاء الطلب' : 'Cancel Request',
            style: GoogleFonts.cairo(color: RqwstColors.rose, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      await ApiService.call('requests.cancel', {'request_id': _req.id, 'reason': reason});
      await s.loadMyReqs();
      if (!mounted) return;
      Navigator.pop(context);
      s.toast(s.t('reqCancelled'), 'warning');
    } catch (_) {}
  }

  Future<void> _completeReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'الطلب خلص؟' : 'Request complete?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Text(rtl ? 'هتأكد إن كل حاجة تمت' : 'Confirm everything went well', style: GoogleFonts.cairo()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(rtl ? 'أيوه، خلص' : 'Yes, done',
            style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      final myId = s.user?.id ?? 0;
      final j = await ApiService.call('requests.complete', {'request_id': _req.id});
      await s.loadMyReqs();
      if (!mounted) return;
      Navigator.pop(context);
      s.toast(s.t('reqCompleted'), 'success');
      final srvReq = j['data']?['req'] ?? {};
      final providerId = srvReq['provider_id'] as int?;
      final requesterId = srvReq['user_id'] as int?;
      if (mounted && myId == requesterId && providerId != null && providerId != myId) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ChangeNotifierProvider.value(
            value: s,
            child: RatingSheet(requestId: _req.id, toUserId: providerId),
          ),
        );
      }
    } catch (_) {}
  }

  bool get _canChat => (_req.state == 'accepted' || _req.state == 'in_progress') && _req.threadId != null;
  bool get _canComplete => _req.state == 'accepted' || _req.state == 'in_progress';
  bool get _canCancel => _req.state == 'bidding' || _req.state == 'open' || _req.state == 'posted';
  bool get _isMine => true; // sheet is only opened for own requests

  String _statusLabel(AppState s) {
    switch (_req.state) {
      case 'bidding': return s.t('bidding');
      case 'accepted': case 'in_progress': return s.t('accepted');
      case 'completed': case 'done': return s.t('completed');
      case 'cancelled': case 'canceled': return s.t('cancelled');
      default: return _req.state;
    }
  }

  String _statusColor() {
    switch (_req.state) {
      case 'bidding': return 'amber';
      case 'accepted': case 'in_progress': return 'invert';
      case 'completed': case 'done': return 'green';
      case 'cancelled': case 'canceled': return 'red';
      default: return 'slate';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2))),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              StatusPill(label: _statusLabel(s), color: _statusColor()),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Description + meta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_req.description, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, height: 1.4)),
              const SizedBox(height: 8),
              Wrap(spacing: 14, children: [
                if (_req.area != null)
                  _Meta(icon: Icons.location_on_outlined, text: _req.area!),
                _Meta(icon: Icons.attach_money, text: '${_req.finalPrice > 0 ? _req.finalPrice : _req.price} ${s.t('egp')}', color: RqwstColors.brand),
                if (_req.requesterName != null)
                  _Meta(icon: Icons.person_outline, text: _req.requesterName!),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(spacing: 8, children: [
              if (_canChat)
                BrandButton(
                  label: s.t('openChat'),
                  small: true,
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: s,
                            child: ChatDetailScreen(threadId: _req.threadId!, requestId: _req.id, peerName: ''),
                          ),
                        ));
                      }
                    });
                  },
                ),
              if (_canComplete)
                BrandButton(label: rtl ? 'الطلب اكتمل' : s.t('markDone'), small: true, ghost: true,
                  icon: Icons.check, onTap: _completeReq),
              if (_canCancel)
                BrandButton(label: s.t('cancel'), small: true, danger: true,
                  icon: Icons.close, onTap: _cancelReq),
            ]),
          ),
          const SizedBox(height: 18),

          // Offers section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.people_outline, size: 16),
              const SizedBox(width: 8),
              Text(s.t('offers'), style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
              if (_offers.isNotEmpty) ...[
                const SizedBox(width: 8),
                StatusPill(label: '${_offers.length}', color: 'slate'),
              ],
            ]),
          ),
          const SizedBox(height: 10),

          // Offers list
          Expanded(child: _loading
              ? ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 2,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerBox(height: 90)))
              : _offers.isEmpty
                  ? Center(child: Text(s.t('noOffers'),
                      style: GoogleFonts.cairo(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))))
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: _offers.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OfferCard(
                          offer: _offers[i],
                          req: _req,
                          s: s,
                          onAccept: _isMine ? () => _acceptOffer(_offers[i]['id'] as int) : null,
                          onReject: _isMine ? () => _rejectOffer(_offers[i]['id'] as int) : null,
                        ),
                      ),
                    )),
        ]),
      ),
    );
  }
}

// ── Offer card ─────────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final Request req;
  final AppState s;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _OfferCard({
    required this.offer, required this.req, required this.s,
    this.onAccept, this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = offer['status'] as String? ?? 'pending';
    final accepted = status == 'accepted';
    final rtl = s.isRTL;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accepted ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
          width: accepted ? 1.5 : 1,
        ),
        boxShadow: accepted
            ? [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.15), blurRadius: 20)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
      ),
      child: Column(children: [
        // Provider header row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: offer['provider_photo'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(offer['provider_photo'] as String, fit: BoxFit.cover))
                  : const Icon(Icons.person, color: Colors.grey, size: 22),
            ),
            const SizedBox(width: 12),
            // Name + badges + rating
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offer['provider_name'] as String? ?? '',
                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Wrap(spacing: 5, runSpacing: 4, children: [
                if (offer['id_verified'] == true)
                  _VerifyBadge(label: rtl ? 'هوية' : 'ID ✓', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF15803D)),
                if (offer['criminal_verified'] == true)
                  _VerifyBadge(label: rtl ? 'سجل نظيف' : 'Clear ✓', bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1D4ED8)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('⭐', style: TextStyle(fontSize: 11)),
                  Text(' ${(offer['provider_rating'] as num? ?? 0).toStringAsFixed(1)}'
                      ' (${offer['provider_rating_count'] ?? 0})',
                    style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                ]),
              ]),
            ])),
            // Price
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${offer['price']}',
                style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900, color: RqwstColors.brand)),
              Text(s.t('egp'),
                style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
            ]),
          ]),
        ),

        // Vehicle strip (delivery requests)
        if (offer['vehicle_make'] != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.symmetric(horizontal: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07))),
            ),
            child: Row(children: [
              Text(offer['vehicle_type'] == 'car' ? '🚗' : '🛵', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text('${offer['vehicle_make']} ${offer['vehicle_model']} ${offer['vehicle_year']}',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              // Vehicle photos mini strip
              if ((offer['vehicle_photos'] as List?)?.any((p) => p != null) == true)
                Row(children: [
                  ...((offer['vehicle_photos'] as List).where((p) => p != null).take(3).map((ph) =>
                    Container(
                      width: 36, height: 28, margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07))),
                      child: ClipRRect(borderRadius: BorderRadius.circular(6),
                        child: Image.network(ph as String, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 14))),
                    )
                  )),
                ]),
            ]),
          ),
        ],

        // Payment methods + action buttons
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            // Payment pills
            Wrap(spacing: 5, children: [
              if ((offer['payment_methods'] as List?)?.contains('cash') == true || offer['payment_method'] == 'cash')
                _PayBadge(label: '💵 ${rtl ? 'كاش' : 'Cash'}'),
              if ((offer['payment_methods'] as List?)?.contains('instapay') == true || offer['payment_method'] == 'instapay')
                _PayBadge(label: '📱 إنستاباي', purple: true),
            ]),
            const Spacer(),
            // Action buttons (only for pending + owner)
            if (status == 'pending' && onAccept != null)
              Row(children: [
                BrandButton(label: s.t('accept'), small: true, onTap: onAccept),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onReject,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: RqwstColors.roseL,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, size: 16, color: RqwstColors.rose),
                  ),
                ),
              ])
            else
              StatusPill(
                label: status == 'accepted' ? (rtl ? '✓ مقبول' : '✓ Accepted')
                    : status == 'rejected' ? (rtl ? 'مرفوض' : 'Rejected')
                    : (rtl ? 'في الانتظار' : 'Pending'),
                color: status == 'accepted' ? 'green' : status == 'rejected' ? 'red' : 'slate',
              ),
          ]),
        ),

        // Tap hint
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            rtl ? 'اضغط على البطاقة لرؤية التفاصيل' : 'Tap card to see full profile & reviews',
            style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
          ),
        ),
      ]),
    );
  }
}

class _VerifyBadge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _VerifyBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check, size: 7, color: fg),
      const SizedBox(width: 2),
      Text(label, style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
    ]),
  );
}

class _PayBadge extends StatelessWidget {
  final String label;
  final bool purple;
  const _PayBadge({required this.label, this.purple = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: purple ? const Color(0xFFEDE9FE) : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: purple ? const Color(0xFFC4B5FD) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
    ),
    child: Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700,
      color: purple ? const Color(0xFF7C3AED) : null)),
  );
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _Meta({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
    const SizedBox(width: 4),
    Text(text, style: GoogleFonts.cairo(fontSize: 13,
      color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      fontWeight: color != null ? FontWeight.w700 : FontWeight.w400)),
  ]);
}


// ============================================================
// SOURCE: lib/screens/active_request_overlay.dart
// ============================================================


// ── Stage helpers (port of arStage() from app.js) ─────────────────────────────
String _arStage(Request req) {
  final s = req.state.toLowerCase();
  if (s == 'bidding' || s == 'open' || s == 'posted') return 'searching';
  if (s == 'accepted' || s == 'in_progress') return 'accepted';
  return 'done';
}

bool _canComplete(Request req) =>
    req.state == 'accepted' || req.state == 'in_progress';

bool _canCancel(Request req) =>
    req.state == 'bidding' || req.state == 'open' || req.state == 'posted';

// ── AR Overlay widget ─────────────────────────────────────────────────────────
class ActiveRequestOverlay extends StatefulWidget {
  final Request req;
  final bool isProvider;
  final VoidCallback onDismiss;

  const ActiveRequestOverlay({
    super.key,
    required this.req,
    required this.isProvider,
    required this.onDismiss,
  });

  @override
  State<ActiveRequestOverlay> createState() => _ActiveRequestOverlayState();
}

class _ActiveRequestOverlayState extends State<ActiveRequestOverlay>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _pulseCtrl;

  List<Map<String, dynamic>> _offers = [];
  int _secondsLeft = 1800;
  int _totalSeconds = 1800;
  Timer? _countdown;
  bool _loadingOffers = false;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadOffers();
    _startTimer();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    _countdown?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Port of startARTimer() — uses expires_at if available, else 30min
    _secondsLeft = 1800;
    _totalSeconds = 1800;
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
      if (_secondsLeft == 0) {
        _countdown?.cancel();
        context.read<AppState>().loadMyReqs();
      }
    });
  }

  Future<void> _loadOffers() async {
    if (_loadingOffers) return;
    setState(() => _loadingOffers = true);
    try {
      final j = await ApiService.call('offers.for_request', {'request_id': widget.req.id});
      if (mounted) {
        setState(() => _offers = List<Map<String, dynamic>>.from(j['data']?['offers'] ?? []));
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingOffers = false);
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Future<void> _cancelReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    String reason = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(rtl ? 'تلغي الطلب؟' : 'Cancel Request?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(rtl ? 'ممكن تسيب سبب بسيط (اختياري)' : 'You can leave a reason (optional)',
            style: GoogleFonts.cairo(fontSize: 13)),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(hintText: rtl ? 'سبب الإلغاء…' : 'Reason (optional)…'),
            style: GoogleFonts.cairo(),
            onChanged: (v) => reason = v,
            maxLines: 2,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text(s.t('back'), style: GoogleFonts.cairo())),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text(rtl ? 'إلغاء الطلب' : 'Cancel Request',
              style: GoogleFonts.cairo(color: RqwstColors.rose, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ApiService.call('requests.cancel', {'request_id': widget.req.id, 'reason': reason});
      await s.loadMyReqs();
      widget.onDismiss();
      s.toast(s.t('reqCancelled'), 'warning');
    } catch (_) {}
  }

  Future<void> _completeReq() async {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(rtl ? 'الطلب خلص؟' : 'Request complete?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
        content: Text(rtl ? 'هتأكد إن كل حاجة تمت' : 'Confirm everything went well', style: GoogleFonts.cairo()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text(rtl ? 'أيوه، خلص' : 'Yes, done',
              style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final myId = s.user?.id ?? 0;
      final j = await ApiService.call('requests.complete', {'request_id': widget.req.id});
      await s.loadMyReqs();
      widget.onDismiss();
      s.toast(s.t('reqCompleted'), 'success');
      // Open rating if I'm the requester and there's a provider
      final srvReq = j['data']?['req'] ?? {};
      final providerId = srvReq['provider_id'] as int?;
      final requesterId = srvReq['user_id'] as int?;
      if (mounted && myId == requesterId && providerId != null && providerId != myId) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: s,
              child: RatingSheet(requestId: widget.req.id, toUserId: providerId),
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _openDetail() {
    widget.onDismiss();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppState>(),
        child: RequestDetailSheet(req: widget.req),
      ),
    );
  }

  void _openChat(int threadId) {
    widget.onDismiss();
    final s = context.read<AppState>();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: s,
        child: ChatDetailScreen(
          threadId: threadId,
          requestId: widget.req.id,
          peerName: widget.req.requesterName ?? '',
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;
    final stage = _arStage(widget.req);
    final isSearching = stage == 'searching';
    final isAccepted = stage == 'accepted';
    final isProvider = widget.isProvider;

    final accentColor = isProvider ? RqwstColors.invert : RqwstColors.brand;
    final bgColor1 = isProvider ? const Color(0xFF0A1628) : const Color(0xFF0A1628);
    final bgColor2 = isProvider ? const Color(0xFF0D2240) : const Color(0xFF0D2A1A);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor1, bgColor2, bgColor1],
            stops: const [0, 0.6, 1],
          ),
        ),
        child: Stack(children: [
          // ── Animated rings (InDrive style) ──────────────────────────────
          _AnimatedRings(ctrl: _ringCtrl, color: accentColor, count: isSearching ? 4 : 3),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Column(children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  // Dismiss
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 7, height: 7,
                        decoration: BoxDecoration(color: isSearching ? RqwstColors.brand : accentColor, shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Text(
                        isSearching
                            ? s.t('searching')
                            : isProvider
                                ? (rtl ? 'جاري التنفيذ' : 'In Progress')
                                : (rtl ? 'قبل المزود طلبك ✓' : 'Provider accepted ✓'),
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ]),
              ),

              // ── Center section ─────────────────────────────────────────
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Stack(alignment: Alignment.center, children: [
                      // Outer pulse ring
                      Container(
                        width: 120 + _pulseCtrl.value * 10,
                        height: 120 + _pulseCtrl.value * 10,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08 + _pulseCtrl.value * 0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Icon box
                      Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.4), blurRadius: 40)],
                        ),
                        child: Icon(
                          isSearching ? Icons.search
                              : isProvider ? Icons.bolt
                              : Icons.check,
                          color: Colors.white, size: 38,
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 22),

                  // Stage title
                  Text(
                    isProvider
                        ? (rtl ? 'جاري التنفيذ' : 'In Progress')
                        : isSearching
                            ? (_offers.isNotEmpty ? s.t('gotOffers') : s.t('searching'))
                            : s.t('providerAccepted'),
                    style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSearching
                        ? (_offers.isNotEmpty
                            ? '${_offers.length} ${rtl ? 'مزودين أبدوا اهتمامهم' : 'providers are interested'}'
                            : (rtl ? 'كل الناس القريبة بتشوف الطلب' : 'Everyone nearby can see your request'))
                        : (widget.req.requesterName ?? ''),
                    style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withValues(alpha: 0.55)),
                    textAlign: TextAlign.center,
                  ),

                  // Timer bar (searching only)
                  if (isSearching && _secondsLeft > 0) ...[
                    const SizedBox(height: 24),
                    SizedBox(width: 300, child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(s.t('timeLeft'),
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                        Text(_fmtTime(_secondsLeft),
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.9))),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _secondsLeft / _totalSeconds,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(RqwstColors.brand),
                          minHeight: 5,
                        ),
                      ),
                    ])),
                  ],

                  // Offer dots (bidding with offers)
                  if (isSearching && _offers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ..._offers.take(5).map((o) => Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: RqwstColors.brand.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.4)),
                        ),
                        child: Center(child: Text('${o['price']}',
                          style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: RqwstColors.brand))),
                      )),
                      if (_offers.length > 5)
                        Text('+${_offers.length - 5}',
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                    ]),
                  ],

                  // Stage progress strip
                  const SizedBox(height: 28),
                  _StageStrip(stage: stage, isProvider: isProvider, s: s),
                ],
              )),

              // ── Bottom section ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
                child: Column(children: [
                  // Safety disclaimer (searching)
                  if (isSearching) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: RqwstColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RqwstColors.amber.withValues(alpha: 0.25)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('⚠️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          rtl
                              ? 'تحقق من تقييم المزود وشاراته. لا تشارك معلوماتك الشخصية.'
                              : 'Always check provider rating and badges. Never share personal info.',
                          style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.7), height: 1.5),
                        )),
                      ]),
                    ),
                  ],

                  // Request card
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.req.description,
                        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
                      const SizedBox(height: 5),
                      Row(children: [
                        if (widget.req.area != null) ...[
                          Text('📍 ${widget.req.area}',
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                          const SizedBox(width: 12),
                        ],
                        Text('${widget.req.finalPrice > 0 ? widget.req.finalPrice : widget.req.price} ${s.t('egp')}',
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                            color: RqwstColors.brand.withValues(alpha: 0.9))),
                      ]),
                    ]),
                  ),

                  // Primary action button
                  if (!isProvider) ...[
                    if (isSearching && _offers.isNotEmpty)
                      _DarkBtn(
                        label: '${s.t('viewOffers')} (${_offers.length})',
                        icon: Icons.search,
                        color: RqwstColors.brand,
                        onTap: _openDetail,
                        full: true,
                      )
                    else if (isAccepted && widget.req.threadId != null)
                      _DarkBtn(
                        label: s.t('openChatNow'),
                        icon: Icons.chat_bubble_outline,
                        color: RqwstColors.invert,
                        onTap: () => _openChat(widget.req.threadId!),
                        full: true,
                      ),
                  ] else ...[
                    if (widget.req.threadId != null)
                      _DarkBtn(
                        label: s.t('openChat'),
                        icon: Icons.chat_bubble_outline,
                        color: RqwstColors.invert,
                        onTap: () => _openChat(widget.req.threadId!),
                        full: true,
                      ),
                    if (_canComplete(widget.req)) ...[
                      const SizedBox(height: 8),
                      _DarkBtn(
                        label: rtl ? 'الطلب اكتمل' : s.t('markDone'),
                        icon: Icons.check,
                        color: RqwstColors.brand.withValues(alpha: 0.7),
                        onTap: _completeReq,
                        full: true,
                        outlined: true,
                      ),
                    ],
                  ],

                  // Cancel button
                  if (_canCancel(widget.req)) ...[
                    const SizedBox(height: 8),
                    _DarkBtn(
                      label: s.t('cancelReq'),
                      icon: Icons.close,
                      color: RqwstColors.rose.withValues(alpha: 0.8),
                      onTap: _cancelReq,
                      full: true,
                      outlined: true,
                    ),
                  ],
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  String _fmtTime(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

// ── Animated concentric rings ─────────────────────────────────────────────────
class _AnimatedRings extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  final int count;
  const _AnimatedRings({required this.ctrl, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Center(
        child: Stack(alignment: Alignment.center, children: [
          for (int i = 0; i < count; i++)
            _Ring(
              size: 120.0 + i * 80,
              opacity: math.max(0, 0.22 - i * 0.05 + math.sin(ctrl.value * 2 * math.pi + i * 0.4) * 0.05),
              color: color,
            ),
        ]),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _Ring({required this.size, required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color.withValues(alpha: opacity), width: 1),
    ),
  );
}

// ── Stage progress strip ──────────────────────────────────────────────────────
class _StageStrip extends StatelessWidget {
  final String stage;
  final bool isProvider;
  final AppState s;
  const _StageStrip({required this.stage, required this.isProvider, required this.s});

  @override
  Widget build(BuildContext context) {
    final accentColor = isProvider ? RqwstColors.invert : RqwstColors.brand;
    final activeIdx = stage == 'accepted' ? 2 : 1;
    final stages = [s.t('stagePosted'), s.t('stageBidding'), s.t('stageAccepted'), s.t('stageDone')];

    return SizedBox(
      width: 320,
      child: Row(
        children: List.generate(stages.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final idx = (i - 1) ~/ 2;
            return Expanded(child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 20),
              color: idx < activeIdx ? accentColor : Colors.white.withValues(alpha: 0.1),
            ));
          } else {
            final idx = i ~/ 2;
            final active = idx <= activeIdx;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: active ? accentColor : Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('${idx + 1}',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800,
                    color: active ? Colors.white : Colors.white.withValues(alpha: 0.3)))),
              ),
              const SizedBox(height: 5),
              Text(stages[idx],
                style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700,
                  color: active ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.3))),
            ]);
          }
        }),
      ),
    );
  }
}

// ── Dark-themed action button ─────────────────────────────────────────────────
class _DarkBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool full;
  final bool outlined;

  const _DarkBtn({
    required this.label, required this.icon, required this.color,
    required this.onTap, this.full = false, this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: full ? double.infinity : null,
      height: outlined ? 44 : 52,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: outlined ? color.withValues(alpha: 0.12) : color,
            borderRadius: BorderRadius.circular(16),
            border: outlined ? Border.all(color: color.withValues(alpha: 0.4)) : null,
            boxShadow: outlined ? null : [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white.withValues(alpha: outlined ? 0.9 : 1), size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.cairo(fontSize: outlined ? 14 : 16, fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: outlined ? 0.9 : 1))),
          ]),
        ),
      ),
    );
  }
}


// ============================================================
// SOURCE: lib/screens/chat_screen.dart
// ============================================================


// ── Chat list screen ───────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadThreads());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('chat'), style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined, size: 20), onPressed: s.loadThreads),
        ],
      ),
      body: s.user == null
          ? EmptyState(
              emoji: '🔒',
              label: rtl ? 'سجّل دخولك الأول' : 'Login required',
              action: BrandButton(label: s.t('login'), onTap: () =>
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (_) => const AuthSheet())))
          : s.threadsLoading && s.threads.isEmpty
              ? ListView.builder(padding: const EdgeInsets.all(14), itemCount: 4,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: ShimmerBox(height: 72)))
              : RefreshIndicator(
                  onRefresh: s.loadThreads,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                    itemCount: s.threads.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 0) return _SupportBtn(s: s);
                      return Padding(padding: const EdgeInsets.only(bottom: 8),
                        child: _ThreadTile(thread: s.threads[i - 1], s: s));
                    },
                  ),
                ),
    );
  }
}

class _SupportBtn extends StatelessWidget {
  final AppState s;
  const _SupportBtn({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RqwstCard(
        onTap: () => _openSupport(context, s),
        background: RqwstColors.invert.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: RqwstColors.invert, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rtl ? 'تواصل مع الدعم' : 'Contact Support',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
            Text(rtl ? 'بلّغ عن مشكلة أو اسأل سؤال' : 'Report a problem or ask a question',
              style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ])),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final ChatThread thread;
  final AppState s;
  const _ThreadTile({required this.thread, required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;
    final isDone = ['completed', 'done'].contains(thread.requestState);
    final isActive = ['accepted', 'in_progress'].contains(thread.requestState);
    final isCancelled = ['cancelled', 'canceled'].contains(thread.requestState);

    String statusLabel = '';
    String statusColor = 'slate';
    if (isDone) { statusLabel = rtl ? '✓ مكتمل' : '✓ Done'; statusColor = 'green'; }
    else if (isActive) { statusLabel = rtl ? '⚡ نشط' : '⚡ Active'; statusColor = 'invert'; }
    else if (isCancelled) { statusLabel = rtl ? 'ملغي' : 'Cancelled'; statusColor = 'red'; }
    else if (thread.requestState != null) { statusLabel = rtl ? 'جاري' : 'Active'; statusColor = 'amber'; }

    String preview = thread.lastMsgType == 'voice'
        ? (rtl ? '🎙️ رسالة صوتية' : '🎙️ Voice note')
        : (thread.lastMessage ?? thread.requestDescription ?? '');

    Color avatarBg = thread.isRequester ? RqwstColors.brand : RqwstColors.invert.withValues(alpha: 0.85);
    if (thread.isSupport) avatarBg = RqwstColors.invert;

    return RqwstCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: s,
          child: ChatDetailScreen(
            threadId: thread.id,
            requestId: thread.requestId,
            peerName: thread.peerName,
            isSupport: thread.isSupport,
          ),
        ),
      )),
      padding: const EdgeInsets.all(13),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
          child: Icon(thread.isSupport ? Icons.support_agent : Icons.person, color: Colors.white, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Row(children: [
              Flexible(child: Text(thread.peerName,
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
              if (!thread.isSupport) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: thread.isRequester ? RqwstColors.brandL : RqwstColors.invertL,
                    borderRadius: BorderRadius.circular(999)),
                  child: Text(thread.isRequester ? (rtl ? 'طالب' : 'Client') : (rtl ? 'مزود' : 'Provider'),
                    style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w800,
                      color: thread.isRequester ? RqwstColors.brand : RqwstColors.invert)),
                ),
              ],
            ])),
            if (statusLabel.isNotEmpty) StatusPill(label: statusLabel, color: statusColor),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            Expanded(child: Text(preview,
              style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              overflow: TextOverflow.ellipsis)),
            if (thread.finalPrice != null)
              Text('${thread.finalPrice} ${rtl ? 'ج' : 'EGP'}',
                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: RqwstColors.brand)),
          ]),
        ])),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
      ]),
    );
  }
}

// ── Support chat opener ────────────────────────────────────────────────────────
void _openSupport(BuildContext context, AppState s) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: s,
      child: const _SupportSheet(),
    ),
  );
}

class _SupportSheet extends StatefulWidget {
  const _SupportSheet();
  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<_SupportSheet> {
  final _msgCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _msgs = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() { _msgCtrl.dispose(); _subjectCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final j = await ApiService.call('support.get');
      if (mounted) setState(() => _msgs = List<Map<String, dynamic>>.from(j['data']?['messages'] ?? []));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
    _scrollBottom();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ApiService.call('support.send', {
        'message': text,
        if (_msgs.isEmpty) 'subject': _subjectCtrl.text.trim(),
      });
      _msgCtrl.clear();
      await _load();
    } catch (_) {}
    setState(() => _sending = false);
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final rtl = s.isRTL;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: RqwstColors.invert, shape: BoxShape.circle),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rtl ? 'الدعم الفني' : 'Support', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900)),
              Text(rtl ? 'فريقنا هنا يساعدك' : 'Our team is here to help',
                style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            ]),
          ]),
        ),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: RqwstColors.invert))
            : _msgs.isEmpty
                ? Center(child: Text(rtl ? 'ابعت رسالتك وهنرد عليك في أقرب وقت' : 'Send your message and we will reply soon',
                    style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    textAlign: TextAlign.center))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) {
                      final m = _msgs[i];
                      final isAdmin = m['sender'] == 'admin';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : RqwstColors.invert,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isAdmin ? const Radius.circular(4) : const Radius.circular(16),
                                bottomRight: isAdmin ? const Radius.circular(16) : const Radius.circular(4),
                              ),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              if (isAdmin) Text(rtl ? '👮 الدعم' : '👮 Support',
                                style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
                              Text(m['body'] as String? ?? '',
                                style: GoogleFonts.cairo(fontSize: 14, color: isAdmin ? null : Colors.white)),
                              const SizedBox(height: 3),
                              Text((m['created_at'] as String? ?? '').length >= 16
                                  ? (m['created_at'] as String).substring(11, 16) : '',
                                style: GoogleFonts.cairo(fontSize: 10,
                                  color: isAdmin
                                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.55))),
                            ]),
                          ),
                        ),
                      );
                    },
                  )),

        // Subject (first message only)
        if (_msgs.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _subjectCtrl,
              decoration: InputDecoration(hintText: rtl ? 'موضوع المشكلة أو السؤال' : 'Subject of your issue',
                hintStyle: GoogleFonts.cairo()),
              style: GoogleFonts.cairo(),
            ),
          ),

        // Input bar
        Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
          ),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              maxLines: 3, minLines: 1,
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(hintText: rtl ? 'اكتب رسالتك هنا…' : 'Type your message here…',
                hintStyle: GoogleFonts.cairo()),
              style: GoogleFonts.cairo(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(width: 42, height: 42,
                decoration: BoxDecoration(color: RqwstColors.invert, borderRadius: BorderRadius.circular(12)),
                child: _sending
                    ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white, size: 18)),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Chat detail screen — full port of the chat overlay from app.js
// ══════════════════════════════════════════════════════════════════════════════
class ChatDetailScreen extends StatefulWidget {
  final int threadId;
  final int? requestId;
  final String peerName;
  final bool isSupport;

  const ChatDetailScreen({
    super.key,
    required this.threadId,
    this.requestId,
    required this.peerName,
    this.isSupport = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  List<ChatMessage> _msgs = [];
  Map<String, dynamic>? _summary;   // request summary card
  Map<String, dynamic>? _thread;    // thread info (closed state)
  bool _loading = false;
  bool _sending = false;
  int _lastSigId = 0;
  Timer? _poll;

  // Voice state
  bool _recording = false;
  int _recSec = 0;
  String? _recPath;  // path after stopping, before sending

  // Call state mirror
  late CallState _call;

  @override
  void initState() {
    super.initState();
    _call = CallService.state;
    CallService.onStateChanged = () { if (mounted) setState(() => _call = CallService.state); };
    VoiceService.onTick = () { if (mounted) setState(() => _recSec = VoiceService.recSec); };
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _fetch());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _poll?.cancel();
    CallService.onStateChanged = null;
    VoiceService.onTick = null;
    super.dispose();
  }

  // ── Fetch messages (port of fetchChat()) ──────────────────────────────────
  Future<void> _fetch() async {
    if (_loading) return;
    _loading = true;
    try {
      final s = context.read<AppState>();
      final j = await ApiService.call('chat.messages', {
        'thread_id': widget.threadId,
        'after_signal': _lastSigId,
      });
      final uid = s.user?.id ?? 0;
      final raw = (j['data']?['messages'] ?? []) as List;

      // Parse system messages (port of parseSysMsg)
      final newMsgs = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final sId = int.tryParse(m['sender_id']?.toString() ?? '') ?? -1;
        if (sId == 0 && (m['body'] as String? ?? '').trim().startsWith('{')) {
          try {
            final parsed = jsonDecode(m['body'] as String);
            m['_sys'] = parsed['sys'] ?? parsed['t'];
            m['_duration'] = parsed['duration'];
          } catch (_) {}
        }
        m['_mine'] = sId == uid;
        return m;
      }).toList();

      bool added = false;
      for (final m in newMsgs) {
        if (!_msgs.any((x) => x.id == (m['id'] as int? ?? 0))) {
          _msgs.add(_mapToMsg(m, uid));
          added = true;
        }
      }

      if (j['data']?['last_signal_id'] != null) {
        _lastSigId = j['data']['last_signal_id'];
      }
      _summary = j['data']?['request'] as Map<String, dynamic>?;
      _thread = j['data']?['thread'] as Map<String, dynamic>?;

      // Handle WebRTC signals
      await CallService.handleSignals(
        newMsgs.where((m) => (m['signal_type'] as String? ?? '').isNotEmpty).toList(),
        widget.threadId, uid,
      );

      if (mounted && added) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
        });
      }
    } catch (_) {}
    _loading = false;
  }

  // ── Send text ──────────────────────────────────────────────────────────────
  Future<void> _sendText() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      await ApiService.call('chat.send', {'thread_id': widget.threadId, 'message': text});
      await _fetch();
    } catch (_) {}
    setState(() => _sending = false);
  }

  // ── Voice note ─────────────────────────────────────────────────────────────
  Future<void> _startVoice() async {
    final ok = await VoiceService.startRecording();
    if (ok) setState(() { _recording = true; _recSec = 0; });
    else _toast(context.read<AppState>().t('micBlocked'));
  }

  Future<void> _stopVoice() async {
    final path = await VoiceService.stopRecording();
    setState(() { _recording = false; _recPath = path; });
  }

  Future<void> _sendVoice() async {
    if (_recPath == null) return;
    setState(() => _sending = true);
    try {
      await MediaService.sendVoiceNote(widget.threadId, _recPath!);
      setState(() => _recPath = null);
      await _fetch();
    } catch (_) {}
    setState(() => _sending = false);
  }

  void _clearVoice() {
    VoiceService.clearRecording();
    setState(() { _recPath = null; _recording = false; });
  }

  // ── Send location ──────────────────────────────────────────────────────────
  Future<void> _sendLocation() async {
    final s = context.read<AppState>();
    _toast(s.isRTL ? 'جاري تحديد موقعك…' : 'Getting your location…');
    final loc = await LocationService.getForChat();
    if (loc == null) { _toast(s.isRTL ? 'تعذّر تحديد الموقع' : 'Could not get location'); return; }
    try {
      await ApiService.call('chat.send', {
        'thread_id': widget.threadId,
        'message': jsonEncode({'type': 'location', 'lat': loc.lat.toStringAsFixed(6), 'lng': loc.lng.toStringAsFixed(6)}),
        'msg_type': 'location',
      });
      await _fetch();
      _toast(s.isRTL ? 'اتبعت الموقع ✓' : 'Location sent ✓');
    } catch (_) {}
  }

  // ── Send image ─────────────────────────────────────────────────────────────
  Future<void> _sendImage() async {
    final file = await MediaService.pickChatImage();
    if (file == null) return;
    setState(() => _sending = true);
    try {
      await MediaService.sendChatImage(widget.threadId, file);
      await _fetch();
    } catch (_) {}
    setState(() => _sending = false);
  }

  // ── Complete request ───────────────────────────────────────────────────────
  Future<void> _complete() async {
    final s = context.read<AppState>();
    final rid = _summary?['id'] as int? ?? widget.requestId;
    if (rid == null) return;
    final rtl = s.isRTL;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(rtl ? 'الطلب خلص؟' : 'Request complete?', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
      content: Text(rtl ? 'هتأكد إن كل حاجة تمت' : 'Confirm everything went well', style: GoogleFonts.cairo()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.t('back'), style: GoogleFonts.cairo())),
        TextButton(onPressed: () => Navigator.pop(context, true),
          child: Text(rtl ? 'أيوه، خلص' : 'Yes, done',
            style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w700))),
      ],
    ));
    if (ok != true || !mounted) return;
    try {
      final myId = s.user?.id ?? 0;
      final j = await ApiService.call('requests.complete', {'request_id': rid});
      await s.loadMyReqs();
      _toast(s.t('reqCompleted'));
      await _fetch();
      final srvReq = j['data']?['req'] ?? {};
      final providerId = srvReq['provider_id'] as int?;
      final requesterId = srvReq['user_id'] as int?;
      if (mounted && myId == requesterId && providerId != null && providerId != myId) {
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => ChangeNotifierProvider.value(value: s,
            child: RatingSheet(requestId: rid, toUserId: providerId)));
      }
    } catch (_) {}
  }

  // ── Delivery status update ─────────────────────────────────────────────────
  Future<void> _updateDeliveryStatus(String status) async {
    final rid = _summary?['id'] as int? ?? widget.requestId;
    if (rid == null) return;
    try {
      await ApiService.call('requests.update_delivery_status', {'request_id': rid, 'delivery_status': status});
      await _fetch();
    } catch (_) {}
  }

  void _toast(String msg) => context.read<AppState>().toast(msg, 'info');

  bool get _isClosed => _thread?['status'] == 'closed';
  bool get _isDelivery => _summary?['type'] == 'توصيل';
  bool get _isProvider => context.read<AppState>().isProv;
  bool get _canComplete {
    final state = _summary?['state'] as String? ?? '';
    return state == 'accepted' || state == 'in_progress';
  }

  static ChatMessage _mapToMsg(Map<String, dynamic> m, int uid) {
    return ChatMessage.fromJson(m, uid);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [
        // ── Header ────────────────────────────────────────────────────────────
        _ChatHeader(
          peerName: widget.peerName,
          summary: _summary,
          isClosed: _isClosed,
          isProvider: _isProvider,
          canComplete: _canComplete,
          call: _call,
          rtl: rtl,
          s: s,
          onBack: () => Navigator.pop(context),
          onStartCall: () => CallService.startCall(widget.threadId),
          onEndCall: () => CallService.endCall(widget.threadId),
          onComplete: _complete,
        ),

        // ── Delivery status bar ────────────────────────────────────────────────
        if (_isDelivery && !_isClosed && _summary != null)
          _DeliveryStatusBar(
            summary: _summary!,
            isProvider: _isProvider,
            rtl: rtl,
            onUpdate: _updateDeliveryStatus,
          ),

        // ── Full-screen call overlay ───────────────────────────────────────────
        if (_call.active)
          _CallOverlay(
            call: _call,
            peerName: widget.peerName,
            threadId: widget.threadId,
            rtl: rtl,
            s: s,
          ),

        // ── Request summary card ───────────────────────────────────────────────
        if (_summary != null && (_summary!['description'] as String? ?? '').isNotEmpty && !_call.active)
          _RequestSummaryCard(summary: _summary!, rtl: rtl, s: s),

        // ── Messages ─────────────────────────────────────────────────────────────
        if (!_call.active)
          Expanded(child: _msgs.isEmpty
              ? Center(child: Text(rtl ? 'ابعت أول رسالة!' : 'Send the first message!',
                  style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) => _MsgBubble(msg: _msgs[i], s: s, threadId: widget.threadId, onComplete: _complete, summary: _summary),
                )),

        if (!_call.active) ...[
          // ── Voice preview bar (after recording, before send) ─────────────────
          if (_recPath != null)
            _VoicePreviewBar(path: _recPath!, rtl: rtl, s: s, sending: _sending, onSend: _sendVoice, onClear: _clearVoice),

          // ── Recording bar ──────────────────────────────────────────────────────
          if (_recording)
            _RecordingBar(recSec: _recSec, rtl: rtl, onStop: _stopVoice, s: s),

          // ── Chat closed banner ─────────────────────────────────────────────────
          if (_isClosed)
            _ClosedBanner(thread: _thread, rtl: rtl),

          // ── Input bar ──────────────────────────────────────────────────────────
          if (!_isClosed && !_recording && _recPath == null)
            _InputBar(
              ctrl: _ctrl,
              rtl: rtl,
              sending: _sending,
              s: s,
              onSend: _sendText,
              onVoice: _startVoice,
              onImage: _sendImage,
              onLocation: _sendLocation,
            ),
        ],
      ]),
    );
  }
}

// ── Chat header ────────────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final String peerName;
  final Map<String, dynamic>? summary;
  final bool isClosed, isProvider, canComplete;
  final CallState call;
  final bool rtl;
  final AppState s;
  final VoidCallback onBack, onComplete;
  final Future<void> Function() onStartCall, onEndCall;

  const _ChatHeader({
    required this.peerName, this.summary, required this.isClosed,
    required this.isProvider, required this.canComplete, required this.call,
    required this.rtl, required this.s, required this.onBack,
    required this.onStartCall, required this.onEndCall, required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final state = summary?['state'] as String? ?? '';
    final isActive = state == 'accepted' || state == 'in_progress';
    final isDone = state == 'completed' || state == 'done';

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
        ),
        child: Row(children: [
          // Back
          IconButton(icon: Icon(rtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, size: 18),
            onPressed: onBack, padding: const EdgeInsets.all(8)),
          // Peer name + description
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(peerName, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis),
            if (summary?['description'] != null)
              Row(children: [
                Flexible(child: Text((summary!['description'] as String).substring(0,
                    (summary!['description'] as String).length.clamp(0, 40)),
                  style: GoogleFonts.cairo(fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  overflow: TextOverflow.ellipsis)),
                if (isDone) ...[
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(color: RqwstColors.brandL, borderRadius: BorderRadius.circular(999)),
                    child: Text(rtl ? '✓ مكتمل' : '✓ Done',
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: RqwstColors.brand))),
                ],
              ]),
          ])),

          // Call button (not in call, not closed)
          if (!isClosed && !call.active)
            GestureDetector(
              onTap: onStartCall,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: RqwstColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.25)),
                ),
                child: Column(children: [
                  const Icon(Icons.call, color: RqwstColors.brand, size: 17),
                  const SizedBox(height: 2),
                  Text(rtl ? 'مجاني' : 'Call', style: GoogleFonts.cairo(
                    fontSize: 9, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
                ]),
              ),
            ),

          // Mark done button (in-call hidden too)
          if (!isClosed && !call.active && canComplete && isActive) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onComplete,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: RqwstColors.invert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RqwstColors.invert.withValues(alpha: 0.25)),
                ),
                child: Column(children: [
                  const Icon(Icons.check, color: RqwstColors.invert, size: 17),
                  const SizedBox(height: 2),
                  Text(rtl ? 'اكتمل الطلب' : 'Done', style: GoogleFonts.cairo(
                    fontSize: 9, fontWeight: FontWeight.w800, color: RqwstColors.invert)),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Delivery status bar ────────────────────────────────────────────────────────
class _DeliveryStatusBar extends StatelessWidget {
  final Map<String, dynamic> summary;
  final bool isProvider, rtl;
  final Future<void> Function(String) onUpdate;
  const _DeliveryStatusBar({required this.summary, required this.isProvider, required this.rtl, required this.onUpdate});

  static const _stages = [
    (id: 'pickup',     label: 'استلام',     icon: '📦'),
    (id: 'on_the_way', label: 'في الطريق',  icon: '🚗'),
    (id: 'delivered',  label: 'تم التسليم', icon: '✅'),
  ];

  bool _isReached(String current, String stage) {
    final order = ['pickup', 'on_the_way', 'delivered'];
    return order.indexOf(current) >= order.indexOf(stage);
  }

  @override
  Widget build(BuildContext context) {
    final pickup = summary['pickup_address'] as String? ?? '';
    final dropoff = summary['dropoff_address'] as String? ?? '';
    final km = summary['delivery_km'];
    final deliveryStatus = summary['delivery_status'] as String? ?? '';
    final state = summary['state'] as String? ?? '';
    final canUpdate = isProvider && (state == 'accepted' || state == 'in_progress') && deliveryStatus != 'delivered';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
      ),
      child: Column(children: [
        // Route line
        if (pickup.isNotEmpty) Row(children: [
          const Text('📍', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(child: Text(pickup, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          const Text('→', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          const Text('🏁', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(child: Text(dropoff, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          if (km != null)
            Container(margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: RqwstColors.brandL, borderRadius: BorderRadius.circular(999)),
              child: Text('$km كم', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: RqwstColors.brand))),
        ]),
        const SizedBox(height: 10),

        // Stage pills
        Row(children: [
          for (int i = 0; i < _stages.length; i++) ...[
            Expanded(child: GestureDetector(
              onTap: canUpdate ? () => onUpdate(_stages[i].id) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _isReached(deliveryStatus, _stages[i].id) ? RqwstColors.brand : RqwstColors.brandL.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: deliveryStatus == _stages[i].id ? RqwstColors.brand : RqwstColors.brand.withValues(alpha: 0.2)),
                ),
                child: Column(children: [
                  Text(_stages[i].icon, style: const TextStyle(fontSize: 14)),
                  Text(_stages[i].label, style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w800,
                    color: _isReached(deliveryStatus, _stages[i].id) ? Colors.white : RqwstColors.brand.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center),
                ]),
              ),
            )),
            if (i < 2)
              Container(width: 12, height: 2, margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ],
        ]),
      ]),
    );
  }
}

// ── Full-screen call overlay ───────────────────────────────────────────────────
class _CallOverlay extends StatelessWidget {
  final CallState call;
  final String peerName;
  final int threadId;
  final bool rtl;
  final AppState s;
  const _CallOverlay({required this.call, required this.peerName, required this.threadId, required this.rtl, required this.s});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: call.inCall
              ? const [Color(0xFF0F3022), Color(0xFF1A4A30)]
              : const [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Avatar
        Container(width: 90, height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2)),
          child: const Icon(Icons.person, color: Colors.white70, size: 44)),
        const SizedBox(height: 14),

        // Direction label
        if (call.ringing && !call.inCall)
          Text(rtl ? 'مكالمة واردة من' : 'INCOMING FROM',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.5)),
        if (call.outgoing && !call.inCall)
          Text(rtl ? 'جاري الاتصال بـ' : 'CALLING',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.5)),
        if (call.inCall)
          Text(rtl ? 'متصل' : 'CONNECTED',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: RqwstColors.brand.withValues(alpha: 0.8))),
        const SizedBox(height: 6),

        // Peer name
        Text(peerName, style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 8),

        // Status sub-label
        if (call.outgoing && !call.inCall)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(
              color: Colors.white.withValues(alpha: 0.7), strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(rtl ? 'في انتظار الرد…' : 'Waiting for answer…',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
          ]),
        if (call.ringing && !call.inCall)
          Text(rtl ? 'يتصل بك…' : 'is calling you…',
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
        if (call.inCall)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(CallService.fmtDur(call.duration),
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: RqwstColors.brand.withValues(alpha: 0.9))),
          ]),

        const SizedBox(height: 40),

        // Action buttons
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (call.ringing && !call.inCall) ...[
            // Incoming: reject + answer
            _CallBtn(icon: Icons.call_end, color: RqwstColors.rose, size: 66,
              onTap: () => CallService.rejectCall(threadId)),
            const SizedBox(width: 24),
            _CallBtn(icon: Icons.call, color: RqwstColors.brand, size: 72,
              onTap: () => CallService.answerCall(threadId), pulse: true),
          ] else ...[
            // Speaker toggle
            Column(children: [
              _CallBtn(
                icon: call.loudspeaker ? Icons.volume_up : Icons.volume_down,
                color: Colors.white.withValues(alpha: call.loudspeaker ? 0.25 : 0.1),
                size: 56,
                onTap: CallService.toggleSpeaker,
                border: true,
              ),
              const SizedBox(height: 6),
              Text(call.loudspeaker ? (rtl ? 'سماعة عالية' : 'Speaker') : (rtl ? 'سماعة عادية' : 'Earpiece'),
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
            ]),
            const SizedBox(width: 24),
            // End call
            Column(children: [
              _CallBtn(icon: Icons.call_end, color: RqwstColors.rose, size: 66,
                onTap: () => CallService.endCall(threadId)),
              const SizedBox(height: 6),
              Text(s.t('endCall'), style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
            ]),
          ],
        ]),
      ]),
    ));
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool pulse;
  final bool border;
  const _CallBtn({required this.icon, required this.color, required this.size, required this.onTap, this.pulse = false, this.border = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5) : null,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: pulse ? 24 : 16)],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.4),
    ),
  );
}

// ── Request summary card (top of chat) ────────────────────────────────────────
class _RequestSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final bool rtl;
  final AppState s;
  const _RequestSummaryCard({required this.summary, required this.rtl, required this.s});

  @override
  Widget build(BuildContext context) {
    final state = summary['state'] as String? ?? '';
    String statusLabel = '';
    String statusColor = 'slate';
    switch (state) {
      case 'bidding': statusLabel = s.t('bidding'); statusColor = 'amber'; break;
      case 'accepted': case 'in_progress': statusLabel = s.t('accepted'); statusColor = 'invert'; break;
      case 'completed': case 'done': statusLabel = s.t('completed'); statusColor = 'green'; break;
      case 'cancelled': case 'canceled': statusLabel = s.t('cancelled'); statusColor = 'red'; break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [RqwstColors.brandL, RqwstColors.invert.withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RqwstColors.brand.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.assignment_outlined, size: 11, color: RqwstColors.brand),
          const SizedBox(width: 5),
          Text(rtl ? 'تفاصيل الطلب' : 'Request Details',
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: RqwstColors.brand)),
        ]),
        const SizedBox(height: 4),
        Text(summary['description'] as String? ?? '',
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Row(children: [
          Text('${summary['final_price'] ?? summary['price'] ?? 0} ${s.t('egp')}',
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: RqwstColors.brand)),
          if (summary['area'] != null) ...[
            const SizedBox(width: 12),
            Text('📍 ${summary['area']}',
              style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
          if (statusLabel.isNotEmpty) ...[
            const SizedBox(width: 12),
            StatusPill(label: statusLabel, color: statusColor),
          ],
        ]),
      ]),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────────
class _MsgBubble extends StatelessWidget {
  final ChatMessage msg;
  final AppState s;
  final int threadId;
  final VoidCallback onComplete;
  final Map<String, dynamic>? summary;
  const _MsgBubble({required this.msg, required this.s, required this.threadId, required this.onComplete, this.summary});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;

    // ── System message (sender_id == 0) ──────────────────────────────────────
    if (msg.body.startsWith('{') || msg.senderName.isEmpty) {
      Map<String, dynamic>? parsed;
      try { parsed = jsonDecode(msg.body); } catch (_) {}
      final sys = parsed?['sys'] ?? parsed?['t'];
      final dur = parsed?['duration'] as int?;

      String sysText = '';
      Widget? sysAction;

      if (sys == 'offer_accepted' || sys == 'request_accepted') {
        sysText = '${sys == 'offer_accepted' ? '✅' : '⚡'} ${rtl ? (sys == 'offer_accepted' ? 'تم قبول العرض' : 'تم قبول الطلب') : (sys == 'offer_accepted' ? 'Offer accepted' : 'Request accepted')}';
      } else if (sys == 'call_ended') {
        sysText = '📞 ${rtl ? 'مكالمة' : 'Call'}${dur != null ? ' · ${CallService.fmtDur(dur)}' : ''}';
      } else if (sys == 'completed') {
        sysText = '🎉 ${rtl ? 'اكتمل الطلب' : 'Request completed'}';
      } else if (sys == 'cancelled') {
        sysText = '⛔ ${rtl ? 'اتلغى الطلب' : 'Request cancelled'}';
      } else if (sys == 'complete_pending') {
        final rid = summary?['id'] as int?;
        sysText = '🏁 ${rtl ? 'طرف أكد الإنهاء' : 'One party confirmed completion'}';
        sysAction = TextButton(
          onPressed: onComplete,
          child: Text(rtl ? 'خلّصت أنا كمان ✓' : 'Done too ✓',
            style: GoogleFonts.cairo(color: RqwstColors.brand, fontWeight: FontWeight.w800)));
      } else {
        sysText = msg.body;
      }

      if (sysText.isEmpty && sysAction == null) return const SizedBox.shrink();

      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(sysText, style: GoogleFonts.cairo(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center),
            if (sysAction != null) sysAction,
          ]),
        ),
      ));
    }

    final mine = msg.isMine;

    // ── Message content ────────────────────────────────────────────────────────
    Widget content;
    if (msg.type == 'voice' || msg.voiceUrl != null) {
      content = _VoiceBubble(url: msg.voiceUrl, mine: mine, rtl: rtl, s: s);
    } else if (msg.type == 'image' || msg.imageUrl != null) {
      content = _ImageBubble(url: msg.imageUrl ?? '', mine: mine);
    } else if (msg.type == 'location') {
      Map<String, dynamic>? loc;
      try { loc = jsonDecode(msg.body); } catch (_) {}
      if (loc != null) {
        content = _LocationBubble(lat: loc['lat'].toString(), lng: loc['lng'].toString(), mine: mine, rtl: rtl);
      } else {
        content = Text(msg.body, style: GoogleFonts.cairo(fontSize: 14, color: mine ? Colors.white : null));
      }
    } else {
      content = Text(msg.body.isNotEmpty ? msg.body : '…',
        style: GoogleFonts.cairo(fontSize: 14, color: mine ? Colors.white : null));
    }

    // Timestamp

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            Container(width: 28, height: 28, decoration: BoxDecoration(
              color: RqwstColors.invert.withValues(alpha: 0.7), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 14)),
            const SizedBox(width: 6),
          ],
          Flexible(child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: msg.type == 'image' || msg.imageUrl != null
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: mine ? RqwstColors.brand : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: mine ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: mine ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                ),
                child: content,
              ),
              const SizedBox(height: 2),
              // Timestamp (from created_at)
            ],
          )),
          if (mine) const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  final String? url;
  final bool mine, rtl;
  final AppState s;
  const _VoiceBubble({this.url, required this.mine, required this.rtl, required this.s});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: url != null ? () => VoiceService.playVoice(url!) : null,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.play_circle_filled, size: 28, color: mine ? Colors.white : RqwstColors.brand),
      const SizedBox(width: 8),
      Text(s.isRTL ? 'رسالة صوتية' : 'Voice note',
        style: GoogleFonts.cairo(fontSize: 13, color: mine ? Colors.white : null)),
    ]),
  );
}

class _ImageBubble extends StatelessWidget {
  final String url;
  final bool mine;
  const _ImageBubble({required this.url, required this.mine});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => launchUrl(Uri.parse(url)),
    child: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: mine ? const Radius.circular(18) : const Radius.circular(4),
        bottomRight: mine ? const Radius.circular(4) : const Radius.circular(18),
      ),
      child: Image.network(url, width: 200, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200, height: 120, color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey))),
    ),
  );
}

class _LocationBubble extends StatelessWidget {
  final String lat, lng;
  final bool mine, rtl;
  const _LocationBubble({required this.lat, required this.lng, required this.mine, required this.rtl});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => launchUrl(Uri.parse('https://www.google.com/maps?q=$lat,$lng')),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mine ? Colors.white.withValues(alpha: 0.15) : RqwstColors.brandL,
        borderRadius: BorderRadius.circular(10),
        border: mine ? null : Border.all(color: RqwstColors.brand.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 34, height: 34,
          decoration: BoxDecoration(
            color: mine ? Colors.white.withValues(alpha: 0.2) : RqwstColors.brand,
            shape: BoxShape.circle),
          child: Icon(Icons.location_on, color: Colors.white, size: 18)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rtl ? 'الموقع الحالي' : 'Current Location',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
              color: mine ? Colors.white : null)),
          Text(rtl ? 'اضغط لفتح الخريطة' : 'Tap to open maps',
            style: GoogleFonts.cairo(fontSize: 11, color: mine ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ]),
        const SizedBox(width: 10),
        Icon(Icons.open_in_new, size: 14, color: mine ? Colors.white70 : RqwstColors.brand),
      ]),
    ),
  );
}

// ── Voice preview bar ─────────────────────────────────────────────────────────
class _VoicePreviewBar extends StatelessWidget {
  final String path;
  final bool rtl, sending;
  final AppState s;
  final VoidCallback onSend, onClear;
  const _VoicePreviewBar({required this.path, required this.rtl, required this.sending, required this.s, required this.onSend, required this.onClear});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
    ),
    child: Row(children: [
      // Play button
      GestureDetector(
        onTap: () => VoiceService.playVoice(path),
        child: Container(width: 36, height: 36,
          decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20)),
      ),
      const SizedBox(width: 8),
      // Waveform placeholder
      Expanded(child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: RqwstColors.brandL,
          borderRadius: BorderRadius.circular(999)),
        child: Center(child: Text(rtl ? '🎙️ جاهزة للإرسال' : '🎙️ Ready to send',
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: RqwstColors.brand))),
      )),
      const SizedBox(width: 8),
      // Clear
      GestureDetector(onTap: onClear,
        child: Container(width: 32, height: 32,
          decoration: BoxDecoration(color: RqwstColors.roseL, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.close, size: 16, color: RqwstColors.rose))),
      const SizedBox(width: 6),
      // Send voice
      BrandButton(label: s.t('sendVoice'), small: true, loading: sending, onTap: onSend),
    ]),
  );
}

// ── Recording bar ─────────────────────────────────────────────────────────────
class _RecordingBar extends StatelessWidget {
  final int recSec;
  final bool rtl;
  final VoidCallback onStop;
  final AppState s;
  const _RecordingBar({required this.recSec, required this.rtl, required this.onStop, required this.s});

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final r = sec % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
    decoration: BoxDecoration(
      color: RqwstColors.rose.withValues(alpha: 0.05),
      border: Border(top: BorderSide(color: RqwstColors.rose.withValues(alpha: 0.2))),
    ),
    child: Row(children: [
      Container(width: 8, height: 8,
        decoration: const BoxDecoration(color: RqwstColors.rose, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(_fmt(recSec), style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: RqwstColors.rose)),
      const SizedBox(width: 10),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: (recSec / 120).clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation(RqwstColors.rose),
          minHeight: 3),
      )),
      const SizedBox(width: 10),
      ElevatedButton.icon(
        onPressed: onStop,
        icon: const Icon(Icons.stop, size: 14),
        label: Text(s.t('stopRec'), style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: RqwstColors.rose, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: const StadiumBorder()),
      ),
    ]),
  );
}

// ── Chat closed banner ─────────────────────────────────────────────────────────
class _ClosedBanner extends StatelessWidget {
  final Map<String, dynamic>? thread;
  final bool rtl;
  const _ClosedBanner({this.thread, required this.rtl});

  @override
  Widget build(BuildContext context) {
    final isCompleted = thread?['closed_reason'] == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: isCompleted ? RqwstColors.brand.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(
          color: isCompleted ? RqwstColors.brand.withValues(alpha: 0.2) : Theme.of(context).dividerColor.withValues(alpha: 0.3))),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(isCompleted ? '🎉' : '🔒', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Column(children: [
          Text(
            isCompleted
                ? (rtl ? 'اكتمل الطلب بنجاح' : 'Request completed')
                : (rtl ? 'المحادثة اتقفلت' : 'Chat closed'),
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800,
              color: isCompleted ? RqwstColors.brand : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          Text(rtl ? 'مش ممكن ترسل رسائل جديدة' : 'No new messages can be sent',
            style: GoogleFonts.cairo(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
        ]),
      ]),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool rtl, sending;
  final AppState s;
  final VoidCallback onSend, onVoice, onImage, onLocation;
  const _InputBar({required this.ctrl, required this.rtl, required this.sending, required this.s,
    required this.onSend, required this.onVoice, required this.onImage, required this.onLocation});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.3))),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      // Image
      _IconBtn(icon: Icons.image_outlined, onTap: onImage),
      const SizedBox(width: 2),
      // Location
      _IconBtn(icon: Icons.location_on_outlined, onTap: onLocation),
      const SizedBox(width: 2),
      // Voice
      _IconBtn(icon: Icons.mic_none, onTap: onVoice),
      const SizedBox(width: 6),
      // Text field (grows with content)
      Expanded(child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100),
        child: TextField(
          controller: ctrl,
          maxLines: null,
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: s.t('typeMsg'), hintStyle: GoogleFonts.cairo(),
            isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          ),
          style: GoogleFonts.cairo(fontSize: 16),
          onSubmitted: (_) => onSend(),
        ),
      )),
      const SizedBox(width: 6),
      // Send
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl,
        builder: (_, v, __) {
          final hasText = v.text.trim().isNotEmpty;
          return GestureDetector(
            onTap: hasText ? onSend : onVoice,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: RqwstColors.brand,
                borderRadius: BorderRadius.circular(12)),
              child: sending
                  ? const Padding(padding: EdgeInsets.all(9),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(hasText ? Icons.send : Icons.mic, color: Colors.white, size: 17),
            ),
          );
        },
      ),
    ]),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
    ),
  );
}


// ============================================================
// SOURCE: lib/screens/tasks_screen.dart
// ============================================================


class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<AppState>();
      if (s.isProv) s.loadFeed(); else s.loadMyReqs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final rtl = s.isRTL;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 1,
            toolbarHeight: 56,
            title: Text(s.isProv ? s.t('nearbyReqs') : s.t('tasks'),
              style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900)),
            actions: [
              if (s.isProv)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AvailToggle(s: s),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                    label: Text(rtl ? 'جديد' : 'New', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const NewRequestSheet()),
                    style: TextButton.styleFrom(backgroundColor: RqwstColors.brand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 12)),
                  ),
                ),
            ],
          ),

          // ── Active request banner (tap to reopen AR overlay) ─────────
          if (s.user != null) ...[
            () {
              final active = s.myReqs.where((r) => r.isMine &&
                (r.state == 'bidding' || r.state == 'open' || r.state == 'accepted' || r.state == 'in_progress')).toList();
              if (active.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              final req = active.first;
              return SliverToBoxAdapter(child: GestureDetector(
                onTap: () => Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
                    value: s,
                    child: ActiveRequestOverlay(req: req, isProvider: false, onDismiss: () => Navigator.pop(context)),
                  ),
                  transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                )),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0D2A1A), Color(0xFF0A1628)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: RqwstColors.brand.withValues(alpha: 0.25), blurRadius: 16)],
                  ),
                  child: Row(children: [
                    Container(width: 10, height: 10,
                      decoration: const BoxDecoration(color: RqwstColors.brand, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      s.isRTL ? '${req.description} • اضغط لتتابع الطلب' : '${req.description} • Tap to track',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    )),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white54),
                  ]),
                ),
              ));
            }(),
          ],

          // ── Mode switch ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _ModeSwitch(s: s),
          )),

          // ── Body ────────────────────────────────────────────────────────────
          if (s.user == null)
            SliverFillRemaining(child: EmptyState(
              emoji: '🔒',
              label: rtl ? 'سجّل دخولك الأول' : 'Login required',
              action: BrandButton(label: s.t('login'), onTap: () =>
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AuthSheet())),
            ))
          else if (s.isProv)
            _ProviderFeed(s: s)
          else
            _RequesterList(s: s),
        ],
      ),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────
class _ModeSwitch extends StatelessWidget {
  final AppState s;
  const _ModeSwitch({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        _Btn(label: s.t('requesterMode'), active: !s.isProv, color: RqwstColors.brand, onTap: () => s.setMode('requester')),
        _Btn(label: s.t('providerMode'), active: s.isProv, color: RqwstColors.invert, onTap: () => s.setMode('provider')),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _Btn({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext ctx) => Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(color: active ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
    child: Text(label, textAlign: TextAlign.center,
      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
        color: active ? Colors.white : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.5))),
  )));
}

// ── Availability toggle ───────────────────────────────────────────────────────
class _AvailToggle extends StatelessWidget {
  final AppState s;
  const _AvailToggle({required this.s});

  @override
  Widget build(BuildContext context) {
    final on = s.providerAvailable == 1;
    return GestureDetector(
      onTap: s.toggleAvail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? RqwstColors.brand : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(
            color: on ? Colors.white : Colors.grey,
            shape: BoxShape.circle,
          )),
          const SizedBox(width: 6),
          Text(on ? s.t('available') : s.t('unavailable'),
            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
              color: on ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ]),
      ),
    );
  }
}

// ── Requester: My requests ────────────────────────────────────────────────────
class _RequesterList extends StatelessWidget {
  final AppState s;
  const _RequesterList({required this.s});

  static const _done = {'completed', 'done', 'cancelled', 'canceled'};

  @override
  Widget build(BuildContext context) {
    if (s.myReqsLoading && s.myReqs.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(14),
        sliver: SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerBox(height: 88)),
          childCount: 3,
        )),
      );
    }

    final active = s.myReqs.where((r) => r.isMine && !_done.contains(r.state)).toList();

    if (active.isEmpty) {
      return SliverFillRemaining(child: EmptyState(
        emoji: '📋',
        label: s.t('noRequests'),
        action: BrandButton(label: s.t('newReq'), small: true, onTap: () =>
          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const NewRequestSheet())),
      ));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      sliver: SliverList(delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ReqCard(req: active[i], s: s),
        ),
        childCount: active.length,
      )),
    );
  }
}

class _ReqCard extends StatelessWidget {
  final Request req;
  final AppState s;
  const _ReqCard({required this.req, required this.s});

  @override
  Widget build(BuildContext context) {
    return RqwstCard(
      onTap: () {
        final isActive = req.state == 'accepted' || req.state == 'in_progress' || req.state == 'bidding' || req.state == 'open';
        if (isActive) {
          Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
              value: s,
              child: ActiveRequestOverlay(req: req, isProvider: false, onDismiss: () => Navigator.pop(context)),
            ),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          ));
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(value: s, child: RequestDetailSheet(req: req)),
          );
        }
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(req.description, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, height: 1.35))),
          const SizedBox(width: 8),
          StatusPill(label: _statusLabel(req, s), color: _statusColor(req)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 12, children: [
          if (req.area != null)
            _Meta(icon: Icons.location_on_outlined, text: req.area!),
          _Meta(icon: Icons.attach_money, text: '${req.finalPrice} ${s.t('egp')}', color: RqwstColors.brand),
          if (req.offerCount > 0)
            _Meta(icon: Icons.chat_bubble_outline, text: '${req.offerCount} ${s.t('offers')}'),
        ]),
        if (req.threadId != null) ...[
          const SizedBox(height: 10),
          BrandButton(label: s.t('openChat'), small: true, icon: Icons.chat_bubble_outline, onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: s,
                child: chat_screen.ChatDetailScreen(threadId: req.threadId!, requestId: req.id, peerName: ''),
              ),
            ));
          }),
        ],
      ]),
    );
  }
}


String _statusLabel(Request r, AppState s) {
  switch (r.state) {
    case 'bidding': return s.t('bidding');
    case 'accepted': case 'in_progress': return s.t('accepted');
    case 'completed': case 'done': return s.t('completed');
    case 'cancelled': case 'canceled': return s.t('cancelled');
    default: return r.state;
  }
}

String _statusColor(Request r) {
  switch (r.state) {
    case 'bidding': return 'amber';
    case 'accepted': case 'in_progress': return 'invert';
    case 'completed': case 'done': return 'green';
    case 'cancelled': case 'canceled': return 'red';
    default: return 'slate';
  }
}

// ── Provider: Feed ─────────────────────────────────────────────────────────────
class _ProviderFeed extends StatelessWidget {
  final AppState s;
  const _ProviderFeed({required this.s});

  @override
  Widget build(BuildContext context) {
    final rtl = s.isRTL;

    if (s.feedLoading && s.feed.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(14),
        sliver: SliverList(delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ShimmerBox(height: 100)),
          childCount: 3,
        )),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      sliver: SliverList(delegate: SliverChildListDelegate([
        // Warnings
        if (s.feedBusy)
          WarningBanner(text: s.t('alreadyActive'), color: RqwstColors.amberL,
            borderColor: RqwstColors.amber.withValues(alpha: 0.25)),
        if (s.providerAvailable == 0)
          WarningBanner(
            text: s.t('providerAvailableHint'),
            color: RqwstColors.roseL,
            borderColor: RqwstColors.rose.withValues(alpha: 0.2),
            trailing: TextButton(
              onPressed: s.toggleAvail,
              child: Text(s.t('available'), style: GoogleFonts.cairo(color: RqwstColors.brand, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),

        if (s.feed.isEmpty)
          EmptyState(
            emoji: '🔍',
            label: rtl ? 'مفيش ركوستات قريبة' : 'No nearby requests',
          )
        else
          ...s.feed.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: _FeedCard(req: req, s: s),
          )),
      ])),
    );
  }
}

class _FeedCard extends StatefulWidget {
  final Request req;
  final AppState s;
  const _FeedCard({required this.req, required this.s});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _showOffer = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final req = widget.req;
    final s = widget.s;
    final rtl = s.isRTL;

    return RqwstCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(req.description, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, height: 1.35)),
          const SizedBox(height: 5),
          Wrap(spacing: 10, children: [
            if (req.requesterName != null)
              _Meta(icon: Icons.person_outline, text: req.requesterName!),
            if (req.area != null)
              _Meta(icon: Icons.location_on_outlined, text: req.area!),
          ]),
        ])),
        const SizedBox(width: 10),
        Text('${req.price}', style: GoogleFonts.cairo(fontSize: 21, fontWeight: FontWeight.w900, color: RqwstColors.brand)),
      ]),

      // Delivery extra info
      if (req.type == 'توصيل' && req.pickupAddress != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Row(children: [const Text('📍 ', style: TextStyle(fontSize: 12)), Expanded(child: Text(req.pickupAddress!, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: RqwstColors.brand), overflow: TextOverflow.ellipsis))]),
            const SizedBox(height: 4),
            Row(children: [const Text('🏁 ', style: TextStyle(fontSize: 12)), Expanded(child: Text(req.dropoffAddress ?? '', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))]),
          ]),
        ),
      ],

      const SizedBox(height: 10),

      // Actions
      if (!s.feedBusy) Row(children: [
        Expanded(child: BrandButton(
          label: s.t('acceptReq'),
          small: true,
          onTap: s.providerAvailable == 1 ? () => s.acceptReq(req.id) : null,
        )),
        const SizedBox(width: 8),
        Expanded(child: BrandButton(
          label: s.t('makeOffer'),
          small: true,
          ghost: true,
          onTap: s.providerAvailable == 1 ? () => setState(() => _showOffer = !_showOffer) : null,
        )),
      ]),

      // My offer badge
      if (req.myOffer != null) ...[
        const SizedBox(height: 8),
        StatusPill(
          label: req.myOffer!['status'] == 'accepted'
              ? (rtl ? 'قُبل عرضك ✓' : 'Offer accepted ✓')
              : req.myOffer!['status'] == 'rejected'
              ? (rtl ? 'رُفض عرضك' : 'Offer rejected')
              : (rtl ? 'في انتظار الموافقة…' : 'Waiting for approval…'),
          color: req.myOffer!['status'] == 'accepted' ? 'green'
              : req.myOffer!['status'] == 'rejected' ? 'red' : 'amber',
        ),
      ],

      // Inline offer input
      if (_showOffer) ...[
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: s.t('offerPrice')),
            style: GoogleFonts.cairo(),
          )),
          const SizedBox(width: 8),
          BrandButton(
            label: s.t('submitOffer'),
            small: true,
            onTap: () {
              final price = num.tryParse(_ctrl.text);
              if (price != null) {
                s.makeOffer(req.id, price);
                setState(() => _showOffer = false);
              }
            },
          ),
        ]),
      ],
    ]));
  }
}


// ============================================================
// SOURCE: lib/screens/profile_screen.dart
// ============================================================


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


// ============================================================
// SOURCE: lib/screens/home_screen.dart
// ============================================================


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


// ============================================================
// SOURCE: lib/main.dart
// ============================================================


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
