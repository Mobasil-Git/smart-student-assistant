import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentsService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAssignments() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('assignments')
        .select()
        .eq('user_id', user.id)
        .order('due_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> addAssignment(
    String subject,
    DateTime date, {
    String? description,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('assignments')
          .insert({
            'user_id': user.id,
            'subject': subject,
            'due_date': date.toIso8601String(),
            'description': description,
            'is_submitted': false,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      debugPrint("Error adding assignment: $e");
      return null;
    }
  }

  Future<void> toggleComplete(String id, bool currentValue) async {
    await _client
        .from('assignments')
        .update({'is_submitted': !currentValue})
        .eq('id', id);
  }

  Future<void> deleteAssignment(String id) async {
    await _client.from('assignments').delete().eq('id', id);
  }
}
