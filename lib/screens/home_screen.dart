import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_sermon_service.dart';
import '../models/sermon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sermonService = SupabaseSermonService();
  final int _selectedIndex = 0;
  String verseOfDay = '';
  String verseReference = '';
  bool _isLoadingVerse = true;
  String _errorMessage = '';
  Sermon? _latestSermon;
  bool _isLoadingSermon = true;
  List<Map<String, dynamic>> _carouselItems = [];
  bool _isLoadingCarousel = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadVerseOfDay(),
      _loadLatestSermon(),
      _loadCarouselItems(),
    ]);
  }

  Future<void> _loadLatestSermon() async {
    try {
      setState(() => _isLoadingSermon = true);
      final sermons = await _sermonService.searchSermons(page: 1);
      if (sermons.isNotEmpty) {
        setState(() {
          _latestSermon = sermons.first;
          _isLoadingSermon = false;
        });
      }
    } catch (e) {
      print('Error loading latest sermon: $e');
      setState(() => _isLoadingSermon = false);
    }
  }

  Future<void> _loadCarouselItems() async {
    try {
      setState(() => _isLoadingCarousel = true);
      final response = await Supabase.instance.client
          .from('carousel_items')
          .select()
          .order('created_at', ascending: false);
      
      setState(() {
        _carouselItems = List<Map<String, dynamic>>.from(response);
        _isLoadingCarousel = false;
      });
    } catch (e) {
      print('Error loading carousel items: $e');
      setState(() => _isLoadingCarousel = false);
    }
  }

  Future<void> _loadVerseOfDay() async {
    setState(() {
      _isLoadingVerse = true;
      _errorMessage = '';
    });

    try {
      final String response = await rootBundle.loadString('assets/data/kjv.json');
      final List<dynamic> verses = json.decode(response);

      if (verses.isEmpty) {
        throw Exception('No verses available');
      }

      final random = Random();
      final verse = verses[random.nextInt(verses.length)];

      setState(() {
        verseOfDay = verse['text'] ?? 'No verse text available';
        verseReference =
            '${verse['book'] ?? ''} ${verse['chapter'] ?? ''}:${verse['verse'] ?? ''}';
        _isLoadingVerse = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading verse: $e';
        _isLoadingVerse = false;
      });
    }
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Church Connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarousel(),
                _buildVerseOfDay(),
                _buildQuickActions(),
                _buildLatestSermon(),
                _buildUpcomingEvents(),
                _buildSectionTitle('Core Features'),
                _buildFeatureSection(_coreFeatures),
                _buildSectionTitle('Media'),
                _buildFeatureSection(_mediaFeatures),
                _buildTestimonials(),
                _buildSectionTitle('Community'),
                _buildFeatureSection(_communityFeatures),
                _buildSectionTitle('Engagement'),
                _buildFeatureSection(_engagementFeatures),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildQuickActionCard(
            'Live Now',
            Icons.live_tv,
            Colors.red,
            () => Navigator.pushNamed(context, '/live-service'),
            isLive: true,
          ),
          _buildQuickActionCard(
            'Latest Sermon',
            Icons.headphones,
            Colors.blue,
            () => Navigator.pushNamed(context, '/sermons'),
          ),
          _buildQuickActionCard(
            'Give',
            Icons.favorite,
            Colors.pink,
            () => Navigator.pushNamed(context, '/give'),
          ),
          _buildQuickActionCard(
            'Prayer',
            Icons.people,
            Colors.teal,
            () => Navigator.pushNamed(context, '/prayer-wall'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isLive = false,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement view all
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(List<Map<String, dynamic>> features) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      crossAxisCount: 4,
      childAspectRatio: 0.85,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: features
          .map((feature) => _buildFeatureCard(
                context,
                feature['title'],
                feature['icon'],
                () {
                  if (feature['route'] == '/live-service') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Live service coming soon!')),
                    );
                  } else {
                    Navigator.pushNamed(context, feature['route']);
                  }
                },
                color: feature['color'],
              ))
          .toList(),
    );
  }

  final List<Map<String, dynamic>> _coreFeatures = [
    {'title': 'Bible', 'icon': Icons.book, 'route': '/bible', 'color': Colors.purple},
    {'title': 'Sermons', 'icon': Icons.headphones, 'route': '/sermons', 'color': Colors.blue},
    {'title': 'Events', 'icon': Icons.event, 'route': '/events', 'color': Colors.amber},
    {'title': 'Notes', 'icon': Icons.note, 'route': '/notes', 'color': Colors.cyan},
  ];

  final List<Map<String, dynamic>> _mediaFeatures = [
    {
      'title': 'Radio',
      'icon': Icons.radio,
      'route': '/radio',
      'color': Colors.orange,
    },
    {
      'title': 'Videos',
      'icon': Icons.video_library,
      'route': '/videos',
      'color': Colors.red,
    },
    {
      'title': 'Hymnal',
      'icon': Icons.music_note,
      'route': '/hymnal',
      'color': Colors.indigo,
    },
    {
      'title': 'Gallery',
      'icon': Icons.photo_library,
      'route': '/gallery',
      'color': Colors.green,
    },
  ];

  final List<Map<String, dynamic>> _communityFeatures = [
    {'title': 'Community', 'icon': Icons.forum, 'route': '/community', 'color': Colors.blue},
    {'title': 'Blog', 'icon': Icons.article, 'route': '/blog', 'color': Colors.deepPurple},
    {'title': 'Testimonies', 'icon': Icons.stars, 'route': '/testimonies', 'color': Colors.pink},
    {'title': 'Connect', 'icon': Icons.groups, 'route': '/connect-groups', 'color': Colors.teal},
  ];

  final List<Map<String, dynamic>> _engagementFeatures = [
    {'title': 'Prayer Wall', 'icon': Icons.people, 'route': '/prayer-wall', 'color': Colors.teal},
    {'title': 'Give', 'icon': Icons.favorite, 'route': '/give', 'color': Colors.red},
    {'title': 'News', 'icon': Icons.campaign, 'route': '/announcements', 'color': Colors.orange},
    {'title': 'More', 'icon': Icons.more_horiz, 'route': '/more', 'color': Colors.grey},
  ];

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color?.withOpacity(0.1) ?? Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color ?? Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingService() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Next Sunday Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Join us this Sunday at 9:00 AM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Theme: Walking in Faith',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/live-service');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                ),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Remind Me'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // Add to calendar
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestSermon() {
    if (_isLoadingSermon) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_latestSermon == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest Sermon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/sermons'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                if (_latestSermon?.audioUrl != null) {
                  Navigator.pushNamed(
                    context,
                    '/audio-player',
                    arguments: _latestSermon,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio not available for this sermon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _latestSermon?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _latestSermon!.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image,
                                        color: Colors.blue,
                                        size: 40,
                                      );
                                    },
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _latestSermon?.title ?? 'Untitled Sermon',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _latestSermon?.preacher ?? 'Unknown Preacher',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${_latestSermon?.durationMinutes ?? 0} mins',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                _latestSermon?.sermonDate != null
                                    ? '${_latestSermon!.sermonDate.day}/${_latestSermon!.sermonDate.month}/${_latestSermon!.sermonDate.year}'
                                    : 'Unknown date',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/events'),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildEventCard(
                  'Youth Conference',
                  'Jan 20',
                  Icons.groups,
                  Colors.orange,
                ),
                _buildEventCard(
                  'Prayer Night',
                  'Jan 22',
                  Icons.nights_stay,
                  Colors.indigo,
                ),
                _buildEventCard(
                  'Bible Study',
                  'Jan 24',
                  Icons.book,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/events'),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      date,
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
      ),
    );
  }

  Widget _buildPrayerRequests() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prayer Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/prayer-wall'),
                child: const Text('View All'),
              ),
            ],
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPrayerRequestItem(
                    'Healing for my mother',
                    '2 hours ago',
                    42,
                  ),
                  const Divider(),
                  _buildPrayerRequestItem(
                    'Guidance for new job',
                    '5 hours ago',
                    28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRequestItem(String title, String time, int prayers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$prayers ',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Testimonies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/testimonies'),
                child: const Text('View All'),
              ),
            ],
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTestimonyItem(
                    'God\'s faithfulness in my career',
                    'Sarah M.',
                    '1 day ago',
                  ),
                  const Divider(),
                  _buildTestimonyItem(
                    'Miraculous healing testimony',
                    'James K.',
                    '2 days ago',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonyItem(String title, String author, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.format_quote,
                color: Colors.purple,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
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
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    if (_isLoadingCarousel) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_carouselItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        aspectRatio: 16/9,
        viewportFraction: 0.9,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
      items: _carouselItems.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(item['image_url'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item['description'] != null)
                        Text(
                          item['description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildVerseOfDay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verse of the Day',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isLoadingVerse)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadVerseOfDay,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoadingVerse)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verseOfDay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  verseReference,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            // Home
            break;
          case 1:
            Navigator.pushNamed(context, '/sermons');
            break;
          case 2:
            Navigator.pushNamed(context, '/bible');
            break;
          case 3:
            Navigator.pushNamed(context, '/notes');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.headphones),
          label: 'Sermons',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Bible',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Notes',
        ),
      ],
    );
  }
}
