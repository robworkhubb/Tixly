// lib/widgets/post_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tixly/features/feed/data/models/post_model.dart';
import 'package:tixly/features/profile/data/models/user_model.dart';
import 'package:tixly/features/feed/data/providers/post_provider.dart';
import 'package:tixly/features/feed/data/providers/comment_provider.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';
import '../screens/comment_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String? currentUid;

  const PostCard({Key? key, required this.post, required this.currentUid})
    : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();

    // Se non abbiamo ancora caricato il profilo dell'autore, chiamalo:
    if (!userProv.cache.containsKey(widget.post.userId)) {
      context.read<UserProvider>().loadProfile(widget.post.userId);
    }

    // Prendi il profilo: o dalla cache o null
    final author = userProv.cache[widget.post.userId];

    final authorName = author?.displayName ?? 'Utente Sconosciuto';
    final authorImage = author?.profileImageUrl;

    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id);
    final postStream = postRef.snapshots();
    final likeStream = widget.currentUid != null
        ? postRef.collection('likes').doc(widget.currentUid).snapshots()
        : const Stream<DocumentSnapshot>.empty();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ——— Header con avatar e nome autore ———
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: authorImage != null
                        ? NetworkImage(authorImage)
                        : null,
                    child: authorImage == null ? Text(authorName[0]) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ——— Immagine del post ———
            if (widget.post.mediaUrl?.isNotEmpty == true)
              CachedNetworkImage(
                imageUrl: widget.post.mediaUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),

            // ——— Contenuto testuale ———
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.post.content),
            ),

            // ——— Footer like/comment/share ———
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Like button + count
                  StreamBuilder<DocumentSnapshot>(
                    stream: likeStream,
                    builder: (_, snap) {
                      final liked = snap.hasData && snap.data!.exists;
                      return IconButton(
                        icon: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : null,
                        ),
                        onPressed: widget.currentUid == null
                            ? null
                            : () => context.read<PostProvider>().toggleLike(
                                widget.post.id,
                                widget.currentUid!,
                              ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: postStream,
                    builder: (_, snap) {
                      final count = (snap.data?.data()?['likes'] ?? 0)
                          .toString();
                      return Text(count);
                    },
                  ),

                  const SizedBox(width: 16),

                  // Comment button + count
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (_) => CommentSheet(postId: widget.post.id),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    (context
                                .watch<CommentProvider>()
                                .commentsCache[widget.post.id]
                                ?.length ??
                            0)
                        .toString(),
                  ),

                  const Spacer(),

                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: integra share_plus
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
