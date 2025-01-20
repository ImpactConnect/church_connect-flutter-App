import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/ebook.dart';
import 'ebook_reader_screen.dart';
import '../../services/supabase_ebook_service.dart';

class EbookDetailsScreen extends StatelessWidget {
  final Ebook book;
  final _ebookService = SupabaseEbookService();

  EbookDetailsScreen({Key? key, required this.book}) : super(key: key);

  Future<void> _launchBookUrl(BuildContext context) async {
    if (book.bookUrl == null || book.bookUrl!.isEmpty) {
      return;
    }

    try {
      final Uri url = Uri.parse(book.bookUrl!);
      if (url.path.toLowerCase().endsWith('.pdf')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EbookReaderScreen(
              pdfUrl: book.bookUrl!,
              title: book.title,
            ),
          ),
        );
      } else {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening book: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _shareBook() {
    final String shareText =
        'Check out this book: ${book.title} by ${book.author}\n${book.bookUrl ?? ''}';
    Share.share(shareText);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not available';
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (book.thumbnailUrl != null &&
                      book.thumbnailUrl!.isNotEmpty)
                    Image.network(
                      book.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, size: 100),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchBookUrl(context),
                          icon: const Icon(Icons.book),
                          label: const Text('Read Now'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _shareBook,
                        icon: const Icon(Icons.share),
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About this book',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description ?? 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(book.category ?? 'Uncategorized'),
                        avatar: const Icon(Icons.category, size: 16),
                      ),
                      Chip(
                        label: Text('${book.viewCount} views'),
                        avatar: const Icon(Icons.remove_red_eye, size: 16),
                      ),
                      if (book.publishedDate != null)
                        Chip(
                          label: Text(_formatDate(book.publishedDate)),
                          avatar: const Icon(Icons.calendar_today, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
