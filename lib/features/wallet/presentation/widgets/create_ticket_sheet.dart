import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/wallet/data/providers/wallet_provider.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

class CreateTicketSheet extends StatefulWidget {
  const CreateTicketSheet({Key? key}) : super(key: key);

  @override
  State<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<CreateTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _eventIdCtrl = TextEditingController();
  TicketType _selectedType = TicketType.pdf;
  File? _pickedFile;
  bool _isLoading = false;
  DateTime? _eventDate;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickDate(FormFieldState<DateTime> state) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      state.didChange(picked);
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
    await context.read<WalletProvider>().addTicket(
      eventId: _eventIdCtrl.text.trim(),
      userId: uid,
      type: _selectedType,
      file: _pickedFile,
      eventDate: _eventDate!,
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Aggiungi Biglietto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Event ID
                TextFormField(
                  controller: _eventIdCtrl,
                  decoration: const InputDecoration(labelText: 'ID Evento'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'ID evento obbligatorio' : null,
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

                // Data Evento Obbligatoria
                FormField<DateTime>(
                  initialValue: _eventDate,
                  validator: (val) =>
                      val == null ? 'Data evento obbligatoria' : null,
                  builder: (state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Data Evento *',
                        errorText: state.errorText,
                        border: const OutlineInputBorder(),
                      ),
                      child: InkWell(
                        onTap: () => _pickDate(state),
                        child: Text(
                          state.value == null
                              ? 'Seleziona data'
                              : '${state.value!.day}/${state.value!.month}/${state.value!.year}',
                          style: TextStyle(
                            color: state.value == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // File picker / preview
                if (_pickedFile != null) ...[
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
                  ),
                  const SizedBox(height: 12),
                ],
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
