import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketType { pdf, image, qr }

class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final TicketType type;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime eventDate;

  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.type,
    this.fileUrl,
    required this.createdAt,
    required this.eventDate,
  });

  factory Ticket.fromMap(Map<String, dynamic> data, String docId) {
    return Ticket(
      id: docId,
      eventId: data['eventId'] as String,
      userId: data['userId'] as String,
      type: TicketType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TicketType.pdf,
      ),
      fileUrl: data['fileUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventDate: (data['eventDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'type': type,
      'fileUrl': fileUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'eventDate': eventDate,
    };
  }
}
