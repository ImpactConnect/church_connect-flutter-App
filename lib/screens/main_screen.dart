import 'package:flutter/material.dart';
import 'package:church_connect/screens/give/give_screen.dart';
import 'package:church_connect/screens/sermons/sermons_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SermonsScreen(),
    const GiveScreen(),
    const Placeholder(), // Events screen (coming soon)
    const Placeholder(), // Profile screen (coming soon)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.headphones_rounded),
            label: 'Sermons',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_rounded),
            label: 'Give',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_rounded),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
