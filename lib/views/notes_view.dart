import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import '../animations/animaton_constants.dart';
import '../controller/theme_controller.dart';
import '../components/glass_cards.dart';
import '../services/notes_services.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final _notesService = NotesService();

  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final data = await _notesService.getNotes();
      if (mounted) {
        setState(() {
          notes = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleDelete(String id) async {
    await _notesService.deleteNote(id);
    _loadNotes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note deleted"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _handleEdit(Map<String, dynamic> note) async {
    final titleController = TextEditingController(text: note['title']);
    final contentController = TextEditingController(text: note['content']);
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return AnimatedBuilder(
          animation: ThemeController.instance,
          builder: (context, child) {
            final theme = ThemeController.instance;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: size.width > 550 ? 500 : size.width * 0.9,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Edit Note",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: titleController,
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "Title",
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contentController,
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 14,
                            ),
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: "Start typing...",
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                if (titleController.text.isNotEmpty) {
                                  await _notesService.updateNote(
                                    note['id'],
                                    titleController.text,
                                    contentController.text,
                                  );
                                  if (mounted) Navigator.pop(context);
                                  _loadNotes();
                                }
                              },
                              child: Text(
                                "Update Note",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAddTextNote() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return AnimatedBuilder(
          animation: ThemeController.instance,
          builder: (context, child) {
            final theme = ThemeController.instance;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: size.width > 550 ? 500 : size.width * 0.9,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add Text Note",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: titleController,
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "Title",
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contentController,
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 14,
                            ),
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: "Write something...",
                              hintStyle: TextStyle(color: theme.secondaryText),
                              filled: true,
                              fillColor: theme.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                if (titleController.text.isNotEmpty) {
                                  await _notesService.addNote(
                                    titleController.text,
                                    contentController.text,
                                  );
                                  if (mounted) Navigator.pop(context);
                                  _loadNotes();
                                }
                              },
                              child: Text(
                                "Save Note",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPdf(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open PDF"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        final theme = ThemeController.instance;

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Notes",
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _handleAddTextNote,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add Note"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : notes.isEmpty
                        ? Center(
                      child: Column( // 🟢 LOTTIE EMPTY STATE ADDED HERE
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            child: Lottie.asset(AppAssets.emptyState),
                          ),
                          Text(
                            "No notes yet.",
                            style: GoogleFonts.poppins(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                        : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      gridDelegate: isMobile
                          ? const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.75,
                      )
                          : const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        final bool isPdf = note['is_pdf'] == true;

                        return GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            isPdf
                                                ? Icons.picture_as_pdf
                                                : Icons.description,
                                            color: isPdf
                                                ? Colors.redAccent
                                                : Colors.blueAccent,
                                            size: 24,
                                          ),
                                          if (isPdf) ...[
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Container(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .redAccent
                                                      .withValues(
                                                      alpha:
                                                      0.15),
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      6),
                                                ),
                                                child: const Text(
                                                  "PDF",
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors
                                                        .redAccent,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                  ),
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isPdf)
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: theme
                                                  .secondaryText,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints:
                                            const BoxConstraints(),
                                            onPressed: () =>
                                                _handleEdit(note),
                                          ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Colors.redAccent,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints:
                                          const BoxConstraints(),
                                          onPressed: () =>
                                              _handleDelete(
                                                  note['id']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  note['title'] ?? "Untitled",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Expanded(
                                  child: isPdf
                                      ? Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        note['file_size'] ??
                                            "File",
                                        style: TextStyle(
                                          color: theme
                                              .secondaryText,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 10),
                                      Center(
                                        child: SizedBox(
                                          height: 32,
                                          child: ElevatedButton
                                              .icon(
                                            onPressed: () =>
                                                _openPdf(
                                                    note[
                                                    'file_url']),
                                            icon: const Icon(
                                              Icons
                                                  .download_rounded,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              "Open",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor: theme
                                                  .isDarkMode
                                                  ? Colors.white
                                                  .withValues(
                                                  alpha:
                                                  0.1)
                                                  : Colors
                                                  .blueAccent
                                                  .withValues(
                                                  alpha:
                                                  0.05),
                                              foregroundColor: theme
                                                  .isDarkMode
                                                  ? Colors.white
                                                  : Colors
                                                  .blueAccent,
                                              elevation: 0,
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                horizontal: 12,
                                              ),
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    8),
                                                side:
                                                BorderSide(
                                                  color: theme
                                                      .isDarkMode
                                                      ? Colors
                                                      .transparent
                                                      : Colors
                                                      .blueAccent
                                                      .withValues(
                                                      alpha: 0.2),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      : Text(
                                    note['content'] ?? "",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: theme
                                          .secondaryText,
                                    ),
                                    maxLines: 6,
                                    overflow: TextOverflow
                                        .ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  note['created_at']
                                      .toString()
                                      .split(
                                    'T',
                                  )[0],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.secondaryText
                                        .withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade().scale(
                          duration: 300.ms,
                          delay: (index * 50).ms,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}