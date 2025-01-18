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

  Widget _buildSermonCard(Map<String, dynamic> sermon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline, size: 32),
        title: Text(
          sermon['title'] ?? 'Untitled Sermon',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sermon['preacher'] ?? 'Unknown Preacher',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              sermon['date'] ?? 'Unknown Date',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_outlined),
          onPressed: () async {
            // Handle download
            try {
              final url = sermon['audio_url'];
              if (url == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio not available')),
                );
                return;
              }
              // Implement download logic here
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Download failed: $e')),
              );
            }
          },
        ),
        onTap: () async {
          try {
            final url = sermon['audio_url'];
            if (url == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio not available')),
              );
              return;
            }
            
            // Show audio player bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.audiotrack, size: 48),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              sermon['title'] ?? 'Untitled Sermon',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sermon['preacher'] ?? 'Unknown Preacher',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Add audio player controls here
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () {
                                  // Rewind 10 seconds
                                },
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 48,
                                onPressed: () {
                                  // Play/pause audio
                                },
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () {
                                  // Forward 10 seconds
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Add progress slider here
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Slider(
                                  value: 0,
                                  onChanged: (value) {
                                    // Update audio position
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '0:00',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text(
                                        '0:00',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to play audio: $e')),
            );
          }
        },
      ),
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
                title: const Text(
                  'Sermons',
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
                      'assets/images/sermon_header.jpg',
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
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
                          FilterChip(
                            label: Text(_selectedCategory ?? 'Category'),
                            selected: _selectedCategory != null,
                            onSelected: (_) => _showFilterDialog(
                              title: 'Select Category',
                              options: _categories,
                              selected: _selectedCategory != null ? [_selectedCategory!] : [],
                              onSelect: (selected) {
                                setState(() {
                                  _selectedCategory = selected.isNotEmpty ? selected.first : null;
                                });
                                _searchSermons(refresh: true);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(_selectedTopics.isEmpty
                                ? 'Topics'
                                : '${_selectedTopics.length} Topics'),
                            selected: _selectedTopics.isNotEmpty,
                            onSelected: (_) => _showFilterDialog(
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
                          FilterChip(
                            label: Text(_selectedPreacher ?? 'Preacher'),
                            selected: _selectedPreacher != null,
                            onSelected: (_) => _showFilterDialog(
                              title: 'Select Preacher',
                              options: _preachers,
                              selected: _selectedPreacher != null ? [_selectedPreacher!] : [],
                              onSelect: (selected) {
                                setState(() {
                                  _selectedPreacher = selected.isNotEmpty ? selected.first : null;
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
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_sermons.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_library_outlined,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSermonCard(_sermons[index]),
                    childCount: _sermons.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
