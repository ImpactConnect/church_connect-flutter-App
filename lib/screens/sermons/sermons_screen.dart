import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/sermon.dart';
import '../../services/supabase_sermon_service.dart';
import 'sermon_player_screen.dart';
import 'package:intl/intl.dart';

enum SermonViewType { all, favorites, downloads }

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen>
    with SingleTickerProviderStateMixin {
  final _sermonService = SupabaseSermonService();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late TabController _tabController;

  List<Sermon> _sermons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _selectedCategory;
  List<String> _selectedTopics = [];
  String? _selectedPreacher;
  List<String> _categories = [];
  List<String> _topics = [];
  List<String> _preachers = [];
  SermonViewType _currentView = SermonViewType.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentView = SermonViewType.values[_tabController.index];
        });
        _loadInitialData();
      }
    });
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      await Future.wait([
        _loadFilters(),
        _searchSermons(refresh: true),
      ]);

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading initial data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error refreshing sermons. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFilters() async {
    final categories = await _sermonService.getAllCategories();
    final topics = await _sermonService.getAllTopics();
    final preachers = await _sermonService.getAllPreachers();

    setState(() {
      _categories = categories;
      _topics = topics;
      _preachers = preachers;
    });
  }

  Future<void> _searchSermons({bool refresh = false}) async {
    if (_isLoading) return;

    final page = refresh ? 1 : (_sermons.length ~/ 10) + 1;

    if (refresh) {
      setState(() {
        _sermons = [];
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      List<Sermon> sermons;
      switch (_currentView) {
        case SermonViewType.favorites:
          sermons = await _sermonService.getFavoriteSermons(
            searchQuery: _searchController.text,
            category: _selectedCategory,
            topics: _selectedTopics,
            preacher: _selectedPreacher,
            page: page,
          );
          break;
        case SermonViewType.downloads:
          sermons = await _sermonService.getDownloadedSermons(
            searchQuery: _searchController.text,
            category: _selectedCategory,
            topics: _selectedTopics,
            preacher: _selectedPreacher,
            page: page,
          );
          break;
        default:
          sermons = await _sermonService.searchSermons(
            searchQuery: _searchController.text,
            category: _selectedCategory,
            topics: _selectedTopics,
            preacher: _selectedPreacher,
            page: page,
          );
      }

      setState(() {
        if (refresh || page == 1) {
          _sermons = sermons;
        } else {
          _sermons.addAll(sermons);
        }
        _hasMore = sermons.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sermons: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sermons: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _searchSermons();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadInitialData();
        },
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
                        print('Error loading header image: $error');
                        print('Stack trace: $stackTrace');
                        // Return a colored container as fallback
                        return Container(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 48,
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
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search sermons...',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            onChanged: (_) => _searchSermons(refresh: true),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Filter Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter Sermons By:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (_selectedCategory != null ||
                                _selectedTopics.isNotEmpty ||
                                _selectedPreacher != null)
                              TextButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all, size: 20),
                                label: const Text('Clear All'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: Text(_selectedCategory ?? 'Category'),
                                selected: _selectedCategory != null,
                                onSelected: (_) => _showCategoryFilter(),
                                backgroundColor: Colors.grey[200],
                                selectedColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedCategory != null
                                      ? Theme.of(context).primaryColor
                                      : Colors.black87,
                                ),
                                checkmarkColor: Theme.of(context).primaryColor,
                                avatar: Icon(
                                  Icons.category,
                                  size: 16,
                                  color: _selectedCategory != null
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(_selectedTopics.isEmpty
                                    ? 'Topics'
                                    : '${_selectedTopics.length} Topics'),
                                selected: _selectedTopics.isNotEmpty,
                                onSelected: (_) => _showTopicsFilter(),
                                backgroundColor: Colors.grey[200],
                                selectedColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedTopics.isNotEmpty
                                      ? Theme.of(context).primaryColor
                                      : Colors.black87,
                                ),
                                checkmarkColor: Theme.of(context).primaryColor,
                                avatar: Icon(
                                  Icons.label,
                                  size: 16,
                                  color: _selectedTopics.isNotEmpty
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(_selectedPreacher ?? 'Preacher'),
                                selected: _selectedPreacher != null,
                                onSelected: (_) => _showPreacherFilter(),
                                backgroundColor: Colors.grey[200],
                                selectedColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedPreacher != null
                                      ? Theme.of(context).primaryColor
                                      : Colors.black87,
                                ),
                                checkmarkColor: Theme.of(context).primaryColor,
                                avatar: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: _selectedPreacher != null
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'All Sermons'),
                        Tab(text: 'Favorites'),
                        Tab(text: 'Downloads'),
                      ],
                      indicatorColor: Theme.of(context).primaryColor,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorWeight: 3,
                    ),
                  ),
                ],
              ),
            ),

            // Sermons List
            _sermons.isEmpty && !_isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.speaker_notes_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No sermons found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          if (_selectedCategory != null ||
                              _selectedTopics.isNotEmpty)
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters'),
                            ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < _sermons.length) {
                          return _buildSermonCard(_sermons[index]);
                        } else if (_hasMore) {
                          return _buildLoadingCard();
                        }
                        return null;
                      },
                      childCount: _sermons.length + (_hasMore ? 1 : 0),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSermonCard(Sermon sermon) {
    final formattedDate = DateFormat('MMM d, y').format(sermon.sermonDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SermonPlayerScreen(sermon: sermon),
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Play button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Sermon details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sermon.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${sermon.preacher} • $formattedDate',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      sermon.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: sermon.isFavorite ? Colors.red : Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () => _toggleFavorite(sermon),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      sermon.isDownloaded
                          ? Icons.download_done
                          : Icons.download,
                      color:
                          sermon.isDownloaded ? Colors.green : Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () => _toggleDownload(sermon),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showCategoryFilter() async {
    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) => _FilterDialogBase(
          title: 'Select Category',
          options: _categories,
          selected: _selectedCategory,
          isMultiSelect: false,
        ),
      );

      if (result != null) {
        setState(() {
          _selectedCategory = result;
        });
        _searchSermons(refresh: true);
      }
    } catch (e) {
      print('Error in category filter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating category filter. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPreacherFilter() async {
    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) => _FilterDialogBase(
          title: 'Select Preacher',
          options: _preachers,
          selected: _selectedPreacher,
          isMultiSelect: false,
        ),
      );

      if (result != null) {
        setState(() {
          _selectedPreacher = result;
        });
        _searchSermons(refresh: true);
      }
    } catch (e) {
      print('Error in preacher filter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating preacher filter. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showTopicsFilter() async {
    try {
      final currentTopics = List<String>.from(_selectedTopics);
      final result = await showDialog<List<String>>(
        context: context,
        barrierDismissible: true,
        builder: (context) => _FilterDialogBase(
          title: 'Select Topics',
          options: _topics,
          selected: currentTopics,
          isMultiSelect: true,
        ),
      );

      if (result != null) {
        setState(() {
          _selectedTopics = result;
        });
        _searchSermons(refresh: true);
      }
    } catch (e) {
      print('Error in topic filter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating topics filter. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedTopics = [];
      _selectedPreacher = null;
      _searchController.clear(); // Also clear search
    });
    _searchSermons(refresh: true);
  }

  Future<void> _toggleFavorite(Sermon sermon) async {
    try {
      final success =
          await _sermonService.toggleFavorite(sermon.id, !sermon.isFavorite);
      if (success) {
        setState(() {
          final index = _sermons.indexWhere((s) => s.id == sermon.id);
          if (index != -1) {
            _sermons[index] =
                _sermons[index].copyWith(isFavorite: !sermon.isFavorite);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sermon.isFavorite
                ? 'Removed from favorites'
                : 'Added to favorites'),
            duration: const Duration(seconds: 2),
          ),
        );

        if (_currentView == SermonViewType.favorites && sermon.isFavorite) {
          _searchSermons(refresh: true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorite status')),
      );
    }
  }

  Future<void> _toggleDownload(Sermon sermon) async {
    // Store the context before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final wasDownloaded = sermon.isDownloaded;

    try {
      final success = await _sermonService.toggleDownload(
        sermon.id,
        !wasDownloaded,
        sermon.audioUrl,
        context,
      );

      if (success && mounted) {
        setState(() {
          final index = _sermons.indexWhere((s) => s.id == sermon.id);
          if (index != -1) {
            _sermons[index] = _sermons[index].copyWith(
              isDownloaded: !wasDownloaded,
              localAudioPath:
                  !wasDownloaded ? null : _sermons[index].localAudioPath,
            );
          }
        });

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(wasDownloaded
                ? 'Sermon removed from downloads'
                : 'Sermon downloaded'),
            duration: const Duration(seconds: 2),
          ),
        );

        if (_currentView == SermonViewType.downloads &&
            wasDownloaded &&
            mounted) {
          _searchSermons(refresh: true);
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Error updating download status')),
        );
      }
    }
  }
}

class _FilterDialogBase extends StatefulWidget {
  final String title;
  final List<String> options;
  final dynamic
      selected; // Can be String for single select or List<String> for multi-select
  final bool isMultiSelect;

  const _FilterDialogBase({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.isMultiSelect,
  });

  @override
  State<_FilterDialogBase> createState() => _FilterDialogBaseState();
}

class _FilterDialogBaseState extends State<_FilterDialogBase> {
  late dynamic _selectedItems;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.isMultiSelect
        ? List<String>.from(widget.selected as List<String>)
        : widget.selected;
    _filteredOptions = List.from(widget.options);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options
            .where(
                (option) => option.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: _filterOptions,
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: _filteredOptions.map((option) {
                    final isSelected = widget.isMultiSelect
                        ? (_selectedItems as List<String>).contains(option)
                        : _selectedItems == option;

                    return widget.isMultiSelect
                        ? CheckboxListTile(
                            title: Text(option),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  (_selectedItems as List<String>).add(option);
                                } else {
                                  (_selectedItems as List<String>)
                                      .remove(option);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          )
                        : RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _selectedItems as String?,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedItems = value;
                              });
                            },
                            dense: true,
                          );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (widget.isMultiSelect) {
                        (_selectedItems as List<String>).clear();
                      } else {
                        _selectedItems = null;
                      }
                    });
                  },
                  child: const Text('Clear All'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(_selectedItems);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
