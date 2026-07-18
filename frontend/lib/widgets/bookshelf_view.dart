import 'package:flutter/material.dart';
import '../controllers/ebook_library_controller.dart';

class BookshelfView extends StatelessWidget {
  final List<dynamic> ebooks;
  final EbookLibraryController controller;
  final Function(dynamic) onBookTap;
  final Function(dynamic) onBookLongPress;

  const BookshelfView({
    super.key,
    required this.ebooks,
    required this.controller,
    required this.onBookTap,
    required this.onBookLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (ebooks.isEmpty) {
      return _buildEmptyShelf();
    }

    final int itemsPerRow = 3;
    final int rowCount = (ebooks.length / itemsPerRow).ceil();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        final startIndex = rowIndex * itemsPerRow;
        final rowBooks = <dynamic>[];

        for (var i = 0; i < itemsPerRow; i++) {
          final index = startIndex + i;
          if (index < ebooks.length) {
            rowBooks.add(ebooks[index]);
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  for (var i = 0; i < itemsPerRow; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: i < rowBooks.length
                            ? _buildBookCard(rowBooks[i])
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildWoodenShelf(),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildBookCard(dynamic ebook) {
    final title = ebook['title'] as String;
    final author = ebook['author'] as String;
    final id = ebook['id'] as int;
    final fileType = ebook['file_type'] as String;
    final coverUrl = ebook['cover_image_url'] as String?;
    final isDownloaded = controller.localFilePaths[id] != null;
    final isDownloading = controller.downloadingStates[id] ?? false;

    final coverColors = [
      const Color(0xFF2E5B88),
      const Color(0xFF882E2E),
      const Color(0xFF2E885B),
      const Color(0xFF887D2E),
      const Color(0xFF5B2E88),
    ];
    final coverColor = coverColors[id % coverColors.length];

    return GestureDetector(
      onTap: () => onBookTap(ebook),
      onLongPress: () => onBookLongPress(ebook),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 140,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(3, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverUrl != null && coverUrl.isNotEmpty)
                    Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildCoverPlaceholder(title, author, coverColor),
                    )
                  else
                    _buildCoverPlaceholder(title, author, coverColor),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.0),
                          Colors.black.withOpacity(0.2),
                        ],
                        stops: const [0.0, 0.05, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 3,
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fileType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  if (isDownloading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                  else if (!isDownloaded)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_download,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder(String title, String author, Color color) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.book,
              color: Colors.white24,
              size: 20,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ),
          ),
          Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoodenShelf() {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD2B48C),
            Color(0xFF8B5A2B),
            Color(0xFF5C3A21),
          ],
          stops: [0.0, 0.4, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShelf() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Column(
          children: [
            if (index == 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.library_books,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your library is empty',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the button below to upload your first book.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(height: 100),
            _buildWoodenShelf(),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
