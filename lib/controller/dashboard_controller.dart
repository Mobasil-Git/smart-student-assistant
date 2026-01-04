import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../../services/profile_services.dart';
import '../../services/image_service.dart';

class DashboardController extends ChangeNotifier {
  final _profileService = ProfileService();
  final _imageService = ImageService();
  final _user = Supabase.instance.client.auth.currentUser;

  String fullName = "User";
  String? avatarUrl;
  bool loading = true;

  Future<void> loadProfile() async {
    if (_user == null) return;

    final profile = await _profileService.fetchProfile(_user.id);
    if (profile != null) {
      fullName = profile['full_name'] ?? "User";
      avatarUrl = profile['profile_image'];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> changeAvatar() async {
    if (_user == null) return;
    final Uint8List? imageBytes = await _imageService.pickFromGallery();

    if (imageBytes == null) return;

    final String userId = _user.id;
    const String fileExt = 'jpg';

    final url = await _profileService.uploadAvatar(userId, imageBytes, fileExt);

    if (url == null) return;

    await _profileService.saveAvatarUrl(userId, url);
    avatarUrl = url;
    notifyListeners();
  }
}