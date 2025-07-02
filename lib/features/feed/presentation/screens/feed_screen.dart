import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';
import 'package:tixly/features/feed/data/providers/post_provider.dart';
import 'package:tixly/features/feed/presentation/widgets/post_card.dart';
import 'package:tixly/features/feed/presentation/widgets/create_post_sheet.dart';
import 'package:tixly/features/feed/presentation/screens/comment_sheet.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _firstLoadDone = false;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carica la prima pagina
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_firstLoadDone) {
        context.read<PostProvider>().fetchPosts(clear: true);
        _firstLoadDone = true;
      }
    });

    // Listener per infinite scroll
    _scrollCtrl.addListener(() {
      final prov = context.read<PostProvider>();
      if (_scrollCtrl.position.pixels >=
              _scrollCtrl.position.maxScrollExtent - 200 &&
          prov.hasMore &&
          !prov.isLoading) {
        prov.fetchPosts(clear: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() {
    // Ricarica tutto da capo
    return context.read<PostProvider>().fetchPosts(clear: true);
  }

  @override
  Widget build(BuildContext context) {
    final postProv = context.watch<PostProvider>();
    final posts = postProv.posts;
    final uid = context.watch<UserProvider>().user?.uid;

    Widget child;

    // 1) Loading iniziale
    if (postProv.isLoading && posts.isEmpty) {
      child = const Center(child: CircularProgressIndicator());
    }
    // 2) Empty state (ma lista scrollabile per il refresh)
    else if (posts.isEmpty) {
      child = ListView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(
            child: Text('Nessun post ancora', style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    }
    // 3) Lista piena con paginazione
    else {
      child = ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + (postProv.hasMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i < posts.length) {
            return PostCard(post: posts[i], currentUid: uid);
          }
          // loader di fine lista
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: RefreshIndicator(onRefresh: _onRefresh, child: child),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // apri CreatePostSheet...
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
