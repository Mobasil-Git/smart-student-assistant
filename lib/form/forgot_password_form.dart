import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../components/auth_input_field.dart';

enum ResetStep { email, code, newPassword }

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordForm({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final authService = AuthService();

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  ResetStep _currentStep = ResetStep.email;
  bool isLoading = false;

  Future<void> _sendCode() async {
    if (emailController.text.trim().isEmpty) {
      _showMessage("Please enter your email", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      await authService.sendPasswordResetEmail(emailController.text.trim());
      if (mounted) {
        _showMessage("Code sent! Check your email.", Colors.green);
        setState(() => _currentStep = ResetStep.code);
      }
    } catch (e) {
      if (mounted) _showMessage("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (codeController.text.trim().isEmpty) {
      _showMessage("Please enter the code", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      await authService.verifyRecoveryCode(
        emailController.text.trim(),
        codeController.text.trim(),
      );
      if (mounted) {
        _showMessage("Code verified!", Colors.green);
        setState(() => _currentStep = ResetStep.newPassword);
      }
    } catch (e) {
      if (mounted) _showMessage("Invalid code. Try again.", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (newPassController.text.isEmpty || confirmPassController.text.isEmpty) {
      _showMessage("Please fill all fields", Colors.orange);
      return;
    }
    if (newPassController.text != confirmPassController.text) {
      _showMessage("Passwords do not match", Colors.red);
      return;
    }

    setState(() => isLoading = true);
    try {
      await authService.updatePassword(newPassController.text.trim());
      await authService.signOut();

      if (mounted) {
        _showMessage("Password updated! Please login.", Colors.green);
        widget.onBackToLogin();
      }
    } catch (e) {
      if (mounted) _showMessage("Update failed: $e", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 RESPONSIVE FONT SIZE
    final isMobile = MediaQuery.of(context).size.width < 600;
    final double headerSize = isMobile ? 24 : 28;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getHeaderText(),
            style: GoogleFonts.playfairDisplay(fontSize: headerSize, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _getSubHeaderText(),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 32),

          if (_currentStep == ResetStep.email)
            AuthInputField(controller: emailController, hint: "Email Address", icon: Icons.email_outlined),

          if (_currentStep == ResetStep.code)
            AuthInputField(controller: codeController, hint: "Enter 8-digit Code", icon: Icons.security),

          if (_currentStep == ResetStep.newPassword) ...[
            AuthInputField(controller: newPassController, hint: "New Password", icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 16),
            AuthInputField(controller: confirmPassController, hint: "Confirm Password", icon: Icons.lock_outline, obscure: true),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleButtonPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)))
                  : Text(_getButtonText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: widget.onBackToLogin,
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress() {
    switch (_currentStep) {
      case ResetStep.email: _sendCode(); break;
      case ResetStep.code: _verifyCode(); break;
      case ResetStep.newPassword: _updatePassword(); break;
    }
  }

  String _getHeaderText() {
    switch (_currentStep) {
      case ResetStep.email: return "Reset Password";
      case ResetStep.code: return "Verify Code";
      case ResetStep.newPassword: return "Set Password";
    }
  }

  String _getSubHeaderText() {
    switch (_currentStep) {
      case ResetStep.email: return "Enter email to receive code.";
      case ResetStep.code: return "Enter the code sent to your email.";
      case ResetStep.newPassword: return "Create your new secure password.";
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case ResetStep.email: return "Send Code";
      case ResetStep.code: return "Verify Code";
      case ResetStep.newPassword: return "Update Password";
    }
  }
}