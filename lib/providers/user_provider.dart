import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  /// Profilo dell'utente attualmente autenticato
  User? _user;
  User? get user => _user;

  /// Cache per gli altri profili: userId -> UserModel
  final Map<String, User> _cache = {};
  Map<String, User> get cache => Map.unmodifiable(_cache);

  /// Carica il profilo dell'utente corrente dal DB
  Future<void> loadUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = User.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ loadUser error: $e');
    }
  }

  /// Carica e mette in cache il profilo di qualsiasi utente (per commenti, ecc.)
  Future<void> loadProfile(String uid) async {
    // Evito doppio fetch
    if (_cache.containsKey(uid)) return;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _cache[uid] = User.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ loadProfile error: $e');
    }
  }

  /// Aggiorna il profilo corrente (displayName, avatar)
  Future<void> updateProfile({String? displayName, String? profileImageUrl}) async {
    if (_user == null) return;
    final uid = _user!.uid;
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;

    try {
      await _db.collection('users').doc(uid).update(data);
      // Rifresco il profilo locale
      _user = user!.copyWith(
        displayName: displayName,
        profileImageUrl: profileImageUrl,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ updateProfile error: $e');
    }
  }

 void clearUser() {
    _user = null;
    notifyListeners();
 }

}