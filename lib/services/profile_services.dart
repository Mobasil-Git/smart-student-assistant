import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return await _client
        .from('profile')
        .select('full_name, profile_image')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<String?> uploadAvatar(
    String userId,
    Uint8List imageBytes,
    String fileExt,
  ) async {
    final path = '$userId/avatar.$fileExt';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          imageBytes,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
        );

    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> saveAvatarUrl(String userId, String url) async {
    await _client
        .from('profile')
        .update({'profile_image': url})
        .eq('id', userId);
  }
}
