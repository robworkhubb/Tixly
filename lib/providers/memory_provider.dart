import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/models/memory_model.dart';

class MemoryProvider with ChangeNotifier {
  List<Memory> _memories = [];

  List<Memory> get memories => _memories;

  Future<void> fetchMemories(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('memories')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      _memories = snapshot.docs.map((doc) {
        return Memory.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Errore fetchMemory: $e');
    }
  }

  Future<void> addMemory(Memory memories) async {
    try {
      await FirebaseFirestore.instance
          .collection('memories')
          .add(memories.toMap());
      await fetchMemories(memories.userId);
    } catch (e) {
      debugPrint("Errore aggiunta ricordo: $e");
    }
  }
}
