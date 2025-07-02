import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> data, String docId) {
    return Comment(
      id: docId,
      postId: data['postId'] as String,
      userId: data['userId'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'postId': postId,
    'userId': userId,
    'content': content,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
