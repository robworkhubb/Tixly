// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;
import 'package:tixly/features/wallet/data/providers/wallet_provider.dart';
import 'package:tixly/features/wallet/presentation/screens/ticket_detail_screen.dart';
import 'package:tixly/features/wallet/presentation/widgets/create_ticket_sheet.dart';
import 'package:tixly/features/wallet/presentation/widgets/edit_ticket_sheet.dart';
import 'package:tixly/features/wallet/presentation/widgets/ticket_card.dart';
import 'dart:async';
import '../widgets/ticket_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<app.AuthProvider>().firebaseUser?.uid;
      if (uid != null) {
        context.read<WalletProvider>().fetchTickets(uid);
      }
    });
    _scrollCtrl.addListener(() {
      final prov = context.read<WalletProvider>();
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        if (prov.hasMore && !prov.isLoading && _debounce == null) {
          _debounce = Timer(const Duration(milliseconds: 300), () {
            prov.fetchTickets(context.read<app.AuthProvider>().firebaseUser!.uid, clear: false);
            _debounce?.cancel();
            _debounce = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickets  = context.select<WalletProvider, List<Ticket>>((p) => p.ticket);
    final isLoading = context.select<WalletProvider, bool>((p) => p.isLoading);
    final hasMore   = context.select<WalletProvider, bool>((p) => p.hasMore);

    if (isLoading && tickets.isEmpty) {
      return ListView.builder(
        controller: _scrollCtrl,
        itemCount: 5,
        itemBuilder: (_, __) => const TicketSkeleton(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Il mio Wallet')),
      body: RefreshIndicator(
        onRefresh: () => context.read<WalletProvider>().fetchTickets(context.read<app.AuthProvider>().firebaseUser!.uid),
        child: tickets.isEmpty
            ? const Center(child: Text('Nessun biglietto salvato'))
            : ListView.builder(
          controller: _scrollCtrl,
          itemCount: tickets.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i < tickets.length) {
              final t = tickets[i];
              return RepaintBoundary(
                key: ValueKey(t.id),
                child: TicketCard(
                  ticket: t,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(ticket: t),
                      ),
                    );
                  },
                  onEdit: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => EditTicketSheet(ticket: t),
                    );
                  },
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const CreateTicketSheet(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
