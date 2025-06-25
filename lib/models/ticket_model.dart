class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final String type;
  final String? fileUrl;

  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.type,
    this.fileUrl,
  });

  factory Ticket.fromMap(Map<String, dynamic> data, String docId) {
    return Ticket(
      id: docId,
      eventId: data['eventId'],
      userId: data['userId'],
      type: data['type'],
      fileUrl: data['fileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'type': type,
      'fileUrl': fileUrl,
    };
  }
}
