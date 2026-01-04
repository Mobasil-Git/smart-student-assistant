import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../components/auth_input_field.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSwitch;

  const SignupForm({super.key, required this.onSwitch});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final nameController = TextEditingController();
  final rollNoController = TextEditingController();
  final institutionController = TextEditingController();
  final majorController = TextEditingController();
  final semesterController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final authService = AuthService();
  final FocusNode _emailFocus = FocusNode();

  String? _emailErrorText;
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    rollNoController.dispose();
    institutionController.dispose();
    majorController.dispose();
    semesterController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = emailController.text.trim().toLowerCase();
    String? errorMessage;

    if (email.isEmpty) {
      errorMessage = null;
    } else if (email.endsWith('@gmail.com')) {
      final gmailRegex = RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$");
      if (!gmailRegex.hasMatch(email)) {
        errorMessage = "Invalid characters in email";
      } else {
        errorMessage = null;
      }
    } else {
      if (email.contains('@gnail') ||
          email.contains('@gmil') ||
          email.contains('@gmal')) {
        errorMessage = "Did you mean @gmail.com?";
      } else if (email.endsWith('.con')) {
        errorMessage = "Did you mean .com?";
      } else if (email.endsWith('@gmail')) {
        errorMessage = "Missing .com";
      } else if (email.contains('@')) {
        errorMessage = "Only @gmail.com allowed";
      } else {
        errorMessage = "Invalid email format";
      }
    }

    setState(() {
      _isEmailValid = errorMessage == null;
      _emailErrorText = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 RESPONSIVE SIZING
    final isMobile = MediaQuery.of(context).size.width < 600;
    final double headerSize = isMobile ? 26 : 32;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Account",
            style: GoogleFonts.playfairDisplay(
              fontSize: headerSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Join the student network today.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          AuthInputField(
            controller: nameController,
            hint: "Full Name",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AuthInputField(
            controller: rollNoController,
            hint: "Roll No",
            icon: Icons.numbers,
          ),
          const SizedBox(height: 12),
          AuthInputField(
            controller: institutionController,
            hint: "Institution / University",
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AuthInputField(
                  controller: majorController,
                  hint: "Major",
                  icon: Icons.book_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AuthInputField(
                  controller: semesterController,
                  hint: "Semester",
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          AuthInputField(
            controller: emailController,
            focusNode: _emailFocus,
            hint: "Email Address",
            icon: Icons.email_outlined,
            borderColor: _isEmailValid ? null : Colors.redAccent,
            iconColor: _isEmailValid ? null : Colors.redAccent,
            textColor: _isEmailValid ? null : Colors.redAccent,
          ),

          if (!_isEmailValid && _emailErrorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                _emailErrorText!,
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 12),
          AuthInputField(
            controller: passwordController,
            hint: "Password",
            icon: Icons.lock_outline,
            obscure: true,
          ),
          const SizedBox(height: 12),
          AuthInputField(
            controller: confirmController,
            hint: "Confirm Password",
            icon: Icons.lock_outline,
            obscure: true,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                _validateEmail();
                if (!_isEmailValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fix email errors"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all fields"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (passwordController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Passwords do not match"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  await authService.signUp(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                    fullName: nameController.text.trim(),
                    rollNo: rollNoController.text.trim(),
                    institution: institutionController.text.trim(),
                    major: majorController.text.trim(),
                    semester: semesterController.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Account created! Please login."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    widget.onSwitch();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Signup Failed: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: widget.onSwitch,
              child: RichText(
                text: const TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.white54),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
