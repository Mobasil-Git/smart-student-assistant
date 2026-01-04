import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../animations/animaton_constants.dart';
import '../components/glass_cards.dart';
import '../controller/theme_controller.dart';
import '../services/assignment_services.dart';

class AssignmentsView extends StatefulWidget {
  const AssignmentsView({super.key});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  final AssignmentsService _service = AssignmentsService();
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await _service.getAssignments();
      if (mounted) {
        setState(() {
          _assignments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> addAssignmentDialog() async {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                          height: 500,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Add Assignment",
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
                                controller: subjectController,
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Subject / Title",
                                  hintStyle: TextStyle(
                                    color: theme.secondaryText,
                                  ),
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
                              const SizedBox(height: 15),
                              Expanded(
                                child: TextField(
                                  controller: descriptionController,
                                  style: TextStyle(color: theme.textColor),
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText: "Description (Optional)...",
                                    hintStyle: TextStyle(
                                      color: theme.secondaryText,
                                    ),
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
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Due: ${selectedDate.toString().split(' ')[0]}",
                                      style: TextStyle(color: theme.textColor),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.calendar_month,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2030),
                                          builder: (ctx, child) => Theme(
                                            data: theme.isDarkMode
                                                ? ThemeData.dark()
                                                : ThemeData.light(),
                                            child: child!,
                                          ),
                                        );
                                        if (picked != null) {
                                          setStateDialog(
                                            () => selectedDate = picked,
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
                                  ),
                                  onPressed: () async {
                                    if (subjectController.text.trim().isEmpty) {
                                      return;
                                    }
                                    Navigator.pop(context);
                                    final newAssignment = await _service
                                        .addAssignment(
                                          subjectController.text.trim(),
                                          selectedDate,
                                          description: descriptionController
                                              .text
                                              .trim(),
                                        );
                                    if (newAssignment != null && mounted) {
                                      setState(
                                        () => _assignments.add(newAssignment),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Add Assignment",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
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
      },
    );
  }

  Future<void> toggleSubmitted(String id, bool currentVal, int index) async {
    setState(() => _assignments[index]['is_submitted'] = !currentVal);
    await _service.toggleComplete(id, currentVal);
  }

  Future<void> deleteAssignment(String id, int index) async {
    setState(() => _assignments.removeAt(index));
    await _service.deleteAssignment(id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        final theme = ThemeController.instance;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Assignments",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: addAssignmentDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("New"),
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
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ),
                      )
                    : _assignments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              child: Lottie.asset(AppAssets.emptyState),
                            ),
                            Text(
                              "No assignments pending.",
                              style: GoogleFonts.poppins(
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn()
                    : ListView.builder(
                        itemCount: _assignments.length,
                        itemBuilder: (_, index) {
                          final item = _assignments[index];
                          final isSubmitted = item['is_submitted'] == true;
                          final description = item['description'] as String?;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              opacity: 0.08,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                            activeColor: Colors.blueAccent,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide(
                                              color: theme.secondaryText,
                                              width: 1.5,
                                            ),
                                            value: isSubmitted,
                                            onChanged: (val) => toggleSubmitted(
                                              item['id'],
                                              isSubmitted,
                                              index,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['subject'] ?? "No Subject",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  decoration: isSubmitted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                  color: isSubmitted
                                                      ? theme.secondaryText
                                                      : theme.textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.blueAccent,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    "Due: ${item['due_date'].toString().split(' ')[0]}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.blueAccent,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => deleteAssignment(
                                            item['id'],
                                            index,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (description != null && description.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(
                                        height: 1,
                                        color: Colors.white10,
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: theme.secondaryText,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn().slideX();
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
