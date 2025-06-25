import 'package:cloud_firestore/cloud_firestore.dart';

class Memory {
  final String id;
  final String eventId;
  final String userId;
  final String note;
  final String? mediaUrl;
  final int stars;
  final DateTime date;

  Memory({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.note,
    required this.mediaUrl,
    required this.stars,
    required this.date,
  });

  factory Memory.fromMap(Map<String, dynamic> data, String docId) {
    return Memory(
      id: docId,
      eventId: data['eventId'],
      userId: data['userId'],
      note: data['note'],
      mediaUrl: data['mediaUrl'],
      stars: data['stars'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'note': note,
      'mediaUrl': mediaUrl,
      'stars': stars,
      'date': date,
    };
  }
}
