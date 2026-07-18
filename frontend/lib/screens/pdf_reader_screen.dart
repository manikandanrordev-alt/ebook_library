import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfReaderScreen extends StatefulWidget {
  final String? filePath;
  final Uint8List? pdfBytes;
  final String title;
  final int? bookId;

  const PdfReaderScreen({
    super.key,
    this.filePath,
    this.pdfBytes,
    required this.title,
    this.bookId,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  late PdfController _pdfController;
  int _totalPages = 0;
  int _currentPage = 1;
  bool _isReady = false;
  static const String _prefPrefix = 'last_read_pdf_';

  String get _prefKey => '$_prefPrefix${widget.bookId ?? widget.title.hashCode}';

  @override
  void initState() {
    super.initState();
    _initReader();
  }

  Future<void> _initReader() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt(_prefKey) ?? 1;

    _pdfController = PdfController(
      document: widget.pdfBytes != null
          ? PdfDocument.openData(widget.pdfBytes!)
          : PdfDocument.openFile(widget.filePath!),
      initialPage: savedPage,
    );

    setState(() {
      _currentPage = savedPage;
    });
  }

  Future<void> _saveLastReadPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, page);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (_isReady && _currentPage > 1)
              Text(
                'Last read: page $_currentPage',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
          ],
        ),
        actions: [
          if (_isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PdfView(
            controller: _pdfController,
            onDocumentLoaded: (document) {
              setState(() {
                _totalPages = document.pagesCount;
                _isReady = true;
              });
            },
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              _saveLastReadPage(page);
            },
            builders: PdfViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              pageLoaderBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
              errorBuilder: (context, error) => Center(
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          if (_isReady)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: _currentPage > 1
                              ? () => _pdfController.previousPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  )
                              : null,
                        ),
                        Text(
                          'Page $_currentPage',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: _currentPage < _totalPages
                              ? () => _pdfController.nextPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
