import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Adjust these imports to match your folder structure exactly
import '../form/forgot_password_form.dart';
import '../form/login_form.dart';
import '../form/signup_form.dart';

enum AuthMode { login, signup, forgotPassword }

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _showAuthOverlay = false;
  AuthMode _authMode = AuthMode.login;

  void _toggleAuthOverlay() {
    setState(() {
      _showAuthOverlay = !_showAuthOverlay;
      if (_showAuthOverlay) {
        _authMode = AuthMode.login;
      }
    });
  }

  Widget _buildAuthForm() {
    switch (_authMode) {
      case AuthMode.login:
        return LoginForm(
          onSwitch: () => setState(() => _authMode = AuthMode.signup),
          onForgotPassword: () =>
              setState(() => _authMode = AuthMode.forgotPassword),
        );
      case AuthMode.signup:
        return SignupForm(
          onSwitch: () => setState(() => _authMode = AuthMode.login),
        );
      case AuthMode.forgotPassword:
        return ForgotPasswordForm(
          onBackToLogin: () => setState(() => _authMode = AuthMode.login),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ----------------------------------------------------------
          // LAYER 1: ANIMATED BACKGROUND ORBS (Added More & Faster)
          // ----------------------------------------------------------
          Positioned(
            top: -100,
            left: -100,
            child: _GlowOrb(
              color: const Color(0xFF2563EB),
              size: 500,
              delay: 0.ms,
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: _GlowOrb(
              color: const Color(0xFF7C3AED),
              size: 600,
              delay: 1000.ms,
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            right: -200,
            child: _GlowOrb(
              color: const Color(0xFF06B6D4),
              size: 400,
              delay: 2000.ms,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: _GlowOrb(
              color: const Color(0xFFDB2777),
              size: 350,
              delay: 500.ms,
            ),
          ),
          // --- EXTRA ORBS FOR DENSITY ---
          Positioned(
            top: size.height * 0.1,
            left: size.width * 0.4,
            child: _GlowOrb(
              color: const Color(0xFF10B981), // Emerald
              size: 300,
              delay: 300.ms,
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            left: size.width * 0.6,
            child: _GlowOrb(
              color: const Color(0xFFF59E0B), // Amber
              size: 450,
              delay: 1500.ms,
            ),
          ),
          Positioned(
            top: size.height * 0.6,
            left: -50,
            child: _GlowOrb(
              color: const Color(0xFF6366F1), // Indigo
              size: 400,
              delay: 800.ms,
            ),
          ),
          Positioned(
            top: -80,
            right: size.width * 0.3,
            child: _GlowOrb(
              color: const Color(0xFFEC4899), // Pink
              size: 380,
              delay: 1200.ms,
            ),
          ),

          // ----------------------------------------------------------
          // LAYER 2: SHAPES
          // ----------------------------------------------------------
          Positioned(
            top: 100,
            right: 80,
            child: _OutlineShape(
              size: 100,
              // 🟢 UPDATED: withValues
              color: Colors.white.withValues(alpha: 0.05),
              rotation: 0.5,
            ),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: _OutlineShape(
              size: 200,
              // 🟢 UPDATED: withValues
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
          ),

          // ----------------------------------------------------------
          // LAYER 3: MAIN SCROLLABLE CONTENT
          // ----------------------------------------------------------
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: size.height - 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // --- HEADER ---
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 30,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      // 🟢 UPDATED: withValues
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        // 🟢 UPDATED: withValues
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  if (!isMobile) ...[
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Smart Student",
                                          style: GoogleFonts.playfairDisplay(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0,
                                          ),
                                        ),
                                        Text(
                                          "Assistant",
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF38BDF8),
                                            fontSize: 14,
                                            letterSpacing: 2.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => showHelpCenterDialog(context),
                                icon: Icon(
                                  Icons.help_outline_rounded,
                                  // 🟢 UPDATED: withValues
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                                label: Text(
                                  "Support",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  // 🟢 UPDATED: withValues
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.05,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- HERO SECTION ---
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  // 🟢 UPDATED: withValues
                                  color: const Color(
                                    0xFF38BDF8,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    // 🟢 UPDATED: withValues
                                    color: const Color(
                                      0xFF38BDF8,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  "STREAMLINED ACADEMIC WORKSPACE",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Text(
                                "Architect Your\nAcademic Success",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: isMobile ? 42 : 84,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      // 🟢 UPDATED: withValues
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: size.width > 800
                                    ? 600
                                    : size.width * 0.9,
                                child: Text(
                                  "A unified command center for your studies. Master your schedule with precision tools designed for high achievers.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    // 🟢 UPDATED: withValues
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: isMobile ? 15 : 18,
                                    height: 1.6,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),

                              ElevatedButton(
                                onPressed: _toggleAuthOverlay,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF020617),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 24,
                                  ),
                                  elevation: 20,
                                  shadowColor: const Color(
                                    0xFF38BDF8,
                                  ).withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Get Started Free",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- FOOTER STATS ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              const _StatItem(label: "4.8/5", sub: "Rating"),
                              if (!isMobile)
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                              const _StatItem(label: "10k+", sub: "Students"),
                              if (!isMobile)
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                              const _StatItem(label: "Free", sub: "Forever"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // LAYER 4: AUTH OVERLAY
          // ----------------------------------------------------------
          if (_showAuthOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleAuthOverlay,
                child: Container(
                  // 🟢 UPDATED: withValues
                  color: Colors.black.withValues(alpha: 0.6),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        child: GestureDetector(
                          onTap: () {},
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                width: size.width > 550
                                    ? 450
                                    : size.width * 0.9,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  // 🟢 UPDATED: withValues
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    // 🟢 UPDATED: withValues
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      // 🟢 UPDATED: withValues
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 50,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: AnimatedSize(
                                  duration: 300.ms,
                                  curve: Curves.easeInOut,
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: _toggleAuthOverlay,
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                      _buildAuthForm(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER WIDGETS
// ---------------------------------------------------------------------------

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final Duration delay;

  const _GlowOrb({
    required this.color,
    required this.size,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            // 🟢 UPDATED: withValues
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7],
        ),
      ),
    )
        .animate(delay: delay, onPlay: (c) => c.repeat(reverse: true))
    // FASTER SPEED SETTINGS
        .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.2, 1.2),
      duration: 2.5.seconds, // Faster breathing
      curve: Curves.easeInOut,
    )
        .move(
      begin: const Offset(0, 0),
      end: const Offset(50, -50), // Increased range
      duration: 3.5.seconds, // Faster movement
      curve: Curves.easeInOut,
    );
  }
}

class _OutlineShape extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;
  final BoxShape shape;

  const _OutlineShape({
    required this.size,
    required this.color,
    this.rotation = 0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          border: Border.all(color: color, width: 1.5),
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(20)
              : null,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String sub;

  const _StatItem({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          sub,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

void showHelpCenterDialog(BuildContext context) {
  final size = MediaQuery.of(context).size;
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: size.width > 600 ? 600 : size.width * 0.9,
          height: 500,
          decoration: BoxDecoration(
            // 🟢 UPDATED: withValues
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              // 🟢 UPDATED: withValues
              color: Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                // 🟢 UPDATED: withValues
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Help Center",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        // 🟢 UPDATED: withValues
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: TabBar(
                    indicatorColor: const Color(0xFF38BDF8),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: "FAQ"),
                      Tab(text: "Contact Support"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        padding: const EdgeInsets.all(24),
                        children: const [
                          _FaqTile(
                            question: "Is it free?",
                            answer: "Yes! Core features are free.",
                          ),
                          _FaqTile(
                            question: "Is data secure?",
                            answer: "Yes. Encrypted via Supabase.",
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Expanded(
                              child: _DarkTextField(
                                label: "Message",
                                maxLines: 5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38BDF8),
                                  foregroundColor: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Send Message",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      // 🟢 UPDATED: withValues
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ExpansionTile(
      title: Text(question, style: GoogleFonts.poppins(color: Colors.white)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
      ],
    ),
  );
}

class _DarkTextField extends StatelessWidget {
  final String label;
  final int maxLines;

  const _DarkTextField({required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      filled: true,
      // 🟢 UPDATED: withValues
      fillColor: Colors.black.withValues(alpha: 0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}