// lib/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String venue;
  final String? location;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    required this.venue,
    this.location,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Event.fromMap(Map<String, dynamic> data, String docId) {
    return Event(
      id: docId,
      title: data['title'] as String,
      description: data['description'] as String?,
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      venue: data['venue'] as String,
      location: data['location'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'venue': venue,
      'location': location,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
