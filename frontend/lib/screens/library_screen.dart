import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/ebook_library_controller.dart';
import '../widgets/bookshelf_view.dart';
import 'pdf_reader_screen.dart';
import 'epub_reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  final EbookLibraryController controller;

  const LibraryScreen({super.key, required this.controller});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.loadEbooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.controller.setSearchQuery(query);
    });
  }

  void _handleBookTap(dynamic ebook) async {
    final id = ebook['id'] as int;
    final title = ebook['title'] as String;
    final fileType = ebook['file_type'] as String;
    final localPath = widget.controller.localFilePaths[id];

    if (kIsWeb) {
      if (fileType == 'pdf') {
        _openPdfReaderWeb(id, title);
      } else if (fileType == 'epub') {
        _openEpubReaderWeb(id, title);
      }
      return;
    }

    if (localPath != null) {
      if (fileType == 'pdf') {
        _openPdfReader(localPath, title);
      } else if (fileType == 'epub') {
        _openEpubReader(localPath, title);
      }
    } else {
      _showDownloadAndReadDialog(ebook);
    }
  }

  void _openPdfReader(String path, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfReaderScreen(
          filePath: path,
          title: title,
        ),
      ),
    );
  }

  void _openEpubReader(String path, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EpubReaderScreen(
          filePath: path,
          title: title,
        ),
      ),
    );
  }

  void _openPdfReaderWeb(int id, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final bytes = await widget.controller.apiClient.downloadEbook(id);
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfReaderScreen(
            pdfBytes: Uint8List.fromList(bytes),
            title: title,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Failed to load PDF: ${e.toString()}');
    }
  }

  void _openEpubReaderWeb(int id, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final bytes = await widget.controller.apiClient.downloadEbook(id);
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EpubReaderScreen(
            epubBytes: Uint8List.fromList(bytes),
            title: title,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Failed to load EPUB: ${e.toString()}');
    }
  }

  void _showDownloadAndReadDialog(dynamic ebook) {
    final title = ebook['title'] as String;
    final id = ebook['id'] as int;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Book'),
        content: Text('Would you like to download and read "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A2B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final path = await widget.controller.downloadEbook(ebook);
                if (ebook['file_type'] == 'pdf') {
                  _openPdfReader(path, title);
                } else if (ebook['file_type'] == 'epub') {
                  _openEpubReader(path, title);
                }
              } catch (e) {
                _showErrorSnackBar('Download failed: ${e.toString()}');
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _handleBookLongPress(dynamic ebook) {
    final title = ebook['title'] as String;
    final id = ebook['id'] as int;
    final isDownloaded = widget.controller.localFilePaths[id] != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            if (kIsWeb)
              ListTile(
                leading: const Icon(Icons.book, color: Colors.green),
                title: const Text('Read Now', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _openPdfReaderWeb(id, title);
                },
              )
            else if (!isDownloaded)
              ListTile(
                leading: const Icon(Icons.cloud_download, color: Colors.blue),
                title: const Text('Download Offline', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await widget.controller.downloadEbook(ebook);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book downloaded successfully.')),
                    );
                  } catch (e) {
                    _showErrorSnackBar('Download failed: ${e.toString()}');
                  }
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.book, color: Colors.green),
                title: const Text('Read Now', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  final path = widget.controller.localFilePaths[id]!;
                  _openPdfReader(path, title);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete from Library', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(id, title);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await widget.controller.deleteEbook(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ebook deleted successfully.')),
                );
              } catch (e) {
                _showErrorSnackBar('Deletion failed: ${e.toString()}');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openUploadBottomSheet() {
    File? selectedFile;
    File? selectedCover;
    String fileLabel = 'Select PDF or EPUB *';
    String coverLabel = 'Select Cover Image (Optional)';
    final titleFieldController = TextEditingController();
    final authorFieldController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upload Ebook',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleFieldController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Book Title (Falls back to filename)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorFieldController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Author Name (Falls back to Unknown)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  icon: const Icon(Icons.insert_drive_file),
                  label: Text(fileLabel),
                  onPressed: () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'epub'],
                    );
                    if (result != null && result.files.single.path != null) {
                      setModalState(() {
                        selectedFile = File(result.files.single.path!);
                        fileLabel = result.files.single.name;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  icon: const Icon(Icons.image),
                  label: Text(coverLabel),
                  onPressed: () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      setModalState(() {
                        selectedCover = File(result.files.single.path!);
                        coverLabel = result.files.single.name;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select an ebook file.')),
                            );
                            return;
                          }

                          setModalState(() {
                            isSubmitting = true;
                          });

                          try {
                            await widget.controller.uploadEbook(
                              file: selectedFile!,
                              coverImage: selectedCover,
                              title: titleFieldController.text,
                              author: authorFieldController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ebook uploaded successfully.')),
                            );
                          } catch (e) {
                            setModalState(() {
                              isSubmitting = false;
                            });
                            _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Upload Book'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[800],
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller;

        return Scaffold(
          backgroundColor: const Color(0xFFF0E5D8),
          appBar: AppBar(
            backgroundColor: const Color(0xFF8B5A2B),
            foregroundColor: Colors.white,
            elevation: 4,
            title: const Text(
              'Digital Ebook Shelf',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Container(
                color: const Color(0xFF8B5A2B),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search title, author or file name...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.controller.setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.black12,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildFilterChip('All', null),
                            const SizedBox(width: 8),
                            _buildFilterChip('PDF', 'pdf'),
                            const SizedBox(width: 8),
                            _buildFilterChip('EPUB', 'epub'),
                          ],
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.sortBy,
                            dropdownColor: const Color(0xFF8B5A2B),
                            icon: const Icon(Icons.sort, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            onChanged: (String? value) {
                              if (value != null) {
                                state.setSortBy(value);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'recently_uploaded', child: Text('Recent')),
                              DropdownMenuItem(value: 'title_asc', child: Text('Title (A-Z)')),
                              DropdownMenuItem(value: 'title_desc', child: Text('Title (Z-A)')),
                              DropdownMenuItem(value: 'author_asc', child: Text('Author (A-Z)')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5A2B)),
                  ),
                )
              : state.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5A2B),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => state.loadEbooks(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : BookshelfView(
                      ebooks: state.ebooks,
                      controller: state,
                      onBookTap: _handleBookTap,
                      onBookLongPress: _handleBookLongPress,
                    ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF8B5A2B),
            foregroundColor: Colors.white,
            onPressed: _openUploadBottomSheet,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = widget.controller.filterFileType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          widget.controller.setFilterFileType(type);
        }
      },
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return Colors.transparent;
      }),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF8B5A2B) : Colors.white,
        fontSize: 10,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: const BorderSide(color: Colors.white30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}
