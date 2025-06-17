import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/models/post_model.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();
      _posts = snapshot.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Errore nel fetchPosts: $e");
    }

    Future<void> addPosts(Post post) async {
      try {
        await FirebaseFirestore.instance.collection('posts').add(post.toMap());
        await fetchPosts();
      } catch (e) {
        debugPrint("Errore nel addPosts");
      }
    }
  }
}
