import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _auth;
  final ProfileService _service;

  bool _loading = false;
  User? _user;

  ProfileProvider({fb_auth.FirebaseAuth? auth, ProfileService? service})
    : _auth = auth ?? fb_auth.FirebaseAuth.instance,
      _service = service ?? ProfileService();

  bool get loading => _loading;

  User? get user => _user;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final uid = _auth.currentUser!.uid;
    final snap = await _service.fetchProfile(uid);
    _user = snap;  // User.fromMap usa già i default
    _loading = false;
    notifyListeners();
  }

  Future<void> setDisplayName(String name) async {
    final uid = _auth.currentUser!.uid;
    await _service.updateDisplayName(uid, name);
    _user = _user!.copyWith(displayName: name);
    notifyListeners();
  }

  Future<void> setAvatar(File file) async {
    final uid = _auth.currentUser!.uid;

    // uploadAvatar ora ritorna il String
    final url = await _service.uploadAvatar(uid, file);

    // aggiornalo anche in memoria
    _user = _user!.copyWith(profileImageUrl: url);
    notifyListeners();
  }

  // …

  Future<void> toggleDarkMode(bool on) async {
    final uid = _auth.currentUser!.uid;
    await _service.updateDarkMode(uid, on);
    _user = _user!.copyWith(darkMode: on);
    notifyListeners();
  }
}
