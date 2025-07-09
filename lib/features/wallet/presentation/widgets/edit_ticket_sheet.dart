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
  File? _pickedFile;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? _eventDate;

  @override
  void initState() {
    super.initState();
    _eventIdCtrl = TextEditingController(text: widget.ticket.eventId);
    final stored = widget.ticket.type;
    _selectedType = TicketType.values.firstWhere(
      (t) => t.name.toLowerCase() == stored,
      orElse: () => TicketType.pdf,
    );
    _eventDate = widget.ticket.eventDate;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year - 5), // fino a 5 anni fa
      lastDate: DateTime(now.year + 5), // fino a 5 anni nel futuro
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  @override
  void dispose() {
    _eventIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
    await context.read<WalletProvider>().updateTicket(
      id: widget.ticket.id,
      userId: uid,
      eventId: _eventIdCtrl.text.trim(),
      type: _selectedType,
      newFile: _pickedFile,
      eventDate: _eventDate,
    );
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        // se vogliamo far sparire l'anteprima vecchia
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Modifica Biglietto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Event ID
                TextFormField(
                  controller: _eventIdCtrl,
                  decoration: const InputDecoration(labelText: 'ID Evento'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obbligatorio' : null,
                ),
                const SizedBox(height: 12),

                // Tipo
                DropdownButtonFormField<TicketType>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: TicketType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (type) {
                    if (type != null) setState(() => _selectedType = type);
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Data Evento'),
                    child: Text(
                      _eventDate == null
                          ? 'Seleziona data'
                          : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // File picker / preview
                if (_pickedFile != null)
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: _selectedType == TicketType.pdf
                          ? null
                          : DecorationImage(
                              image: FileImage(_pickedFile!),
                              fit: BoxFit.cover,
                            ),
                      color: Colors.grey[200],
                    ),
                    child: _selectedType == TicketType.pdf
                        ? const Center(
                            child: Icon(
                              Icons.picture_as_pdf,
                              size: 60,
                              color: Colors.redAccent,
                            ),
                          )
                        : null,
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Seleziona file/PDF'),
                  ),
                const SizedBox(height: 24),

                // Salva
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Salva'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
