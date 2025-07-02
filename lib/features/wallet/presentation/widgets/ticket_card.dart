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
    final bool isPdf = ticket.fileUrl?.toLowerCase().endsWith('.pdf') ?? false;
    final String? url = ticket.fileUrl;

    // Thumbnail widget
    Widget thumbnail;
    if (isPdf) {
      thumbnail = Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.picture_as_pdf,
          size: 30,
          color: Colors.redAccent,
        ),
      );
    } else if (url != null) {
      thumbnail = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(width: 50, height: 50, color: Colors.grey[200]),
          errorWidget: (_, __, ___) => Container(
            width: 50,
            height: 50,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    } else {
      thumbnail = Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.confirmation_number_outlined,
          size: 30,
          color: Colors.grey,
        ),
      );
    }

    final dateText = ticket.eventDate != null
        ? '${ticket.eventDate.day}/${ticket.eventDate.month}/${ticket.eventDate.year}'
        : 'Non hai inserito la data';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticket: ticket),
            ),
          );
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: thumbnail,
        title: Text(
          ticket.eventId,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: -8,
          children: [
            Chip(
              label: Text(
                ticket.type.name.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
            Chip(
              avatar: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                size: 16,
                color: Colors.grey[700],
              ),
              label: Text(
                ticket.id.substring(0, 6),
                style: const TextStyle(fontSize: 10),
              ),
            ),
            Chip(
              label: Text(
                dateText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.deepPurple),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
