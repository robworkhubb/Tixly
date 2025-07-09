import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/features/wallet/presentation/screens/ticket_detail_screen.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onEdit;

  const TicketCard({Key? key, required this.ticket, required this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = ticket.fileUrl ?? '';
    final isPdf = url.toLowerCase().endsWith('.pdf');

    Widget leading;
    if (isPdf) {
      // Mostra un'icona PDF o una thumb generata in eager/upload
      leading = Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.picture_as_pdf, size: 32, color: Colors.redAccent),
      );
    } else if (url.isNotEmpty) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Colors.grey[200]),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      );
    } else {
      leading = const Icon(
        Icons.confirmation_number_outlined,
        size: 60,
        color: Colors.grey,
      );
    }

    return GestureDetector(
      onTap: () {
        // Se vuoi aprire il dettaglio
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(ticket: ticket),
          ),
        );
      },
      child: Hero(
        tag: 'ticket_${ticket.id}',
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventId,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.type.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}