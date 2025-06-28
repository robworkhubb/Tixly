import 'package:flutter/material.dart';
import '../models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const TicketCard({
    Key? key,
    required this.ticket,
    required this.onDelete,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'TicketCard[${ticket.id}] fileUrl=${ticket.fileUrl} type=${ticket.type.name}'
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          if (ticket.fileUrl?.isNotEmpty == true)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(ticket.fileUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (ticket.type == TicketType.qr)
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.qr_code, size: 40, color: Colors.grey),
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[100],
              child: const Center(
                child: Icon(Icons.event, size: 40, color: Colors.grey),
              ),
            ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evento: ${ticket.eventId}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tipo: ${ticket.type.name.toUpperCase()}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Caricato il: '
                        '${ticket.createdAt.day.toString().padLeft(2, '0')}/'
                        '${ticket.createdAt.month.toString().padLeft(2, '0')}/'
                        '${ticket.createdAt.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),

          // Azioni: condividi e elimina
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: onShare,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}