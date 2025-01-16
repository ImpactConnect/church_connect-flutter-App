import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_event_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _eventService = SupabaseEventService();
  Map<String, dynamic>? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final event = await _eventService.getEventById(widget.eventId);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load event details: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_event!['title'] ?? 'Event Details'),
              background: CachedNetworkImage(
                imageUrl: _event!['image_url'] ??
                    'https://via.placeholder.com/400x200.png?text=Church+Event',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Details
                    _buildEventDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('EEEE, MMM d, yyyy')
                          .format(DateTime.parse(_event!['start_date'])),
                    ),
                    _buildEventDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: _event!['location'] ?? 'Location not specified',
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'About this Event',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _event!['description'] ?? 'No description available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    // Registration
                    if (_event!['registration_required'] == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implement registration logic
                          },
                          icon: const Icon(Icons.event_available),
                          label: const Text('Register for Event'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
