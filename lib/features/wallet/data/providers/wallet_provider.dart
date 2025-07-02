import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/core/services/cloudinary_service.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

class WalletProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Ticket> _tickets = [];

  List<Ticket> get ticket => List.unmodifiable(_tickets);

  Future<void> fetchTickets(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('eventDate')
          .get();

      _tickets = snapshot.docs.map((doc) {
        return Ticket.fromMap(doc.data(), doc.id);
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌Errore fetchBiglietti: $e');
    }
  }

  Future<void> addTicket({
    required String eventId,
    required String userId,
    required TicketType type,
    File? file,
    required DateTime eventDate,
  }) async {
    try {
      String? fileUrl;
      if (file != null) {
        fileUrl = await _cloudinary.uploadImage(file.path);
      }
      final docData = {
        'eventId': eventId,
        'userId': userId,
        'type': type.name,
        'fileUrl': fileUrl,
        'createdAt': Timestamp.now(),
        'eventDate': eventDate,
      };
      await _db.collection('tickets').add(docData);
      await fetchTickets(userId);
    } catch (e) {
      debugPrint('❌Errore addTicket: $e');
    }
  }

  Future<void> deleteTicket(String id, String userId) async {
    try {
      await _db.collection('tickets').doc(id).delete();
      _tickets.removeWhere((t) => t.id == id);
      await fetchTickets(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌Errore delete tickets: $e');
    }
  }

  Future<void> updateTicket({
    required String id,
    required String userId,
    String? eventId,
    TicketType? type,
    File? newFile,
    DateTime? eventDate,
  }) async {
    try {
      final docRef = _db.collection('tickets').doc(id);
      final data = <String, dynamic>{};

      // campi modificabili
      if (eventId != null) data['eventId'] = eventId;
      if (type != null) data['type'] = type.name;
      if (eventDate != null) data['eventDate'] = eventDate;

      // upload file
      if (newFile != null) {
        debugPrint('▶️ updateTicket: uploading file ${newFile.path}');
        final url = await _cloudinary.uploadImage(newFile.path);
        debugPrint('✅ updateTicket: got new URL: $url');
        data['fileUrl'] = url;
      }

      if (data.isEmpty) {
        debugPrint('⚠️ updateTicket: niente da aggiornare');
        return;
      }

      debugPrint('▶️ updateTicket: updating Firestore with $data');
      await docRef.update(data);
      debugPrint('✅ updateTicket: Firestore updated');

      // ricarico la lista
      await fetchTickets(userId);
      debugPrint('✅ updateTicket: tickets reloaded, total=${_tickets.length}');
    } catch (e) {
      debugPrint('❌ updateTicket error: $e');
    }
  }
}
