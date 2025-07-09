import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tixly/features/feed/data/models/post_model.dart';
import 'package:tixly/core/services/supabase_storage_service.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();
  String bucket = 'tickets';


  List<Post> _posts = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;
  static const int _perPage = 10;

  List<Post> get posts => _posts;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  /// Carica la prima “pagina” di post (o ricarica tutto se clear=true)
  Future<void> fetchPosts({bool clear = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    if (clear) {
      _posts.clear();
      _lastDoc = null;
      _hasMore = true;
    }

    Query<Map<String, dynamic>> query = _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_perPage);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    try {
      final snap = await query.get();
      final fetched = snap.docs.map((d) => Post.fromMap(d.data(), d.id)).toList();

      // se meno di _perPage, non ci sono altre pagine
      if (fetched.length < _perPage) _hasMore = false;

      if (clear) {
        _posts = fetched;
      } else {
        _posts.addAll(fetched);
      }

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
      }
    } catch (e) {
      debugPrint('❌ fetchPosts error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Aggiunge un post, con upload opzionale di immagine su Cloudinary
  Future<void> addPost({
    required String userId,
    required String content,
    File? imageFile,
    bool isPdf = false, // corretto ; → = e default
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      String? downloadUrl;

      if (imageFile != null) {
        final resp = await _storageService.uploadFile(
          file: imageFile,
          bucket: bucket,
          isPdf: isPdf,
        );
        // Supponendo che uploadFile restituisca una Map<String, String> con 'rawUrl' o 'thumbUrl'
        downloadUrl = isPdf ? resp['thumbUrl'] : resp['rawUrl'];
      }

      await _db.collection('posts').add({
        'userId': userId,
        'content': content.trim(),
        'mediaUrl': downloadUrl,
        'likes': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await fetchPosts(clear: true);
      debugPrint('✅ addPost: post creato con mediaUrl=$downloadUrl');
    } catch (e, st) {
      debugPrint('❌ addPost FAILED: $e\n$st');
    }

    _isLoading = false;
    notifyListeners();
  }



  /// Toggle like con transazione atomica
  Future<void> toggleLike(String postId, String uid) async {
    final postRef = _db.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) return;

      int current = (postSnap.data()?['likes'] ?? 0) as int;
      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likes': current - 1});
      } else {
        tx.set(likeRef, {'uid': uid, 'ts': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likes': current + 1});
      }
    });
  }
}