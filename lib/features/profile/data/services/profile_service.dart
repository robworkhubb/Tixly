import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/core/services/supabase_storage_service.dart';
import 'package:tixly/features/profile/data/models/user_model.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;
  final _storage = SupabaseStorageService();

  Future<User> fetchProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return User.fromMap(snap.data()!, uid);
  }

  Future<void> updateDisplayName(String uid, String name) =>
      _db.collection('users').doc(uid).update({'displayName': name});

  Future<String> uploadAvatar(String uid, File file) async {
    final publicUrl = await _storage.uploadAvatar(file: file, userId: uid);
    await _db.collection('users').doc(uid).update({'profileImageUrl': publicUrl});
    return publicUrl;  // ← non dimenticare il return
  }

  Future<void> updatePhotoUrl(String uid, String url) =>
      _db.collection('users').doc(uid).update({'photoUrl': url});

  Future<void> updateDarkMode(String uid, bool on) =>
      _db.collection('users').doc(uid).update({'darkMode': on});
}