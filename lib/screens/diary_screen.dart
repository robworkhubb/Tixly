import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/widgets/create_memory_sheet.dart';
import 'package:tixly/widgets/memory_card.dart';
import '../providers/memory_provider.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      //context.read<MemoryProvider>().loadMore(); //TODO Aggiungere nel provider funzione che carica altri memories
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memories = context
        .watch<MemoryProvider>()
        .memories;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'I miei ricordi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rivivi i tuoi concerti e salva i momenti più belli',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Expanded(
                child: memories.isEmpty
                    ? const Center (
                  child: Text(
                    'Non hai ancora salvato ricordi. \n Aggiungine e rivivi le tue esperienze!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 16
                    ),
                  ),
                )
                    : ListView.builder(
                    controller: _scrollController,
                    itemCount: memories.length,
                    itemBuilder: (context, i){
                      final m = memories[i];
                      return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                        child: MemoryCard(memory: m),
                      );
                    }
                )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateMemorySheet,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _openCreateMemorySheet () {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
        ),
        builder: (_) => CreateMemorySheet()
    );
  }

}
