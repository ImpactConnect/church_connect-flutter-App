import 'package:flutter/material.dart';
import '../../models/sermon.dart';
import '../../services/database/database_helper.dart';
import 'category_list_screen.dart';
import 'preacher_list_screen.dart';
import 'category_sermons_screen.dart';
import 'preacher_sermons_screen.dart';
import 'topic_list_screen.dart';
import 'topic_sermons_screen.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Sermon> _sermons = [];
  List<String> _categories = [];
  List<String> _preachers = [];
  List<String> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // Load sermons
      final List<Map<String, dynamic>> sermonsMap = await db.query(
        'Sermons',
        orderBy: 'date DESC',
      );
      _sermons = sermonsMap.map((map) => Sermon.fromMap(map)).toList();

      // Extract unique categories, preachers, and topics
      _categories = _sermons.map((s) => s.category).toSet().toList();
      _preachers = _sermons.map((s) => s.preacher).toSet().toList();
      _topics = _sermons.expand((s) => s.topics).toSet().toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading sermons: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryListScreen(
                        categories: _categories,
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.take(5).length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final categorySermons =
                  _sermons.where((s) => s.category == category).toList();

              return Card(
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategorySermonsScreen(
                          category: category,
                          sermons: categorySermons,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${categorySermons.length} sermons',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preachers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreacherListScreen(
                        preachers: _preachers,
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _preachers.take(5).length,
            itemBuilder: (context, index) {
              final preacher = _preachers[index];
              final preacherSermons =
                  _sermons.where((s) => s.preacher == preacher).toList();

              return Card(
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreacherSermonsScreen(
                          preacher: preacher,
                          sermons: preacherSermons,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            preacher[0],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          preacher,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${preacherSermons.length} sermons',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Topics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicListScreen(
                        topics: _topics,
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _topics.take(8).length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final topicSermons =
                  _sermons.where((s) => s.topics.contains(topic)).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text(topic),
                  avatar: Text(
                    topicSermons.length.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopicSermonsScreen(
                          topic: topic,
                          sermons: topicSermons,
                        ),
                      ),
                    );
                  },
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
      appBar: AppBar(
        title: const Text('Sermons'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search sermons...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      children: [
                        _buildCategorySection(),
                        const SizedBox(height: 16),
                        _buildPreachersSection(),
                        const SizedBox(height: 16),
                        _buildTopicsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
