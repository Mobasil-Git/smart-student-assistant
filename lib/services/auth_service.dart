import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String rollNo,
    required String institution,
    required String major,
    required String semester,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception("Signup failed: No user returned");
    }

    await _client.from('profile').insert({
      'id': user.id,
      'full_name': fullName,
      'email': email,
      'roll_no': rollNo,
      'institution_name': institution,
      'major': major,
      'current_semester': semester,
      'profile_image': null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // 2. Verify the Code entered by the user
  Future<AuthResponse> verifyRecoveryCode(String email, String code) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.recovery,
    );
  }

  // 3. Update the Password (after code is verified)
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  User? get currentUser => _client.auth.currentUser;
}