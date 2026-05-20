import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

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
