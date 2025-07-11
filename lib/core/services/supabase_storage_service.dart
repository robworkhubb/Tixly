import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseStorageService {
  final _client = Supabase.instance.client;
  final _storage = Supabase.instance.client.storage;

  /// 🔐 Upload dell'avatar con accesso sicuro
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    final bucket = 'avatars';
    final ext = file.path.split('.').last;

    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // 1️⃣ Upload su Supabase (bucket privato)
    final res = await _storage.from(bucket).upload(path, file);
    if (res.isEmpty) throw Exception("❌ Errore upload avatar su Supabase");

    // 2️⃣ Signed URL temporaneo (valido 1 ora)
    final signedUrl = await _storage.from(bucket).createSignedUrl(path, 3600);
    if (signedUrl.isEmpty) {
      throw Exception('Non sono riuscito a generare la signed URL');
    }

    return signedUrl;
  }

  /// 📦 Upload generico file (PDF o immagine)
  Future<Map<String, String>> uploadFile({
    required File file,
    required String bucket,
    required bool isPdf,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utente Firebase non autenticato');

    final uid = user.uid;
    final ext = isPdf ? 'pdf' : file.path.split('.').last;
    final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = '$uid/$filename';

    final res = await _storage.from(bucket).upload(path, file);
    if (res.isEmpty) throw Exception("❌ Errore upload su Supabase");

    // Signed URL valida 1 ora
    final signedUrl = await _storage.from(bucket).createSignedUrl(path, 3600);

    return {
      'rawUrl': signedUrl,
      'thumbUrl': signedUrl, // Se in futuro generi una thumb separata
    };
// Per bucket privato:
    // final signedUrl = await _storage.from(bucket).createSignedUrl(filename, 3600);
    // return { 'rawUrl': signedUrl, 'thumbUrl': signedUrl };
  }
}
