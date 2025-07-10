// ignore_for_file: unused_import

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/profile/data/providers/profile_provider.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;
import 'package:tixly/features/profile/data/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  // ignore: unused_field
  File? _picked;

  @override
  void initState() {
    super.initState();
    final uid = context.read<app.AuthProvider>().firebaseUser!.uid;
    context.read<ProfileProvider>().load().then((_) {
      final user = context.read<ProfileProvider>().user;
      if (user != null) {
        _nameCtrl.text = user.displayName;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    final user = prov.user;
    final uid = context.read<app.AuthProvider>().firebaseUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Il mio Profilo')),
      body: prov.loading || user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final xf = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (xf != null) {
                  try {
                    await prov.setAvatar(File(xf.path));
                    await context.read<UserProvider>().refreshProfile(uid);
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Errore upload avatar: $e')));
                  }
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                child: user.profileImageUrl == null
                    ? Text(user.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 40))
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl..text = user.displayName,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  await prov.setDisplayName(_nameCtrl.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nome aggiornato!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $e')),
                  );
                }
              },
              child: const Text('Aggiorna nome'),
            ),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: user.darkMode,
              onChanged: prov.toggleDarkMode,
            ),
          ],
        ),
      ),
    );
  }
}