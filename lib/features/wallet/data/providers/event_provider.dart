import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/features/wallet/data/models/event_model.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  Future<void> fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date')
          .get();
      _events = snapshot.docs.map((doc) {
        return Event.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Errore fetchEvent: $e');
    }
  }

  Future<void> addEvent(Event events) async {
    try {
      await FirebaseFirestore.instance.collection('events').add(events.toMap());
      await fetchEvents();
    } catch (e) {
      debugPrint("Errore aggiunta ricordo: $e");
    }
  }
}
