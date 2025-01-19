import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/devotional.dart';
import '../../services/supabase_devotional_service.dart';

class AllDevotionalsScreen extends StatefulWidget {
  const AllDevotionalsScreen({super.key});

  @override
  State<AllDevotionalsScreen> createState() => _AllDevotionalsScreenState();
}

class _AllDevotionalsScreenState extends State<AllDevotionalsScreen> {
  final _devotionalService = SupabaseDevotionalService();
  final _scrollController = ScrollController();
  List<Devotional> _devotionals = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadDevotionals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreDevotionals();
    }
  }

  Future<void> _loadDevotionals() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final devotionals = await _devotionalService.getRecentDevotionals(
        limit: _pageSize,
      );
      setState(() {
        _devotionals = devotionals;
        _isLoading = false;
        _hasMore = devotionals.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading devotionals: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreDevotionals() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final moreDevotionals = await _devotionalService.getRecentDevotionals(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      setState(() {
        _devotionals.addAll(moreDevotionals);
        _currentPage++;
        _isLoading = false;
        _hasMore = moreDevotionals.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more devotionals: $e')),
        );
      }
    }
  }

  Future<void> _refreshDevotionals() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadDevotionals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Devotionals'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDevotionals,
        child: _devotionals.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _devotionals.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _devotionals.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const SizedBox(),
                      ),
                    );
                  }

                  final devotional = _devotionals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, devotional);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMMM d, y').format(devotional.date),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              devotional.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              devotional.bibleReading,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              devotional.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
