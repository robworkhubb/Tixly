import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rawUrl = ticket.rawFileUrl;
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.eventId),
      ),
      body: rawUrl == null
          ? const Center(child: Text('Nessun file disponibile'))
          : FutureBuilder<File>(
        future: DefaultCacheManager().getSingleFile(rawUrl),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Errore caricamento file'));
          }

          final file = snap.data!;
          final lower = rawUrl.toLowerCase();

          // se è un PDF, usa flutter_pdfview
          if (lower.endsWith('.pdf')) {
            return PDFView(
              filePath: file.path,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            );
          }

          // altrimenti è un’immagine
          return InteractiveViewer(
            child: Image.file(file, fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}