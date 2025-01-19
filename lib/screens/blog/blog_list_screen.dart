import 'package:flutter/material.dart';
import '../../models/blog.dart';
import '../../services/blog_service.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final _blogService = BlogService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Blog> _blogs = [];
  List<String>? _selectedTags;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _selectedTags = [];
    _scrollController.addListener(_onScroll);
    _loadBlogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBlogs();
    }
  }

  Future<void> _loadBlogs() async {
    if (_isLoading) return;

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final blogs = await _blogService.getBlogs(
        page: _currentPage,
        searchQuery: _searchController.text,
        tags: _selectedTags,
      );

      setState(() {
        if (_currentPage == 1) {
          _blogs = blogs;
        } else {
          _blogs.addAll(blogs);
        }
        _hasMore = blogs.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading blogs: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreBlogs() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final blogs = await _blogService.getBlogs(
        page: _currentPage + 1,
        searchQuery: _searchController.text,
        tags: _selectedTags,
      );

      setState(() {
        _blogs.addAll(blogs);
        _hasMore = blogs.length >= _pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading more blogs: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _currentPage = 1;
    });
    _loadBlogs();
  }

  void _handleTagSelection(String tag) {
    setState(() {
      if (_selectedTags?.contains(tag) ?? false) {
        _selectedTags?.remove(tag);
      } else {
        _selectedTags?.add(tag);
      }
      _currentPage = 1;
    });
    _loadBlogs();
  }

  Widget _buildBlogCard(Blog blog) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(blogId: blog.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.thumbnailUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    blog.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: blog.author.profileImageUrl != null
                            ? NetworkImage(blog.author.profileImageUrl!)
                            : null,
                        child: blog.author.profileImageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.author.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              blog.formattedDate,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          blog.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: blog.isLikedByCurrentUser
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          try {
                            final updatedBlog =
                                await _blogService.toggleLike(blog);
                            setState(() {
                              final index =
                                  _blogs.indexWhere((b) => b.id == blog.id);
                              if (index != -1) {
                                _blogs[index] = updatedBlog;
                              }
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
                      const SizedBox(width: 4),
                      Text(
                        '${blog.likesCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blog.excerpt ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (blog.tags != null && blog.tags!.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: blog.tags!.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          labelPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 180,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadBlogs,
                  tooltip: 'Refresh blogs',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Blog',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/blog_header.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                        );
                      },
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
          ];
        },
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search blogs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: _onSearchSubmitted,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Church',
                        'Worship',
                        'Prayer',
                        'Bible Study',
                        'Community',
                        'Events',
                      ].map((tag) {
                        final isSelected = _selectedTags?.contains(tag) ?? false;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) => _handleTagSelection(tag),
                            backgroundColor: Colors.grey[200],
                            selectedColor:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: _isLoading && _blogs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        _currentPage = 1;
                        await _loadBlogs();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _blogs.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _blogs.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final blog = _blogs[index];
                          return _buildBlogCard(blog);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLike(Blog blog) {
    // Implement like functionality here
  }
}
