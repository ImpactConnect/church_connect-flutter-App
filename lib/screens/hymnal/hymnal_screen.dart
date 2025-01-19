import 'package:flutter/material.dart';
import '../../models/hymn.dart';
import '../../services/hymn_service.dart';
import 'hymn_detail_screen.dart';

class HymnalScreen extends StatefulWidget {
  const HymnalScreen({super.key});

  @override
  State<HymnalScreen> createState() => _HymnalScreenState();
}

class _HymnalScreenState extends State<HymnalScreen>
    with SingleTickerProviderStateMixin {
  late HymnService _hymnService;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Hymn> _hymns = [];
  List<Hymn> _filteredHymns = [];
  List<int> _bookmarkedHymns = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeHymnService();
  }

  Future<void> _initializeHymnService() async {
    _hymnService = await HymnService.create();
    await _loadHymns();
    await _loadBookmarks();
  }

  Future<void> _loadHymns() async {
    try {
      final hymns = await _hymnService.loadHymns();
      setState(() {
        _hymns = hymns;
        _filteredHymns = hymns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load hymns');
    }
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _hymnService.getBookmarkedHymns();
    setState(() {
      _bookmarkedHymns = bookmarks;
    });
  }

  void _filterHymns(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredHymns = _hymns;
      } else {
        _filteredHymns = _hymnService.searchHymns(query);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: HymnSearchDelegate(_hymns),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                // title: const Text(
                //   '',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //     shadows: [
                //       Shadow(
                //         offset: Offset(0, 1),
                //         blurRadius: 3.0,
                //         color: Color.fromARGB(255, 0, 0, 0),
                //       ),
                //     ],
                //   ),
                // ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/hymnal_header.jpg',
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
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Hymns'),
                  Tab(text: 'Bookmarks'),
                ],
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title or hymn number...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _filterHymns,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHymnList(_filteredHymns),
                  _buildBookmarkedHymnList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnList(List<Hymn> hymns) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hymns.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No hymns available'
              : 'No hymns found for "$_searchQuery"',
        ),
      );
    }

    return ListView.builder(
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymns[index];
        return _buildHymnTile(hymn);
      },
    );
  }

  Widget _buildBookmarkedHymnList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bookmarkedHymns =
        _hymns.where((hymn) => _bookmarkedHymns.contains(hymn.number)).toList();

    if (bookmarkedHymns.isEmpty) {
      return const Center(
        child: Text('No bookmarked hymns'),
      );
    }

    return ListView.builder(
      itemCount: bookmarkedHymns.length,
      itemBuilder: (context, index) {
        final hymn = bookmarkedHymns[index];
        return _buildHymnTile(hymn);
      },
    );
  }

  Widget _buildHymnTile(Hymn hymn) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          hymn.number.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        hymn.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(hymn.author),
      trailing: IconButton(
        icon: Icon(
          _bookmarkedHymns.contains(hymn.number)
              ? Icons.bookmark
              : Icons.bookmark_border,
        ),
        onPressed: () async {
          await _hymnService.toggleHymnBookmark(hymn.number);
          await _loadBookmarks();
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HymnDetailScreen(hymn: hymn),
          ),
        );
      },
    );
  }
}

class HymnSearchDelegate extends SearchDelegate<Hymn?> {
  final List<Hymn> hymns;

  HymnSearchDelegate(this.hymns);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Search for hymns by title or number'),
      );
    }

    final suggestions = hymns.where((hymn) {
      final hymnTitle = hymn.title.toLowerCase();
      final hymnNumber = hymn.number.toString();
      final input = query.toLowerCase();

      return hymnTitle.contains(input) || hymnNumber.contains(input);
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Text('No hymns found for "$query"'),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final hymn = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(hymn.number.toString()),
          ),
          title: Text(hymn.title),
          subtitle: Text(hymn.author ?? 'Unknown Author'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HymnDetailScreen(hymn: hymn),
              ),
            );
          },
        );
      },
    );
  }
}
