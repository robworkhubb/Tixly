import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Memory {
  final String id;
  final String eventId;
  final String userId;
  final String title;
  final String artist;
  final String description;
  final String location;
  final String? mediaUrl;
  final int stars;
  final DateTime date;

  Memory({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.title,
    required this.artist,
    required this.location,
    required this.description,
    this.mediaUrl,
    required this.stars,
    required this.date,
  });

  factory Memory.fromMap(Map<String, dynamic> data, String docId) {
    return Memory(
      id: docId,
      eventId: data['eventId'].toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Senza titolo',
      artist: data['artist']?.toString()    ?? 'Artista sconosciuto',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location']?.toString()  ?? 'Luogo sconosciuto',
      mediaUrl: data['mediaUrl']?.toString(),
      description: data['description']?.toString() ?? '',
      stars: int.tryParse(data['stars']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'title': title,
      'artist': artist,
      'description': description,
      'mediaUrl': mediaUrl,
      'stars': stars,
      'date': date,
    };
  }

  String get dateFormatted => DateFormat('dd/MM/yyyy').format(date);
}
