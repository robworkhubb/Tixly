import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tixly Home')),
      body: const Center(
        child: Text('Benvenuto su Tixly!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
