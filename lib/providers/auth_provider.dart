import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixly/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _srv;
  User? _firebaseUser;

  User? get firebaseUser => _firebaseUser;

  AuthProvider(this._srv) {
    _srv.userChanges.listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    final user = await _srv.signIn(email, password);
    debugPrint('sign in restituisce: $user');
    if(user != null) {
      _firebaseUser = user;
      debugPrint('user settato: $_firebaseUser');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    final user = await _srv.signUp(email: email, password: password, displayName: username);

    if(user != null) {
      _firebaseUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() => _srv.signOut();

}