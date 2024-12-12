class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? imageUrl;
  final String category;
  final bool isRecurring;
  final String? recurrenceRule;
  final bool requiresRegistration;
  final int? maxAttendees;
  final int currentAttendees;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.imageUrl,
    required this.category,
    this.isRecurring = false,
    this.recurrenceRule,
    this.requiresRegistration = false,
    this.maxAttendees,
    this.currentAttendees = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'category': category,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_rule': recurrenceRule,
      'requires_registration': requiresRegistration ? 1 : 0,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      location: map['location'] as String,
      imageUrl: map['image_url'] as String?,
      category: map['category'] as String,
      isRecurring: map['is_recurring'] == 1,
      recurrenceRule: map['recurrence_rule'] as String?,
      requiresRegistration: map['requires_registration'] == 1,
      maxAttendees: map['max_attendees'] as int?,
      currentAttendees: map['current_attendees'] as int,
    );
  }

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isFull => maxAttendees != null && currentAttendees >= maxAttendees!;
} 