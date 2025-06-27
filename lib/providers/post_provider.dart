import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/models/post_model.dart';
import 'package:tixly/services/cloudinary_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _cloudinary = CloudinaryService();

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

  Future<void> addPost({
    required String userId,
    required String content,
    File? imageFile,
  }) async {
    String? downloadUrl;
    try {
      debugPrint('🛠️ addPost START -- hasImage: ${imageFile != null}');

      if (imageFile != null) {
        downloadUrl = await _cloudinary.uploadImage(imageFile.path);
      }

      // ④ crea il documento in Firestore
      final doc = await _db.collection('posts').add({
        'userId': userId,
        'content': content.trim(),
        'mediaUrl': downloadUrl,
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('📝 post created: ${doc.id}');

      // ⑤ ricarica i post
      await fetchPosts();
      debugPrint('🔄 fetchPosts DONE');
    } catch (e, st) {
      debugPrint('❌ addPost FAILED: $e\n$st');
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

