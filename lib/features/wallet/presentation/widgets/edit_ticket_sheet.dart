import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/wallet/data/providers/wallet_provider.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;


class EditTicketSheet extends StatefulWidget {
  final Ticket ticket;
  const EditTicketSheet({Key? key, required this.ticket}) : super(key: key);

  @override
  State<EditTicketSheet> createState() => _EditTicketSheetState();
}

class _EditTicketSheetState extends State<EditTicketSheet> {
  late TextEditingController _eventIdCtrl;
  late TicketType _selectedType;
  DateTime? _eventDate;
  File? _newFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventIdCtrl = TextEditingController(text: widget.ticket.eventId);
    _selectedType = widget.ticket.type;
    _eventDate   = widget.ticket.eventDate;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate!,
      firstDate: now.subtract(const Duration(days: 365*5)),
      lastDate:  now.add(const Duration(days: 365*5)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf','jpg','png','jpeg'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() => _newFile = File(res.files.single.path!));
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
    await context.read<WalletProvider>().updateTicket(
      id: widget.ticket.id,
      userId: uid,
      eventId: _eventIdCtrl.text.trim(),
      type: _selectedType,
      newFile: _newFile,
      eventDate: _eventDate,
    );
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _eventIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children:[
            const Text('Modifica Biglietto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventIdCtrl,
              decoration: const InputDecoration(labelText: 'ID Evento'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TicketType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: TicketType.values.map((t)=>
                  DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))
              ).toList(),
              onChanged: (t) => setState(()=>_selectedType = t!),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Data Evento'),
                child: Text('${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'),
              ),
            ),
            const SizedBox(height: 12),
            if (_newFile != null)
              Text('Nuovo file selezionato')
            else
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Cambiare file/PDF'),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Salva Modifiche'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}