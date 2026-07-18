import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String _baseUrl;

  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? _getDefaultBaseUrl();

  static String _getDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  String get baseUrl => _baseUrl;

  Future<List<dynamic>> getEbooks({String? query, String? fileType, String? sortBy}) async {
    final uri = Uri.parse('$_baseUrl/api/ebooks').replace(
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (fileType != null && fileType.isNotEmpty) 'file_type': fileType,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load ebooks: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> uploadEbook({
    required File file,
    File? coverImage,
    required String title,
    required String author,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/ebooks');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['author'] = author;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    if (coverImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover_image',
          coverImage.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = errorData['errors'] ?? [errorData['error'] ?? 'Unknown error'];
      throw Exception((errors as List).join(', '));
    }
  }

  Future<List<int>> downloadEbook(int id) async {
    final uri = Uri.parse('$_baseUrl/api/ebooks/$id/download');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download ebook: ${response.statusCode}');
    }
  }

  Future<void> deleteEbook(int id) async {
    final uri = Uri.parse('$_baseUrl/api/ebooks/$id');
    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error'] ?? 'Failed to delete ebook');
      } catch (_) {
        throw Exception('Failed to delete ebook: ${response.statusCode}');
      }
    }
  }
}
