import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../components/auth_input_field.dart';

// 🟢 FIX 1: Changed to StatefulWidget
class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.onSwitch,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // 🟢 FIX 2: Controllers are defined HERE, so they survive screen rebuilds
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when the form is removed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
            "Welcome Back",
            style: GoogleFonts.playfairDisplay(fontSize: headerSize, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Login to continue your progress.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 32),

          AuthInputField(controller: emailController, hint: "Email Address", icon: Icons.email_outlined),
          const SizedBox(height: 16),
          AuthInputField(controller: passwordController, hint: "Password", icon: Icons.lock_outline, obscure: true),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13)),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService().signIn(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: widget.onSwitch,
              child: RichText(
                text: const TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.white54),
                  children: [
                    TextSpan(text: "Sign up", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
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