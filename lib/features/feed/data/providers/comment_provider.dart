import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  final Map<String, List<Comment>> _commentsCache = {};

  Map<String, List<Comment>> get commentsCache => _commentsCache;

  Future<void> fetchComments(String postId) async {
    try {
      final snap = await _db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .get();
      _commentsCache[postId] = snap.docs
          .map((d) => Comment.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetchcomments error: $e');
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
      'postId': postId,
      'userId': userId,
      'content': content.trim(),
      'timestamp': Timestamp.fromDate(now),
      });

      final comment = Comment(id: docRef.id,
          postId: postId,
          userId: userId,
          content: content.trim(),
          timestamp: now
      );
      _commentsCache.putIfAbsent(postId, () => []).add(comment);
      notifyListeners();
    } catch (e) {
      debugPrint('addComment error: $e');
    }
  }
}
