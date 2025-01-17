import 'package:flutter/material.dart';
import '../services/supabase_sermon_service.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  _SermonsScreenState createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final _sermonService = SupabaseSermonService();
  List<Map<String, dynamic>> _sermons = [];
  bool _isLoading = true;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _selectedCategory;
  List<String> _selectedTopics = [];
  String? _selectedPreacher;
  List<String> _categories = [];
  List<String> _topics = [];
  List<String> _preachers = [];

  @override
  void initState() {
    super.initState();
    _fetchSermons();
  }

  Future<void> _fetchSermons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sermons = await _sermonService.fetchSermons();
      setState(() {
        _sermons = sermons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sermons: $e')),
      );
    }
  }

  Future<void> _loadInitialData() async {
    await _fetchSermons();
  }

  void _searchSermons({bool refresh = false}) {
    // Implement search logic here
  }

  void _showFilterDialog({
    required String title,
    required List<String> options,
    List<String> selected = const [],
    required Function(List<String>) onSelect,
    bool multiSelect = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((option) => ListTile(
                      title: Text(option),
                      trailing: selected.contains(option)
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        if (multiSelect) {
                          if (selected.contains(option)) {
                            onSelect(selected..remove(option));
                          } else {
                            onSelect(selected..add(option));
                          }
                        } else {
                          onSelect([option]);
                        }
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required Function onTap,
  }) {
    return Chip(
      label: Text(label),
      onDeleted: onTap as void Function()?,
    );
  }

  Widget _buildSermonCard(Map<String, dynamic> sermon) {
    return ListTile(
      title: Text(sermon['title'] ?? 'Untitled Sermon'),
      subtitle: Text(sermon['preacher'] ?? 'Unknown Preacher'),
      onTap: () {
        // Navigate to sermon details
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadInitialData(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 180,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadInitialData,
                  tooltip: 'Refresh sermons',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Sermons'),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/sermon_header.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).primaryColor,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search sermons...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        _searchSermons(refresh: true);
                      },
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: _selectedCategory ?? 'Category',
                            onTap: () => _showFilterDialog(
                              title: 'Select Category',
                              options: _categories,
                              selected: _selectedCategory != null
                                  ? [_selectedCategory!]
                                  : [],
                              onSelect: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected.isNotEmpty ? selected.first : null;
                                });
                                _searchSermons(refresh: true);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: _selectedTopics.isEmpty
                                ? 'Topics'
                                : '${_selectedTopics.length} Topics',
                            onTap: () => _showFilterDialog(
                              title: 'Select Topics',
                              options: _topics,
                              selected: _selectedTopics,
                              onSelect: (selected) {
                                setState(() {
                                  _selectedTopics = selected;
                                });
                                _searchSermons(refresh: true);
                              },
                              multiSelect: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: _selectedPreacher ?? 'Preacher',
                            onTap: () => _showFilterDialog(
                              title: 'Select Preacher',
                              options: _preachers,
                              selected: _selectedPreacher != null
                                  ? [_selectedPreacher!]
                                  : [],
                              onSelect: (selected) {
                                setState(() {
                                  _selectedPreacher =
                                      selected.isNotEmpty ? selected.first : null;
                                });
                                _searchSermons(refresh: true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_sermons.isEmpty && !_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sermons found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters or search terms',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _sermons.length) {
                      if (_isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return null;
                    }

                    final sermon = _sermons[index];
                    return _buildSermonCard(sermon);
                  },
                  childCount: _sermons.length + (_isLoading ? 1 : 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
