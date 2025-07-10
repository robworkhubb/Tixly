// ignore_for_file: unnecessary_cast

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/core/services/supabase_storage_service.dart';

class WalletProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();

  static const int _perPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  final List<Ticket> _tickets = [];

  bool get isLoading => _isLoading;
  bool get hasMore   => _hasMore;
  List<Ticket> get ticket => List.unmodifiable(_tickets);

  Future<void> fetchTickets(String userId, {bool clear = true}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    if (clear) {
      _tickets.clear();
      _lastDoc = null;
      _hasMore = true;
    }

    Query<Map<String, dynamic>> query = _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDate')
        .limit(_perPage);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snap = await query.get();
    final fetched = snap.docs.map((d) => Ticket.fromMap(d.data(), d.id)).toList();

    if (fetched.length < _perPage) _hasMore = false;
    _tickets.addAll(fetched);
    if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;

    _isLoading = false;
    notifyListeners();
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
      String? rawFileUrl;

      if (file != null) {
        final isPdf = type == TicketType.pdf;
        final resp = await _storageService.uploadFile(
          file: file, bucket: 'tickets', isPdf: isPdf,
        );
        rawFileUrl = resp['rawUrl'] as String?;
        fileUrl    = isPdf ? resp['thumbUrl'] as String? : rawFileUrl;
      }

      final docData = {
        'eventId'   : eventId,
        'userId'    : userId,
        'type'      : type.name,
        'fileUrl'   : fileUrl,
        'rawFileUrl': rawFileUrl,
        'eventDate' : eventDate,
        'createdAt' : Timestamp.now(),
      };

      await _db.collection('tickets').add(docData);
      await fetchTickets(userId, clear: true);
    } catch (e) {
      debugPrint('❌ Errore addTicket: $e');
    }
  }

  Future<void> deleteTicket(String id, String userId) async {
    try {
      await _db.collection('tickets').doc(id).delete();
      _tickets.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Errore deleteTicket: $e');
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

      if (eventId != null)    data['eventId']   = eventId;
      if (type != null)       data['type']      = type.name;
      if (eventDate != null)  data['eventDate'] = Timestamp.fromDate(eventDate);

      if (newFile != null && type != null) {
        final isPdf = type == TicketType.pdf;
        final resp = await _storageService.uploadFile(
          file: newFile, bucket: 'tickets', isPdf: isPdf,
        );
        data['rawFileUrl'] = isPdf ? resp['rawUrl'] : null;
        data['fileUrl']    = isPdf ? resp['thumbUrl'] : resp['rawUrl'];
      }

      if (data.isNotEmpty) {
        await docRef.update(data);
        await fetchTickets(userId, clear: true);
      }
    } catch (e) {
      debugPrint('❌ updateTicket error: $e');
    }
  }
}