import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tixly/providers/user_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../providers/auth_provider.dart' as app;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _firstLoadDone = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProv = context.watch<PostProvider>();
    final uid = context.watch<UserProvider>().user?.uid;
    return Consumer<PostProvider>(
      builder: (context, postProv, _) {
        final posts = postProv.posts;
        if (postProv.isLoading && posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (posts.isEmpty) {
          return const Center(child: Text('Nessun post ancora'));
        }

        return RefreshIndicator(
          child: ListView.builder(
            itemBuilder: (_, i) => PostCard(post: posts[i], uid: uid),
            itemCount: posts.length,
          ),
          onRefresh: postProv.fetchPosts,
        );
      },
    );
  }
}
