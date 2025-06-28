import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/comment_card.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _ctrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().fetchComments(widget.postId);
    });
  }

  Future<void> _send() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _isSending = true;
    });
    final uid = context.read<AuthProvider>().firebaseUser!.uid;
    await context.read<CommentProvider>().addComment(
      postId: widget.postId,
      userId: uid,
      content: txt,
    );
    _ctrl.clear();
    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = context.watch<CommentProvider>().commentsCache[widget.postId] ?? [];

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Commenti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: comments.isEmpty
                  ? const Center(child: Text('Nessun commento ancora'))
                  : ListView.builder(
                itemCount: comments.length,
                itemBuilder: (_, i) => CommentCard(comment: comments[i]),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(hintText: 'Scrivi un commento...'),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
