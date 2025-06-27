import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider.dart';
import '../providers/auth_provider.dart';

class CreateMemorySheet extends StatefulWidget {
  const CreateMemorySheet({super.key});

  @override
  State<CreateMemorySheet> createState() => _CreateMemorySheetState();
}

class _CreateMemorySheetState extends State<CreateMemorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl       = TextEditingController();
  final _artistCtrl      = TextEditingController();
  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime? _selectedDate;
  File? _imageFile;
  int _rating = 0;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xf != null) setState(() => _imageFile = File(xf.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    setState(() => _isLoading = true);

    final userId = context.read<AuthProvider>().firebaseUser!.uid;
    await context.read<MemoryProvider>().addMemory(
      userId:     userId,
      title:      _titleCtrl.text.trim(),
      artist:     _artistCtrl.text.trim(),
      location:   _locationCtrl.text.trim(),
      description:_descriptionCtrl.text.trim(),
      date:       _selectedDate!,
      imageFile:  _imageFile,
      rating:     _rating,
    );

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
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
                const Text('Nuovo ricordo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Titolo
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titolo evento'),
                  validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                ),
                const SizedBox(height: 8),

                // Artista
                TextFormField(
                  controller: _artistCtrl,
                  decoration: const InputDecoration(labelText: 'Artista'),
                  validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                ),
                const SizedBox(height: 8),

                // Data
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Data e luogo'),
                    child: Text(
                      _selectedDate == null
                          ? 'Seleziona data'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Luogo
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(labelText: 'Luogo'),
                  validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                ),
                const SizedBox(height: 8),

                // Descrizione
                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
                const SizedBox(height: 8),

                // Rating
                Row(
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                      onPressed: () => setState(() => _rating = i + 1),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Immagine
                _imageFile != null
                    ? Image.file(_imageFile!, height: 120, fit: BoxFit.cover)
                    : OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Aggiungi foto'),
                ),
                const SizedBox(height: 16),

                // Pulsante salva
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Salva'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}