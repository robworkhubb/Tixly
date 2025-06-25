import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserProvider extends ChangeNotifier {
  //Accediamo al modello che rappresenta l'utente attualmente loggato
  User? _user;

  //Getter per far leggere lo stato da fuori
  User? get user => _user;

  // Metodo per caricare l'utente da Firebase usando il suo UID
  Future<void> loadUser(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      //Se esiste trasforma i dati in un oggetto user e notifica la UI
      if (doc.exists) {
        _user = User.fromMap(doc.data()!);
        notifyListeners();
      } else {
        await fb.FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      debugPrint("Errore loadUser: $e");
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
