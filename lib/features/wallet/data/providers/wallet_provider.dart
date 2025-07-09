import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/core/services/supabase_storage_service.dart';

class WalletProvider with ChangeNotifier {
  String bucket = 'tickets';
  final _db = FirebaseFirestore.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();
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

  // providers/wallet_provider.dart
  Future<void> addTicket({
    required String eventId,
    required String userId,
    required TicketType type,
    File? file,
    required DateTime eventDate,
  }) async {
    try {
      String? fileUrl;
      String? rawFileUrl;

      if (file != null) {
        final isPdf = type == TicketType.pdf;
        final resp = await _storageService.uploadFile(file: file, bucket: bucket, isPdf: isPdf);
        rawFileUrl = isPdf ? resp['rawUrl'] : null;
        fileUrl = isPdf ? resp['thumbUrl'] : resp['rawUrl'];
      }

      final docData = {
        'eventId': eventId,
        'userId': userId,
        'type': type.name,
        'fileUrl': fileUrl,
        'rawFileUrl': rawFileUrl,
        'eventDate': eventDate,
        'createdAt': Timestamp.now(),
      };

      await _db.collection('tickets').add(docData);
      await fetchTickets(userId);
    } catch (e) {
      debugPrint('❌ Errore addTicket: $e');
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

      if (eventId != null) data['eventId'] = eventId;
      if (type != null) data['type'] = type.name;
      if (eventDate != null) data['eventDate'] = Timestamp.fromDate(eventDate);

      if (newFile != null && type != null) {
        final isPdf = type == TicketType.pdf;
        final resp = await _storageService.uploadFile(
          file: newFile,
          bucket: bucket,
          isPdf: isPdf,
        );
        data['rawFileUrl'] = isPdf ? resp['rawUrl'] : null;
        data['fileUrl'] = isPdf ? resp['thumbUrl'] : resp['rawUrl'];
      }

      if (data.isEmpty) {
        debugPrint('⚠️ updateTicket: niente da aggiornare');
        return;
      }

      await docRef.update(data);
      await fetchTickets(userId);
    } catch (e) {
      debugPrint('❌ updateTicket error: $e');
    }
  }
}
