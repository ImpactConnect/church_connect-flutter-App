import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/bible/bible_screen.dart';
import 'screens/notes/notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload the Bible verses
  await rootBundle.loadString('assets/kjv.json');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/bible': (context) => const BibleScreen(),
        '/notes': (context) => const NotesScreen(),
        // Add other routes...
      },
    );
  }
}
