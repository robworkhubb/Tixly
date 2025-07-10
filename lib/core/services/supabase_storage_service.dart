import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final _client = Supabase.instance.client;
  final _storage = Supabase.instance.client.storage;

  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    final bucket = 'avatars';

    // Estrai l’estensione originale
    final ext = file.path
        .split('.')
        .last;

    // Includi l’estensione nel nome
    final path = '$userId/avatar_${DateTime
        .now()
        .millisecondsSinceEpoch}.$ext';

    // 1️⃣ Upload
    final res = await _client.storage
        .from(bucket)
        .upload(path, file,
        fileOptions: FileOptions(cacheControl: '3600', upsert: true)
    );


    // 2️⃣ Genera la public URL con lo stesso path
    final publicUrl = _client.storage
        .from(bucket)
        .getPublicUrl(path);

    if (publicUrl == null) {
      throw Exception('Non ho potuto recuperare la publicUrl');
    }

    return publicUrl;
  }

  Future<Map<String, String>> uploadFile({
    required File file,
    required String bucket,
    required bool isPdf,
  }) async {
    final ext = isPdf ? 'pdf' : file.path
        .split('.')
        .last;
    final filename = '${DateTime
        .now()
        .millisecondsSinceEpoch}.$ext';

    final res = await _storage.from(bucket).upload(filename, file);
    if (res.isEmpty) throw Exception("❌ Errore upload su Supabase");

    // Se bucket è pubblico
    final rawUrl = _storage.from(bucket).getPublicUrl(filename);
    final thumbUrl = isPdf ? rawUrl : rawUrl; // puoi differenziare in futuro

    return {
      'rawUrl': rawUrl,
      'thumbUrl': thumbUrl,
    };

    // Per bucket privato:
    // final signedUrl = await _storage.from(bucket).createSignedUrl(filename, 3600);
    // return { 'rawUrl': signedUrl, 'thumbUrl': signedUrl };
  }
}
