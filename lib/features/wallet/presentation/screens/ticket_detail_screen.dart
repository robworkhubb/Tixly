import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

/// Ottimizzato per performance:
/// - StatefulWidget per mantenere il future e non rifetchare il file a ogni rebuild
/// - Uso di ListView per permettere lo scrolling dei dettagli
/// - Pre-calcolo di isPdf in initState
/// - Altezza fissa del preview con SizedBox
class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late final Future<File> _fileFuture;
  late final bool _isPdf;

  @override
  void initState() {
    super.initState();
    // Carichiamo il file solo una volta
    _fileFuture = DefaultCacheManager().getSingleFile(widget.ticket.fileUrl!);
    // Pre-calcoliamo il tipo
    _isPdf = widget.ticket.fileUrl!.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio Biglietto')),
      body: Hero(
        tag: 'ticket_${widget.ticket.id}',
        child: FutureBuilder<File>(
          future: _fileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Errore caricamento file'));
            }
            final file = snapshot.data!;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Preview fisso (immagine o PDF)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: _isPdf
                      ? PDFView(
                          filePath: file.path,
                          enableSwipe: true,
                          swipeHorizontal: false,
                        )
                      : PhotoView(
                          imageProvider: FileImage(file),
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ticket.eventId,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipo: ${widget.ticket.type.name.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data: ${widget.ticket.eventDate.day}/${widget.ticket.eventDate.month}/${widget.ticket.eventDate.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
