import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/core/services/supabase_storage_service.dart';
import '../models/user_model.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;
  final _storage = SupabaseStorageService(); // o il tuo CloudinaryService

  /// Legge o inizializza il documento utente
  Future<User> fetchProfile(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      // se manca, creo default
      final defaults = {
        'displayName': '',
        'profileImageUrl': null,
        'darkMode': false,
      };
      await docRef.set(defaults);
      return User.fromMap(defaults, uid);
    }
    return User.fromMap(snap.data()!, uid);
  }

  /// Aggiorna solo il displayName
  Future<void> updateDisplayName(String uid, String name) {
    return _db.collection('users').doc(uid).update({'displayName': name});
  }

  Future<String> uploadAvatar(String uid, File file) async {
    // 1️⃣ upload su Supabase
    final url = await _storage.uploadAvatar(file: file, userId: uid);

    // 2️⃣ aggiorna Firestore
    await _db.collection('users').doc(uid).update({'profileImageUrl': url});

    // 3️⃣ ritorna l’URL così chi chiama può usarlo immediatamente
    return url;
  }

  /// Aggiorna solo darkMode
  Future<void> updateDarkMode(String uid, bool on) {
    return _db.collection('users').doc(uid).update({'darkMode': on});
  }
}
