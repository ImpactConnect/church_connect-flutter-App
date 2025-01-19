import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'config/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/bible/bible_screen.dart';
import 'screens/sermons/sermons_screen.dart';
import 'screens/sermons/audio_player_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/events/events_screen.dart';
import 'screens/live_service_screen.dart';
import 'screens/radio/index.dart';
import 'models/sermon.dart';
import 'package:provider/provider.dart';
import 'providers/radio_provider.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/blog/blog_list_screen.dart';
import 'screens/give/give_screen.dart';
import 'screens/devotional/devotional_screen.dart';
import 'screens/hymnal/hymnal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Preload the Bible verses
  await rootBundle.loadString('assets/data/kjv.json');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioProvider()),
      ],
      child: MaterialApp(
        title: 'Church Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/bible': (context) => const BibleScreen(),
          '/sermons': (context) => const SermonsScreen(),
          '/notes': (context) => const NotesScreen(),
          '/events': (context) => const EventsScreen(),
          '/live-service': (context) => const LiveServiceScreen(),
          '/audio-player': (context) {
            final sermon = ModalRoute.of(context)!.settings.arguments as Sermon;
            return AudioPlayerScreen(sermon: sermon);
          },
          '/radio': (context) => const RadioScreen(),
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/community': (context) => const CommunityScreen(),
          '/blog': (context) => const BlogListScreen(),
          '/give': (context) => const GiveScreen(),
          '/videos': (context) => _buildComingSoonScreen('Videos'),
          '/hymnal': (context) => const HymnalScreen(),
          '/gallery': (context) => _buildComingSoonScreen('Gallery'),
          '/announcements': (context) =>
              _buildComingSoonScreen('Announcements'),
          '/devotional': (context) => const DevotionalScreen(),
          '/connect-groups': (context) =>
              _buildComingSoonScreen('Connect Groups'),
          '/testimonies': (context) => _buildComingSoonScreen('Testimonies'),
          '/prayer-wall': (context) => _buildComingSoonScreen('Prayer Wall'),
        },
      ),
    );
  }

  Widget _buildComingSoonScreen(String feature) {
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(feature),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '$feature Coming Soon!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re working hard to bring you this feature.',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
