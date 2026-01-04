import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/auth_input_field.dart';
import '../../services/image_service.dart';
import '../../services/auth_service.dart';
import '../../controller/theme_controller.dart';

class ProfileForm extends StatefulWidget {
  final VoidCallback onClose;

  const ProfileForm({super.key, required this.onClose});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final supabase = Supabase.instance.client;
  final _imageService = ImageService();
  final _authService = AuthService();

  final nameController = TextEditingController();
  final rollNoController = TextEditingController();
  final institutionController = TextEditingController();
  final majorController = TextEditingController();
  final semesterController = TextEditingController();

  bool isLoading = true;
  Uint8List? _imageBytes;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await supabase
            .from('profile')
            .select()
            .eq('id', user.id)
            .single();
        if (mounted) {
          setState(() {
            nameController.text = data['full_name'] ?? '';
            rollNoController.text = data['roll_no'] ?? '';
            institutionController.text = data['institution_name'] ?? '';
            majorController.text = data['major'] ?? '';
            semesterController.text = data['current_semester'] ?? '';
            _avatarUrl = data['profile_image'];
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final bytes = await _imageService.pickFromGallery();
    if (bytes != null) {
      setState(() {
        _imageBytes = bytes;
        _avatarUrl = null;
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _imageBytes = null;
      _avatarUrl = null;
    });
  }

  ImageProvider? _getProfileImage() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if (_avatarUrl != null) return NetworkImage(_avatarUrl!);
    return null;
  }

  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    setState(() => isLoading = true);

    try {
      String? imageUrl = _avatarUrl;
      if (_imageBytes != null) {
        final String path =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.png';
        await supabase.storage
            .from('avatars')
            .uploadBinary(
          path,
          _imageBytes!,
          fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: true,
          ),
        );
        imageUrl = supabase.storage.from('avatars').getPublicUrl(path);
      }

      await supabase
          .from('profile')
          .update({
        'full_name': nameController.text,
        'roll_no': rollNoController.text,
        'institution_name': institutionController.text,
        'major': majorController.text,
        'current_semester': semesterController.text,
        'profile_image': imageUrl,
      })
          .eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated!"),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClose();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final theme = ThemeController.instance;
    final isDark = theme.isDarkMode;
    final passwordController = TextEditingController();

    final String? passwordInput = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Account?",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This action cannot be undone. Please enter your password to confirm.",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.pop(context, passwordController.text),
              child: const Text(
                "Delete Forever",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (passwordInput == null || passwordInput.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user != null && user.email != null) {
        final authResponse = await supabase.auth.signInWithPassword(
          email: user.email!,
          password: passwordInput,
        );

        if (authResponse.user != null) {
          await supabase.from('profile').delete().eq('id', user.id);
          await _authService.signOut();

          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account deleted successfully."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Incorrect password. Account NOT deleted."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        final theme = ThemeController.instance;
        final isDark = theme.isDarkMode;

        final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final inputFill = isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey[100];
        final inputIcon = isDark ? Colors.white54 : Colors.grey[600];
        final inputBorder = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey[300];
        final hintColor = isDark ? Colors.white38 : Colors.grey[500];

        if (isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Profile",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close, color: inputIcon),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey[200],
                      backgroundImage: _getProfileImage(),
                      child: (_imageBytes == null && _avatarUrl == null)
                          ? Icon(Icons.person, size: 50, color: inputIcon)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xFF38BDF8),
                          ),
                          label: const Text(
                            "Edit Image",
                            style: TextStyle(color: Color(0xFF38BDF8)),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: const Color(
                              0xFF38BDF8,
                            ).withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: _deleteImage,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Remove Pic",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                controller: nameController,
                hint: "Full Name",
                icon: Icons.person_outline,
                textColor: textColor,
                fillColor: inputFill,
                iconColor: inputIcon,
                borderColor: inputBorder,
                hintColor: hintColor,
              ),
              const SizedBox(height: 12),
              AuthInputField(
                controller: rollNoController,
                hint: "Roll No",
                icon: Icons.numbers,
                textColor: textColor,
                fillColor: inputFill,
                iconColor: inputIcon,
                borderColor: inputBorder,
                hintColor: hintColor,
              ),
              const SizedBox(height: 12),
              AuthInputField(
                controller: institutionController,
                hint: "Institution",
                icon: Icons.school_outlined,
                textColor: textColor,
                fillColor: inputFill,
                iconColor: inputIcon,
                borderColor: inputBorder,
                hintColor: hintColor,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AuthInputField(
                      controller: majorController,
                      hint: "Major",
                      icon: Icons.book_outlined,
                      textColor: textColor,
                      fillColor: inputFill,
                      iconColor: inputIcon,
                      borderColor: inputBorder,
                      hintColor: hintColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AuthInputField(
                      controller: semesterController,
                      hint: "Semester",
                      icon: Icons.calendar_today_outlined,
                      textColor: textColor,
                      fillColor: inputFill,
                      iconColor: inputIcon,
                      borderColor: inputBorder,
                      hintColor: hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Divider(color: isDark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _deleteAccount,
                  icon: const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    "Delete Account",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.red.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}