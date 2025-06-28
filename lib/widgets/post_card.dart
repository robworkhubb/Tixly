import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/providers/comment_provider.dart';
import 'package:tixly/providers/post_provider.dart';
import 'package:tixly/providers/user_provider.dart';
import 'package:tixly/screens/comment_sheet.dart';
import '../models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String? uid;

  const PostCard({super.key, required this.post, required this.uid});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final cProv = context.read<CommentProvider>();
    // uid dell'utente corrente (null se non loggato ancora)
    final uid = context.watch<UserProvider>().user?.uid;
    debugPrint('PostCard uid: $uid for post ${widget.post.id}');
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id);

    // stream sul documento post per il contatore
    final postStream = postRef.snapshots();

    // stream personale (solo se uid presente)
    final likeStream = uid != null
        ? postRef.collection('likes').doc(uid).snapshots()
        : Stream<DocumentSnapshot>.empty(); // stream vuoto finché uid null

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.post.mediaUrl?.isNotEmpty == true)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: widget.post.mediaUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const AspectRatio(
                  aspectRatio: 16/9,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
              )
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.post.content),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16, bottom: 8),
            child: Row(
              children: [
                // like button realtime
                StreamBuilder<DocumentSnapshot>(
                  stream: likeStream,
                  builder: (_, snap) {
                    final liked = snap.hasData && snap.data!.exists;
                    return IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : null,
                      ),
                      // disabilita se uid assente
                      onPressed: uid == null
                          ? null
                          : () => context
                          .read<PostProvider>()
                          .toggleLike(widget.post.id, uid),
                    );
                  },
                ),
                const SizedBox(width: 4),
                // contatore globale realtime
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: postStream,
                  builder: (_, snap) {
                    final count = (snap.data?.data()?['likes'] ?? 0).toString();  // 👈 likes
                    return Text(count);
                  },
                ),

                const SizedBox(width: 16),

                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: (){
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => CommentSheet(postId: widget.post.id),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Consumer<CommentProvider>(
                    builder: (ctx, cProv, _) {
                      final comments = cProv.commentsCache[widget.post.id] ?? [];
                      return Text(comments.length.toString());
                    }
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

