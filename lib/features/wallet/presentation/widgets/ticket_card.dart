import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const TicketCard({
    Key? key,
    required this.ticket,
    required this.onEdit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPdf = ticket.type == TicketType.pdf;
    final thumbUrl = ticket.fileUrl;

    Widget thumbWidget;
    if (isPdf) {
      // PDF → icona grande
      thumbWidget = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.picture_as_pdf, size: 32, color: Colors.redAccent),
        ),
      );
    } else if (thumbUrl != null) {
      // Immagine → prova a caricarla
      thumbWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: thumbUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
          ),
          errorWidget: (_, __, ___) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, size: 32),
          ),
        ),
      );
    } else {
      // Nessun file → icona generica
      thumbWidget = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.confirmation_number_outlined, size: 32, color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              thumbWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.eventId,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ticket.eventDate.day}/${ticket.eventDate.month}/${ticket.eventDate.year}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ],
          ),
        ),
      ),
    );
  }
}
