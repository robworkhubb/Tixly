import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Scegli l'URL giusto
    final isPdf = ticket.type == TicketType.pdf;
    final url = isPdf ? ticket.rawFileUrl : ticket.fileUrl;

    // Log URL scelto
    print('[TicketDetailScreen] URL scelto: ' + (url ?? 'null'));

    // 2️⃣ Se non c'è URL, mostro un messaggio
    if (url == null) {
      return Scaffold(
        appBar: AppBar(title: Text(ticket.eventId)),
        body: const Center(child: Text('Nessun file disponibile')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(ticket.eventId)),
      body: FutureBuilder<File>(
        future: DefaultCacheManager().getSingleFile(url),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            // Log errore
            print(
              '[TicketDetailScreen] Errore caricamento file: '
              '${snap.error?.toString() ?? 'no data'}',
            );
            return Center(
              child: Text(
                'Errore caricamento file\n'
                'Dettagli: \\n${snap.error?.toString() ?? 'no data'}',
              ),
            );
          }
          final file = snap.data!;
          // Log path file scaricato
          print('[TicketDetailScreen] File scaricato: ' + file.path);

          // 3️⃣ Branch PDF vs Immagine
          if (isPdf) {
            return PDFView(
              filePath: file.path,
              enableSwipe: true,
              swipeHorizontal: false,
            );
          } else {
            return PhotoView(
              imageProvider: FileImage(file),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          }
        },
      ),
    );
  }
}
