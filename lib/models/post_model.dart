import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String content;
  final String? mediaUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.mediaUrl,
    required this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
      id: docId,
      userId: data['userId'],
      content: data['content'],
      mediaUrl: data['mediaUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp,
    };
  }
}
