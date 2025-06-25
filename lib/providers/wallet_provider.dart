import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class WalletProvider with ChangeNotifier {
  List<Ticket> _ticket = [];

  List<Ticket> get ticket => _ticket;

  Future<void> fetchTickets(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();
      _ticket = snapshot.docs.map((doc) {
        return Ticket.fromMap(doc.data(), doc.id);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Errore fetchBiglietti: $e');
    }
  }

  Future<void> addTicket(Ticket ticket) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .add(ticket.toMap());
      await fetchTickets(ticket.userId);
    } catch (e) {
      debugPrint("Errore aggiunta ticket: $e");
    }
  }
}
