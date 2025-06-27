import 'package:flutter/material.dart';
import '../models/memory_model.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  const MemoryCard({required this.memory, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(memory.mediaUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(memory.mediaUrl!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  memory.artist,
                  style: const TextStyle(
                    fontSize: 14, color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                if(memory.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      memory.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                    size: 14, color: Colors.black45,
                    ),
                    SizedBox(width: 4),
                    Text(
                      memory.dateFormatted,
                      style: const TextStyle(
                        fontSize: 12, color: Colors.black45,
                      ),
                    ),
                    SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        memory.location,
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index){
                      return Icon(
                        index < memory.stars
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
