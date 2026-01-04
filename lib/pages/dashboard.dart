import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controller/theme_controller.dart';
import '../form/profile_form.dart';
import '../views/assignments_view.dart';
import '../views/dashboard_home_view.dart';
import '../views/notes_view.dart';
import '../views/tasks_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  final GlobalKey<DashboardHomeViewState> _dashboardKey = GlobalKey();

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 650;
    final bool isTablet = width >= 650 && width < 1100;

    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        final theme = ThemeController.instance;

        if (isMobile) {
          return _buildMobileLayout(theme);
        } else {
          return _buildSidebarLayout(theme, isTablet: isTablet);
        }
      },
    );
  }

  // 📱 MOBILE LAYOUT
  Widget _buildMobileLayout(ThemeController theme) {
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.school_rounded, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text(
              "Student Assistant",
              style: GoogleFonts.poppins(
                color: theme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => theme.toggleTheme(!theme.isDarkMode),
            icon: Icon(
              theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.textColor,
            ),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          _buildBackgroundOrbs(theme),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContentBody(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
          onTap: (index) {
            if (index == 4) {
              _showProfileDialog();
            } else {
              setState(() => _selectedIndex = index);
              if (index == 0) _dashboardKey.currentState?.loadData();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: theme.secondaryText,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt_outlined),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: 'Assign',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // 🖥️ SIDEBAR LAYOUT
  Widget _buildSidebarLayout(ThemeController theme, {required bool isTablet}) {
    final double sidebarWidth = isTablet ? 80 : 260;
    final double contentPadding = isTablet ? 20.0 : 30.0;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _buildBackgroundOrbs(theme),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: sidebarWidth,
                margin: EdgeInsets.all(isTablet ? 10 : 20),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: theme.isDarkMode
                      ? []
                      : [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isTablet
                          ? const Icon(
                              Icons.school_rounded,
                              color: Colors.blueAccent,
                              size: 32,
                              key: ValueKey('icon'),
                            )
                          : Row(
                              key: const ValueKey('full'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.school_rounded,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Student\nAssistant",
                                  style: GoogleFonts.poppins(
                                    color: theme.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: isTablet ? 30 : 40),

                    // 🟢 MENU (Expanded to fill space since footer is gone)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _HoverSidebarItem(
                              0,
                              "Dashboard",
                              Icons.dashboard_rounded,
                              theme,
                              isTablet,
                              _selectedIndex == 0,
                              () => _handleNav(0),
                            ),
                            _HoverSidebarItem(
                              -1,
                              "Profile",
                              Icons.person_outline,
                              theme,
                              isTablet,
                              false,
                              _showProfileDialog,
                            ),
                            _HoverSidebarItem(
                              1,
                              "Tasks",
                              Icons.check_circle_outline,
                              theme,
                              isTablet,
                              _selectedIndex == 1,
                              () => _handleNav(1),
                            ),
                            _HoverSidebarItem(
                              2,
                              "Notes",
                              Icons.note_alt_outlined,
                              theme,
                              isTablet,
                              _selectedIndex == 2,
                              () => _handleNav(2),
                            ),
                            _HoverSidebarItem(
                              3,
                              "Assignments",
                              Icons.assignment_outlined,
                              theme,
                              isTablet,
                              _selectedIndex == 3,
                              () => _handleNav(3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🟢 FOOTER REMOVED (Logout/Theme are now in Content Header)
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    contentPadding,
                    contentPadding,
                    contentPadding,
                  ),
                  child: _buildContentBody(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleNav(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _dashboardKey.currentState?.loadData();
  }

  Widget _buildContentBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        DashboardHomeView(key: _dashboardKey),
        const TasksView(),
        const NotesView(),
        const AssignmentsView(),
      ],
    );
  }

  Widget _buildBackgroundOrbs(ThemeController theme) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _orb(Colors.blueAccent, theme.isDarkMode),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _orb(Colors.purpleAccent, theme.isDarkMode),
        ),
      ],
    );
  }

  Widget _orb(Color color, bool isDark) {
    return Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: isDark ? 0.15 : 0.05),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.4 : 0.35),
                blurRadius: 120,
                spreadRadius: 40,
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(duration: 4.seconds);
  }

  Future<void> _showProfileDialog() async {
    final size = MediaQuery.of(context).size;
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, child) {
          final theme = ThemeController.instance;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              width: size.width > 500 ? 450 : size.width * 0.9,
              constraints: BoxConstraints(maxHeight: size.height * 0.85),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? const Color(0xFF0F172A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.isDarkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: ProfileForm(onClose: () => Navigator.pop(ctx)),
            ),
          );
        },
      ),
    );
    if (mounted) _dashboardKey.currentState?.loadData();
  }
}

class _HoverSidebarItem extends StatefulWidget {
  final int index;
  final String title;
  final IconData icon;
  final ThemeController theme;
  final bool isTablet;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverSidebarItem(
    this.index,
    this.title,
    this.icon,
    this.theme,
    this.isTablet,
    this.isSelected,
    this.onTap,
  );

  @override
  State<_HoverSidebarItem> createState() => _HoverSidebarItemState();
}

class _HoverSidebarItemState extends State<_HoverSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: widget.isTablet ? 4 : 15,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: widget.isTablet ? 8 : 15,
          ),
          decoration: BoxDecoration(
            color: (widget.isSelected || _isHovered)
                ? Colors.blueAccent.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: Colors.blueAccent.withValues(alpha: 0.5))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: widget.isTablet
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                color: (widget.isSelected || _isHovered)
                    ? Colors.blueAccent
                    : widget.theme.secondaryText,
                size: 22,
              ),
              if (!widget.isTablet) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      color: (widget.isSelected || _isHovered)
                          ? widget.theme.textColor
                          : widget.theme.secondaryText,
                      fontWeight: (widget.isSelected || _isHovered)
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
