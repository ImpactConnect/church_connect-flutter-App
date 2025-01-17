import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/blog.dart';
import '../../services/blog_service.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailScreen({
    Key? key,
    required this.blogId,
  }) : super(key: key);

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _blogService = BlogService();
  Blog? _blog;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlog();
  }

  Future<void> _loadBlog() async {
    try {
      final blog = await _blogService.getBlogById(widget.blogId);
      setState(() {
        _blog = blog;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading blog: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                )
              : _blog == null
                  ? const Center(child: Text('Blog not found'))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 200,
                          floating: false,
                          pinned: true,
                          actions: [
                            IconButton(
                              icon: Icon(
                                _blog!.isLikedByCurrentUser
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _blog!.isLikedByCurrentUser
                                    ? Colors.red
                                    : Colors.white,
                              ),
                              onPressed: () async {
                                try {
                                  final updatedBlog = await _blogService.toggleLike(_blog!);
                                  setState(() {
                                    _blog = updatedBlog;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error liking post: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Center(
                                child: Text(
                                  '${_blog!.likesCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              _blog!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            background: _blog!.thumbnailUrl != null
                                ? Image.network(
                                    _blog!.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image_not_supported),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Theme.of(context).primaryColor,
                                  ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: _blog!.author.profileImageUrl != null
                                          ? NetworkImage(_blog!.author.profileImageUrl!)
                                          : null,
                                      child: _blog!.author.profileImageUrl == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _blog!.author.fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            _blog!.formattedDate,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_blog!.tags != null && _blog!.tags!.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _blog!.tags!.map((tag) {
                                      return Chip(
                                        label: Text(tag),
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(height: 16),
                                MarkdownBody(
                                  data: _blog!.content,
                                  styleSheet: MarkdownStyleSheet(
                                    p: Theme.of(context).textTheme.bodyLarge,
                                    h1: Theme.of(context).textTheme.headlineMedium,
                                    h2: Theme.of(context).textTheme.titleLarge,
                                    h3: Theme.of(context).textTheme.titleMedium,
                                  ),
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
