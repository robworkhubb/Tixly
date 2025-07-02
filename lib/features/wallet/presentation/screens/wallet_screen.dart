import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;
import 'package:tixly/features/wallet/data/providers/wallet_provider.dart';
import 'package:tixly/features/wallet/presentation/widgets/create_ticket_sheet.dart';
import 'package:tixly/features/wallet/presentation/widgets/edit_ticket_sheet.dart';
import 'package:tixly/features/wallet/presentation/widgets/ticket_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final String _uid;
  late final WalletProvider _walletProv;

  @override
  void initState() {
    super.initState();
    // Prendi uid e provider una sola volta
    final auth = context.read<app.AuthProvider>();
    _uid = auth.firebaseUser?.uid ?? '';
    _walletProv = context.read<WalletProvider>();
    // Caricamento iniziale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_uid.isNotEmpty) _walletProv.fetchTickets(_uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Selettori isolano i rebuild
    final tickets = context.select<WalletProvider, List<Ticket>>(
      (prov) => prov.ticket,
    );
    final isLoading = context.select<WalletProvider, bool>(
      (prov) => prov.isLoading,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Il mio Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _walletProv.fetchTickets(_uid),
        child: isLoading && tickets.isEmpty
            ? _buildSkeletonList()
            : tickets.isEmpty
            ? _buildEmptyState()
            : _buildTicketList(tickets),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSkeletonList() {
    // Mostra placeholder durante il caricamento
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => const _TicketPlaceholder(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Nessun biglietto salvato.\nAggiungine uno cliccando sul + in basso.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black45, fontSize: 16),
      ),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets) {
    return ListView.builder(
      itemCount: tickets.length,
      itemExtent: 100, // altezza fissa per performance
      cacheExtent: 200,
      itemBuilder: (context, i) {
        final ticket = tickets[i];
        return Dismissible(
          key: ValueKey(ticket.id),
          direction: DismissDirection.endToStart,
          background: _buildDeleteBackground(),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) =>
              _walletProv.deleteTicket(ticket.id, ticket.userId),
          child: TicketCard(
            ticket: ticket,
            onEdit: () => _showEditSheet(ticket),
          ),
        );
      },
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo biglietto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateTicketSheet(),
    );
  }

  void _showEditSheet(Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditTicketSheet(ticket: ticket),
    );
  }
}

class _TicketPlaceholder extends StatelessWidget {
  const _TicketPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 60, height: 60, color: Colors.grey[300]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 100, color: Colors.grey[300]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 24, height: 24, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
