import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/feed/data/providers/post_provider.dart';
import 'package:tixly/features/feed/data/models/post_model.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => _imageFile = File(xFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userId = context.read<UserProvider>().user!.uid;
    await context.read<PostProvider>().addPost(
      userId: userId,
      content: _contentCtrl.text,
      imageFile: _imageFile,
    );

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nuovo post',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contentCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Racconta la tua esperienza...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Testo obbligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 150,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          onPressed: () => _imageFile = null,
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: const Text('Aggiungi immagine'),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Pubblica'),
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
