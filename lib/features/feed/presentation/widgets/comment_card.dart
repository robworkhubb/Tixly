// lib/widgets/comment_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/feed/data/models/comment_model.dart';
import 'package:tixly/features/profile/data/models/user_model.dart';
import 'package:tixly/features/feed/data/providers/comment_provider.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final currentUser = userProv.user;

    // Se è un commento di un altro utente e non è già in cache, lo carichiamo
    if (comment.userId != currentUser?.uid &&
        !userProv.cache.containsKey(comment.userId)) {
      // Non serve await qui: al termine del fetch, notifyListeners ricostruirà il widget
      context.read<UserProvider>().loadProfile(comment.userId);
    }

    // Recupera il profilo: se è il corrente, uso currentUser, altrimenti dalla cache
    final author = (comment.userId == currentUser?.uid)
        ? currentUser
        : userProv.cache[comment.userId];

    final authorName = author?.displayName ?? 'Utente Sconosciuto';
    final authorAvatar = author?.profileImageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar: prima immagine, poi iniziale se non c'è URL
          CircleAvatar(
            radius: 16,
            backgroundImage: authorAvatar != null
                ? NetworkImage(authorAvatar)
                : null,
            child: authorAvatar == null
                ? Text(authorName.isNotEmpty ? authorName[0] : '?')
                : null,
          ),
          const SizedBox(width: 8),
          // Contenuto commento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 4),
                Text(
                  TimeOfDay.fromDateTime(comment.timestamp).format(context),
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
