import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service.dart';
import '../services/service_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpcomingServiceCard extends StatefulWidget {
  const UpcomingServiceCard({super.key});

  @override
  State<UpcomingServiceCard> createState() => _UpcomingServiceCardState();
}

class _UpcomingServiceCardState extends State<UpcomingServiceCard> {
  late final ServiceRepository _serviceRepository;
  ChurchService? _nextService;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _serviceRepository = ServiceRepository(Supabase.instance.client);
    _loadNextService();
  }

  Future<void> _loadNextService() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final service = await _serviceRepository.getNextService();
      setState(() {
        _nextService = service;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load next service';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_nextService == null) {
      return const Center(child: Text('No upcoming services'));
    }

    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('h:mm a');

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
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _nextService!.isSpecialService ? 'Special Service' : 'Next Sunday Service',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Join us on ${dateFormat.format(_nextService!.serviceDate)} at ${timeFormat.format(_nextService!.serviceDate)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Theme: ${_nextService!.theme}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          if (_nextService!.preacher != null) ...[
            const SizedBox(height: 4),
            Text(
              'Speaker: ${_nextService!.preacher}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement reminder functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder set for the service')),
                  );
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
                  // TODO: Implement calendar integration
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to calendar')),
                  );
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
}
