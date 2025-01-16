import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;
  String verseOfDay = '';
  String verseReference = '';
  bool _isLoadingVerse = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVerseOfDay();
  }

  Future<void> _loadVerseOfDay() async {
    setState(() {
      _isLoadingVerse = true;
      _errorMessage = '';
    });

    try {
      debugPrint('Loading verse file...');
      final String response = await rootBundle.loadString('assets/kjv.json');
      debugPrint('File loaded, parsing JSON...');
      final List<dynamic> verses = json.decode(response);
      debugPrint('JSON parsed, verses count: ${verses.length}');

      if (verses.isEmpty) {
        throw Exception('No verses available');
      }

      final random = Random();
      final verse = verses[random.nextInt(verses.length)];
      debugPrint('Selected verse: ${verse.toString()}');

      setState(() {
        verseOfDay = verse['text'] ?? 'No verse text available';
        verseReference =
            '${verse['book'] ?? ''} ${verse['chapter'] ?? ''}:${verse['verse'] ?? ''}';
        _isLoadingVerse = false;
      });
      debugPrint('Verse set successfully');
    } catch (e) {
      debugPrint('Error in _loadVerseOfDay: $e');
      setState(() {
        _errorMessage = 'Error loading verse: $e';
        _isLoadingVerse = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCarousel(),
              _buildVerseOfDay(),
              _buildFeatureGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notes');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Church Connect',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Welcome to our community',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    final List<String> banners = [
      'Sunday Service - 9:00 AM',
      'Bible Study - Wednesday 6:00 PM',
      'Youth Meeting - Friday 5:00 PM',
    ];

    return CarouselSlider.builder(
      itemCount: banners.length,
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Text(
              banners[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
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

  Widget _buildFeatureGrid() {
    final List<Map<String, dynamic>> features = [
      // Core Features
      {'title': 'Live Service', 'icon': Icons.live_tv, 'route': '/live-service', 'color': Colors.red},
      {'title': 'Sermons', 'icon': Icons.headphones, 'route': '/sermons', 'color': Colors.blue},
      {'title': 'Bible', 'icon': Icons.book, 'route': '/bible', 'color': Colors.purple},
      {'title': 'Prayer Wall', 'icon': Icons.people, 'route': '/prayer-wall', 'color': Colors.teal},
      
      // Media Features
      {'title': 'Radio', 'icon': Icons.radio, 'route': '/radio', 'color': Colors.orange},
      {'title': 'Videos', 'icon': Icons.video_library, 'route': '/videos', 'color': Colors.red},
      {'title': 'Hymnal', 'icon': Icons.music_note, 'route': '/hymnal', 'color': Colors.indigo},
      {'title': 'Gallery', 'icon': Icons.photo_library, 'route': '/gallery', 'color': Colors.green},
      
      // Community Features
      {'title': 'Community', 'icon': Icons.forum, 'route': '/community', 'color': Colors.blue},
      {'title': 'Events', 'icon': Icons.event, 'route': '/events', 'color': Colors.amber},
      {'title': 'Notes', 'icon': Icons.note, 'route': '/notes', 'color': Colors.cyan},
      {'title': 'Blog', 'icon': Icons.article, 'route': '/blog', 'color': Colors.deepPurple},
      
      // Engagement Features
      {'title': 'Testimonies', 'icon': Icons.stars, 'route': '/testimonies', 'color': Colors.pink},
      {'title': 'Announcements', 'icon': Icons.campaign, 'route': '/announcements', 'color': Colors.orange},
      {'title': 'Give', 'icon': Icons.favorite, 'route': '/give', 'color': Colors.red},
      {'title': 'Connect Groups', 'icon': Icons.groups, 'route': '/connect-groups', 'color': Colors.teal},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
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

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    {Color? color}
  ) {
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
