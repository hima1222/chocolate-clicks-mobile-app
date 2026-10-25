import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ImageUploadService {
  /// Works with bytes from a mobile or web file picker. Persist the returned
  /// imageUrl with the event/product; publicId identifies the Cloudinary asset.
  Future<Map<String, dynamic>> upload({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    final token = AuthService().authToken;
    if (token == null) {
      throw ApiException(message: 'Please sign in to upload images');
    }
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw ApiException(message: 'Choose an image smaller than 10 MB');
    }
    if (![
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
    ].contains(mimeType)) {
      throw ApiException(message: 'Use a JPEG, PNG, WebP or GIF image');
    }
    final request =
        http.MultipartRequest('POST', Uri.parse('${ApiClient.baseUrl}/uploads'))
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: filename,
              contentType: MediaType.parse(mimeType),
            ),
          );
    final client = http.Client();
    try {
      final response = await http.Response.fromStream(
        await client.send(request).timeout(const Duration(seconds: 90)),
      ).timeout(const Duration(seconds: 90));
      if (response.statusCode != 201) {
        throw ApiException(
          message: ApiClient.errorMessage(response.body, 'Image upload failed'),
          statusCode: response.statusCode,
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return Map<String, dynamic>.from(body['data'] as Map);
    } finally {
      client.close();
    }
  }
}
