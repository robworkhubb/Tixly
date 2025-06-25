class Event {
  final String id;
  final String name;
  final String artist;
  final String location;
  final DateTime date;
  final String? imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.artist,
    this.imageUrl,
  });

  factory Event.fromMap(Map<String, dynamic> data, String docId) {
    return Event(
      id: docId,
      name: data['name'],
      artist: data['artist'],
      location: data['location'],
      date: data['date'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'date': date,
      'artist': artist,
      'imageUrl': imageUrl,
    };
  }
}
