import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/devotional.dart';
import '../../services/supabase_devotional_service.dart';
import 'package:share_plus/share_plus.dart';

class DevotionalScreen extends StatefulWidget {
  const DevotionalScreen({super.key});

  @override
  State<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalScreen> {
  final _devotionalService = SupabaseDevotionalService();
  late Future<Devotional> _todaysDevotional;
  late Future<List<Devotional>> _recentDevotionals;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDevotionals();
  }

  void _loadDevotionals() {
    _todaysDevotional = _devotionalService.getTodaysDevotional();
    _recentDevotionals = _devotionalService.getRecentDevotionals();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _todaysDevotional = _devotionalService.getDevotionalByDate(picked);
      });
    }
  }

  void _shareDevotional(Devotional devotional) {
    final text = '''
${devotional.title}
Date: ${DateFormat('MMMM d, y').format(devotional.date)}

Bible Reading: ${devotional.bibleReading}
Memory Verse: ${devotional.memoryVerse}

${devotional.content}

Prayer Points:
${devotional.prayerPoints.map((point) => '• $point').join('\n')}

From: Church Connect App
''';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Daily Devotional'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<Devotional>(
              future: _todaysDevotional,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No devotional available for this date.'),
                  );
                }

                final devotional = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(devotional),
                    _buildContent(devotional),
                    _buildPrayerPoints(devotional),
                    _buildRecentDevotionals(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement bookmark functionality
        },
        child: const Icon(Icons.bookmark_border),
      ),
    );
  }

  Widget _buildHeader(Devotional devotional) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM d, y').format(devotional.date),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareDevotional(devotional),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            devotional.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Bible Reading', devotional.bibleReading),
          const SizedBox(height: 12),
          _buildInfoCard('Memory Verse', devotional.memoryVerse),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Devotional devotional) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            devotional.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerPoints(Devotional devotional) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prayer Points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...devotional.prayerPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecentDevotionals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Devotionals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all devotionals
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: FutureBuilder<List<Devotional>>(
            future: _recentDevotionals,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final devotionals = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: devotionals.length,
                itemBuilder: (context, index) {
                  final devotional = devotionals[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = devotional.date;
                            _todaysDevotional =
                                _devotionalService.getDevotionalByDate(devotional.date);
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d').format(devotional.date),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                devotional.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                devotional.bibleReading,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
