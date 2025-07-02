import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tixly/features/memories/data/models/memory_model.dart';
import 'package:tixly/core/services/cloudinary_service.dart';

class MemoryProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryService();

  List<Memory> _memories = [];
  List<Memory> get memories => _memories;

  /// Carica tutti i ricordi dell'utente
  Future<void> fetchMemories(String userId) async {
    final snap = await _db
        .collection('memories')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    _memories = snap.docs
        .map((doc) => Memory.fromMap(doc.data(), doc.id))
        .toList();
    notifyListeners();
  }

  /// Aggiunge un nuovo ricordo (opzionale upload immagine su Cloudinary)
  Future<void> addMemory({
    required String userId,
    required String title,
    required String artist,
    required String location,
    required String description,
    required DateTime date,
    File? imageFile,
    required int rating,
  }) async {
    String? imageUrl;
    try {
      if (imageFile != null) {
        imageUrl = await _cloudinary.uploadImage(imageFile.path);
      }

      await _db.collection('memories').add({
        'userId': userId,
        'title': title,
        'artist': artist,
        'location': location,
        'description': description,
        'date': Timestamp.fromDate(date),
        'imageUrl': imageUrl,
        'rating': rating,
      });

      // ricarica la lista
      await fetchMemories(userId);
    } catch (e) {
      debugPrint('❌ addMemory error: $e');
    }
  }
}
