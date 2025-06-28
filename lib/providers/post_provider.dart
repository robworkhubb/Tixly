import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/models/post_model.dart';
import 'package:tixly/services/cloudinary_service.dart';

class PostProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryService();

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;
  static const int _perPage = 10;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /// Carica la prima pagina (o ricarica tutto)
  Future<void> fetchPosts({bool clear = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    if (clear) {
      _posts.clear();
      _lastDoc = null;
      _hasMore = true;
    }

    Query query = _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_perPage);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final QuerySnapshot<Map<String, dynamic>> snap =
    await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_perPage)
        .get();
    final fetched = snap.docs.map((d) => Post.fromMap(d.data(), d.id)).toList();

    if (fetched.length < _perPage) {
      _hasMore = false; // non ci sono altre pagine
    }

    if (clear) {
      _posts = fetched;
    } else {
      _posts.addAll(fetched);
    }

    if (snap.docs.isNotEmpty) {
      _lastDoc = snap.docs.last;
    }
    _isLoading = false;
    notifyListeners();
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
