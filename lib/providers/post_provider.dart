import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/models/post_model.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  final _db = FirebaseFirestore.instance;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();
      _posts = snapshot.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
      debugPrint('Docs: ${snapshot.docs.length}');
    } catch (e) {
      debugPrint("Errore nel fetchPosts: $e");
    }
  }

  Future<void> addPosts(Post post) async {
    try {
      await FirebaseFirestore.instance.collection('posts').add(post.toMap());
      await fetchPosts();
    } catch (e) {
      debugPrint("Errore nel addPosts");
    }
  }

  Future<void> toggleLike(String postId, String uid) async {
    final postRef  = _db.collection('posts').doc(postId);
    final likeRef  = postRef.collection('likes').doc(uid);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) return;

      int current = (postSnap.data()?['likes'] ?? 0) as int;   // 👈 likes

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likes': current - 1});            // 👈 likes
      } else {
        tx.set(likeRef, {'uid': uid, 'ts': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likes': current + 1});            // 👈 likes
      }
    });
  }
}

