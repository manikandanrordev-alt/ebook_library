import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_client.dart';

class EbookLibraryController extends ChangeNotifier {
  final ApiClient _apiClient;

  List<dynamic> _ebooks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _filterFileType;
  String _sortBy = 'recently_uploaded';

  final Map<int, bool> _downloadingStates = {};
  final Map<int, String?> _localFilePaths = {};

  EbookLibraryController({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  ApiClient get apiClient => _apiClient;
  List<dynamic> get ebooks => _ebooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get filterFileType => _filterFileType;
  String get sortBy => _sortBy;
  Map<int, bool> get downloadingStates => _downloadingStates;
  Map<int, String?> get localFilePaths => _localFilePaths;

  Future<void> loadEbooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ebooks = await _apiClient.getEbooks(
        query: _searchQuery,
        fileType: _filterFileType,
        sortBy: _sortBy,
      );
      await _checkLocalFiles();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadEbooks();
    }
  }

  void setFilterFileType(String? fileType) {
    if (_filterFileType != fileType) {
      _filterFileType = fileType;
      loadEbooks();
    }
  }

  void setSortBy(String sortByOption) {
    if (_sortBy != sortByOption) {
      _sortBy = sortByOption;
      loadEbooks();
    }
  }

  Future<void> uploadEbook({
    required File file,
    File? coverImage,
    required String title,
    required String author,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.uploadEbook(
        file: file,
        coverImage: coverImage,
        title: title,
        author: author,
      );
      await loadEbooks();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> downloadEbook(dynamic ebook) async {
    final id = ebook['id'] as int;
    final fileType = ebook['file_type'] as String;

    _downloadingStates[id] = true;
    notifyListeners();

    try {
      final bytes = await _apiClient.downloadEbook(id);
      if (kIsWeb) {
        return "";
      }
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/ebook_$id.$fileType');
      await localFile.writeAsBytes(bytes);
      _localFilePaths[id] = localFile.path;
      return localFile.path;
    } catch (e) {
      rethrow;
    } finally {
      _downloadingStates[id] = false;
      notifyListeners();
    }
  }

  Future<void> deleteEbook(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.deleteEbook(id);
      if (!kIsWeb) {
        final localPath = _localFilePaths[id];
        if (localPath != null) {
          final localFile = File(localPath);
          if (await localFile.exists()) {
            await localFile.delete();
          }
        }
      }
      await loadEbooks();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _checkLocalFiles() async {
    if (kIsWeb) return;
    final dir = await getApplicationDocumentsDirectory();
    for (var ebook in _ebooks) {
      final id = ebook['id'] as int;
      final fileType = ebook['file_type'] as String;
      final localFile = File('${dir.path}/ebook_$id.$fileType');
      if (await localFile.exists()) {
        _localFilePaths[id] = localFile.path;
      } else {
        _localFilePaths[id] = null;
      }
    }
  }
}
