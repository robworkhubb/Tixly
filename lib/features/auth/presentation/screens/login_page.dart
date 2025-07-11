// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as app;
import 'package:tixly/features/profile/data/providers/user_provider.dart';
import 'package:tixly/features/profile/presentation/screens/home_page.dart';
import 'package:tixly/features/auth/presentation/screens/register_page.dart';
import 'package:tixly/features/auth/data/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final user = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        setState(() {
          _errorMessage = "Login fallito: Utente non trovato.";
        });
      } else {
        Provider.of<UserProvider>(context, listen: false).loadUser(user.uid);
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
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC13378), Color(0xFF4A4A4A), Color(0xFF0A304A)],
              begin: Alignment.bottomCenter,
              end: Alignment.topRight,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 305,
                height: 470,
                padding: const EdgeInsets.all(24),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'images/icons/ticket-solid.svg',
                            width: 50,
                            height: 33,
                            color: Color(0xFFC13378),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Tixly',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: const Color(0xFF122431),
                          filled: true,
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF122431),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);

                          final ok = await context
                              .read<app.AuthProvider>()
                              .login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                          setState(() => _isLoading = false);

                          if (!ok) {
                            setState(
                              () => _errorMessage = 'Credenziali errate',
                            );
                            return;
                          }

                          // LOGIN OK ➔ naviga e rimuovi tutte le rotte precedenti
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008080),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Login'),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RegisterPage()),
                          );
                        },
                        child: const Text(
                          'Registrati',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
