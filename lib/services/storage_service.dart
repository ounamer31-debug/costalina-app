import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const _base = 'http://localhost:3000/api';

class UploadResult {
  final String? downloadUrl;
  final String? error;
  bool get success => downloadUrl != null;
  const UploadResult({this.downloadUrl, this.error});
}

class StorageService {
  static Future<UploadResult> uploadPhoto(
    File file, {
    void Function(double)? onProgress,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return const UploadResult(error: 'Not authenticated');

    try {
      final req = http.MultipartRequest('POST', Uri.parse('$_base/uploads/photo'))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      // Stream the request so we can track progress
      final stream = await req.send();
      onProgress?.call(1.0); // multipart doesn't expose per-byte progress easily

      if (stream.statusCode == 201) {
        final body = await stream.stream.bytesToString();
        // extract url from {"url":"..."}
        final match = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(body);
        final url = match?.group(1);
        if (url != null) return UploadResult(downloadUrl: url);
      }
      return const UploadResult(error: 'Upload failed');
    } catch (e) {
      return UploadResult(error: e.toString());
    }
  }
}