import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getNotes() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('notes')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addNote(String title, String content) async {
    final user = _client.auth.currentUser!;
    await _client.from('notes').insert({
      'user_id': user.id,
      'title': title,
      'content': content,
    });
  }

  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }

  Future<void> updateNote(String id, String title, String content) async {
    await _client.from('notes').update({
      'title': title,
      'content': content,
    }).eq('id', id);
  }
}