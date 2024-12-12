import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../services/database/database_helper.dart';
import 'event_details_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  String _selectedFilter = 'Upcoming';
  final List<String> _filters = ['All', 'Upcoming', 'Ongoing', 'Past'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> eventMaps = await db.query('Events');
      _events = eventMaps.map((map) => Event.fromMap(map)).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Event> get _filteredEvents {
    List<Event> filtered = List.from(_events);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            event.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case 'Upcoming':
        filtered = filtered.where((event) => event.isUpcoming).toList();
        break;
      case 'Ongoing':
        filtered = filtered.where((event) => event.isOngoing).toList();
        break;
      case 'Past':
        filtered = filtered.where((event) => event.isPast).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsScreen(event: event),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (event.imageUrl != null)
                                  Image.network(
                                    event.imageUrl!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('MMM d, y • h:mm a')
                                                .format(event.startDate),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            event.location,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (event.requiresRegistration) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              event.isFull
                                                  ? Icons.error_outline
                                                  : Icons.people,
                                              size: 16,
                                              color: event.isFull
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              event.isFull
                                                  ? 'Event is full'
                                                  : '${event.currentAttendees}/${event.maxAttendees} registered',
                                              style: TextStyle(
                                                color: event.isFull
                                                    ? Colors.red
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add event functionality for admin
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
