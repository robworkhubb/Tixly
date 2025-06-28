import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/widgets/create_ticket_sheet.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart' as app;
import '../widgets/ticket_card.dart';
import '../widgets/create_ticket_sheet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<app.AuthProvider>().firebaseUser?.uid;
      if (uid != null) {
        context.read<WalletProvider>().fetchTickets(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tickets = context.watch<WalletProvider>().ticket;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il mio Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
          await context.read<WalletProvider>().fetchTickets(uid);
        },
        child: tickets.isEmpty
            ? const Center(
          child: Text(
            'Nessun biglietto salvato.\nAggiungine uno cliccando sul + in basso.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45, fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, i) {
            final t = tickets[i];
            return Dismissible(
              key: ValueKey(t.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Conferma eliminazione'),
                    content: const Text('Sei sicuro di voler eliminare questo biglietto?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina')),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                context.read<WalletProvider>().deleteTicket(t.id, t.userId);
              },
              child: TicketCard(
                ticket: t,
                onDelete: () => context.read<WalletProvider>().deleteTicket(t.id, t.userId),
                onShare: () {
                  // TODO: implement share functionality
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const CreateTicketSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}