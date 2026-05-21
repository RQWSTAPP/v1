import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

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
