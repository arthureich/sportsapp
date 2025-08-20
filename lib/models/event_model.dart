
class LocalUser {
  final String id;
  final String name;
  final String avatarUrl;

  LocalUser({required this.id, required this.name, required this.avatarUrl});
}

// Modelo para uma localização simplificada
class Location {
  final String name;
  final String address;

  Location({required this.name, required this.address});
}

// Modelo principal para o Evento
class Event {
  final String id;
  final String title;
  final String description;
  final String sport;
  final DateTime dateTime;
  final Location location;
  final String imageUrl;
  final LocalUser organizer;
  final List<LocalUser> participants;
  final int maxParticipants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.sport,
    required this.dateTime,
    required this.location,
    required this.imageUrl,
    required this.organizer,
    required this.participants,
    required this.maxParticipants,
  });
}