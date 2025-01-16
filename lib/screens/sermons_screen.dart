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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sermons')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _sermons.length,
              itemBuilder: (context, index) {
                final sermon = _sermons[index];
                return ListTile(
                  title: Text(sermon['title'] ?? 'Untitled Sermon'),
                  subtitle: Text(sermon['preacher'] ?? 'Unknown Preacher'),
                  onTap: () {
                    // Navigate to sermon details
                  },
                );
              },
            ),
    );
  }
}
