import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'api.dart';

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
