import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:sanctuary/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {

  /// Uploads a single file to Cloudinary using
  /// unsigned upload with API key + signature.
  static Future<Map<String, dynamic>?> _uploadToCloudinary(
      XFile file,
      ) async {

    try {

      final timestamp =
      (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();

      // Generate signature
      final paramsToSign = 'timestamp=$timestamp';

      final signature = sha1
          .convert(
        utf8.encode(
          '$paramsToSign${Config.cloudinaryApiSecret}',
        ),
      )
          .toString();

      final uri = Uri.parse(Config.cloudinaryUploadUrl);

      final request =
      http.MultipartRequest('POST', uri);

      // Detect MIME type
      final mimeType =
          lookupMimeType(file.path) ?? 'application/octet-stream';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.name,
        ),
      );

      request.fields['api_key'] =
          Config.cloudinaryApiKey;

      request.fields['timestamp'] = timestamp;

      request.fields['signature'] = signature;

      final streamedResponse = await request.send();

      final responseBody =
      await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {

        final data = jsonDecode(responseBody);

        // Determine if it's a video or image
        final bool isVideo =
            mimeType.startsWith('video/');

        return {
          'url': data['secure_url'],
          'type': isVideo ? 'video' : 'image',
          'thumbnail': isVideo
              ? data['secure_url']
              .replaceAll('.mp4', '.jpg')
              .replaceAll('.mov', '.jpg')
              .replaceAll('.avi', '.jpg')
              : null,
          'duration': isVideo
              ? data['duration']
              : null,
        };
      }

      debugPrint(
        'PostService: Cloudinary upload failed '
            '(${streamedResponse.statusCode}): $responseBody',
      );

      return null;

    } catch (e) {

      debugPrint('PostService: Cloudinary upload error - $e');

      return null;
    }
  }

  /// Uploads all selected media files to Cloudinary
  /// and then creates the post in the backend.
  static Future<Map<String, dynamic>> createPost({
    required List<XFile> mediaFiles,
    required String caption,
    required List<String> taggedUserIds,
  }) async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated. Please login again.',
        };
      }

      if (mediaFiles.isEmpty) {
        return {
          'success': false,
          'message': 'Please select at least one photo or video.',
        };
      }

      // 1) UPLOAD ALL MEDIA TO CLOUDINARY
      final List<Map<String, dynamic>> mediaList = [];

      for (final file in mediaFiles) {

        final result = await _uploadToCloudinary(file);

        if (result == null) {
          return {
            'success': false,
            'message':
            'Failed to upload media: ${file.name}',
          };
        }

        // Remove null values
        result.removeWhere(
              (key, value) => value == null,
        );

        mediaList.add(result);
      }

      // 2) CREATE POST IN BACKEND
      final body = jsonEncode({
        'caption': caption,
        'media': mediaList,
        'taggedUsers': taggedUserIds,
      });

      final response = await http.post(
        Uri.parse(Config.createPost_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 201) {

        final data = jsonDecode(response.body);

        return {
          'success': true,
          'post': data['post'],
        };
      }

      debugPrint(
        'PostService: Create post failed '
            '(${response.statusCode}): ${response.body}',
      );

      final errorData = jsonDecode(response.body);

      return {
        'success': false,
        'message': errorData['message'] ??
            'Failed to create post.',
      };

    } catch (e) {

      debugPrint('PostService: Exception - $e');

      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  /// Fetches all posts from the backend.
  static Future<List<dynamic>> getPosts() async {

    try {

      final response = await http.get(
        Uri.parse(Config.getPosts_url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        return data['posts'] ?? [];
      }

      debugPrint(
        'PostService: Get posts failed '
            '(${response.statusCode}): ${response.body}',
      );

      return [];

    } catch (e) {

      debugPrint('PostService: Exception - $e');

      return [];
    }
  }
}
