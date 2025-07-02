// lib/widgets/memory_card.dart
import 'package:flutter/material.dart';
import 'package:tixly/features/memories/data/models/memory_model.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  const MemoryCard({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔥 debug veloce: controlla cosa arriva davvero
    debugPrint(
      'MemoryCard[${memory.id}] '
      'imageUrl=${memory.imageUrl} '
      'rating=${memory.rating}',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Immagine da URL
          if (memory.imageUrl?.isNotEmpty == true)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                memory.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.broken_image)),
              ),
            ),

          // 2) Testi e stelle
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo
                Text(
                  memory.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Artista
                Text(
                  memory.artist,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                // Descrizione (note), se non vuota
                if (memory.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(memory.description),
                  ),
                // Data e luogo
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memory.dateFormatted,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        memory.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stelline: solo se rating > 0
                if (memory.rating > 0)
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < memory.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
