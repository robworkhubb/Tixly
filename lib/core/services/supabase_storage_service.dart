import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final _storage = Supabase.instance.client.storage;

  Future<Map<String, String>> uploadFile({
    required File file,
    required String bucket,
    required bool isPdf,
  }) async {
    final ext = isPdf ? 'pdf' : file.path.split('.').last;
    final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';

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
