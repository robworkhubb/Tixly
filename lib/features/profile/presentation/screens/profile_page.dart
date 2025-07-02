import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final ok = await context.read<app.AuthProvider>().logout();
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
