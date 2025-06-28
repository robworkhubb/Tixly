import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/services/cloudinary_service.dart';
import '../models/ticket_model.dart';

class WalletProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryService();

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

  Future<void> addTicket({
    required String eventId,
    required String userId,
    required TicketType type,
    File? file,
  }) async {
    try {
      String? fileUrl;
      if(file != null) {
        fileUrl = await _cloudinary.uploadImage(file.path);
      }
      final docData = {
        'eventId': eventId,
        'userId': userId,
        'type': type.name,
        'fileUrl': fileUrl,
        'createdAt': Timestamp.now
      };
      await _db.collection('tickets').add(docData);
      await fetchTickets(userId);
    } catch (e) {
      debugPrint('Errore addTicket: $e');
    }
  }

  Future<void> deleteTicket(String id, String userId) async {
    try {
      await _db.collection('tickets').doc(id).delete();
      await fetchTickets(userId);
    }catch (e){
      debugPrint('Errore delete tickets: $e');
    }
  }



}
