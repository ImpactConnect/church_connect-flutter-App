import 'package:flutter/material.dart';
import '../../models/ebook.dart';
import '../../services/supabase_ebook_service.dart';
import 'ebook_details_screen.dart';

class EbooksScreen extends StatefulWidget {
  const EbooksScreen({super.key});

  @override
  State<EbooksScreen> createState() => _EbooksScreenState();
}

class _EbooksScreenState extends State<EbooksScreen> {
  final _ebookService = SupabaseEbookService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<Ebook> _books = [];
  List<Ebook> _bookOfWeek = [];
  List<Ebook> _recommendedBooks = [];
  List<String> _categories = [];
  List<String> _authors = [];
  
  String? _selectedCategory;
  String? _selectedAuthor;
  String _sortBy = 'latest'; // latest, popular, title
  bool _isLoading = true;
  bool _isSearching = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);
      await Future.wait([
        _loadBooks(),
        _loadBookOfWeek(),
        _loadRecommendedBooks(),
        _loadCategories(),
        _loadAuthors(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading books: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadBooks() async {
    final books = await _ebookService.getAllBooks(
      page: _currentPage,
      category: _selectedCategory,
      author: _selectedAuthor,
      sortBy: _sortBy,
    );
    setState(() {
      if (_currentPage == 1) {
        _books = books;
      } else {
        _books.addAll(books);
      }
      _hasMore = books.length == 10;
    });
  }

  Future<void> _loadBookOfWeek() async {
    final books = await _ebookService.getBookOfWeek();
    if (mounted) {
      setState(() => _bookOfWeek = books);
    }
  }

  Future<void> _loadRecommendedBooks() async {
    final books = await _ebookService.getRecommendedBooks();
    if (mounted) {
      setState(() => _recommendedBooks = books);
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _ebookService.getAllCategories();
    if (mounted) {
      setState(() => _categories = categories);
    }
  }

  Future<void> _loadAuthors() async {
    final authors = await _ebookService.getAllAuthors();
    if (mounted) {
      setState(() => _authors = authors);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    setState(() => _currentPage++);
    await _loadBooks();
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _currentPage = 1;
      });
      await _loadBooks();
      return;
    }

    setState(() => _isSearching = true);
    final results = await _ebookService.searchBooks(query);
    if (mounted) {
      setState(() => _books = results);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedAuthor = null;
      _sortBy = 'latest';
      _currentPage = 1;
      _isSearching = false;
      _searchController.clear();
    });
    _loadBooks();
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        image: DecorationImage(
          image: const AssetImage('assets/images/library_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Theme.of(context).primaryColor.withOpacity(0.8),
            BlendMode.multiply,
          ),
          onError: (exception, stackTrace) {
            // Fallback to gradient only if image fails to load
          },
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: GridPatternPainter(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Digital Library',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore our collection of Christian books, devotionals, and resources.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                // Search bar with modern design
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books, authors, or categories...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _searchBooks,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Ebook book) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EbookDetailsScreen(book: book),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          book.thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.book,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.book,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
            ),
            // Book details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.viewCount}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterButton(
                  label: _sortBy == 'latest' 
                    ? 'Latest' 
                    : _sortBy == 'popular' 
                      ? 'Popular' 
                      : 'A-Z',
                  icon: Icons.sort,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildSortingOptions(),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  label: _selectedCategory ?? 'Categories',
                  icon: Icons.category,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildCategoryOptions(),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterButton(
                  label: _selectedAuthor ?? 'Authors',
                  icon: Icons.person,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildAuthorOptions(),
                    );
                  },
                ),
                if (_selectedCategory != null || _selectedAuthor != null || _sortBy != 'latest')
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildFilterButton(
                      label: 'Reset',
                      icon: Icons.refresh,
                      onPressed: _resetFilters,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      textColor: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: backgroundColor ?? Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor ?? Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortingOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sort By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Latest'),
            selected: _sortBy == 'latest',
            onTap: () {
              setState(() => _sortBy = 'latest');
              Navigator.pop(context);
              _loadBooks();
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Popular'),
            selected: _sortBy == 'popular',
            onTap: () {
              setState(() => _sortBy = 'popular');
              Navigator.pop(context);
              _loadBooks();
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('A-Z'),
            selected: _sortBy == 'title',
            onTap: () {
              setState(() => _sortBy = 'title');
              Navigator.pop(context);
              _loadBooks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    Navigator.pop(context);
                    _loadBooks();
                  },
                ),
                ..._categories.map(
                  (category) => ListTile(
                    title: Text(category),
                    selected: _selectedCategory == category,
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      Navigator.pop(context);
                      _loadBooks();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Author',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Authors'),
                  selected: _selectedAuthor == null,
                  onTap: () {
                    setState(() => _selectedAuthor = null);
                    Navigator.pop(context);
                    _loadBooks();
                  },
                ),
                ..._authors.map(
                  (author) => ListTile(
                    title: Text(author),
                    selected: _selectedAuthor == author,
                    onTap: () {
                      setState(() => _selectedAuthor = author);
                      Navigator.pop(context);
                      _loadBooks();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookSection(String title, List<Ebook> books) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildBookCard(books[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroSection(),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverFilterDelegate(
              child: _buildFilterSection(),
            ),
            pinned: true,
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                if (!_isSearching) ...[
                  _buildBookSection('Book of the Week', _bookOfWeek),
                  _buildBookSection('Recommended for You', _recommendedBooks),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    _isSearching ? 'Search Results' : 'All Books',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _books.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _books.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildBookCard(_books[index]);
                  },
                ),
              ]),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(_SliverFilterDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
