import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _register() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _usernameController.text.trim();

    print('Nome inserito: "$displayName"');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        Navigator.of(context).pop();
      }

      if (user == null) {
        setState(() {
          _errorMessage = 'Registrazione fallita. Riprova';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrati su Tixly')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(label: Text('Nome utente')),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(label: Text('Email')),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(label: Text('Password')),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: Text('Registrati a Tixly!'),
                  ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
