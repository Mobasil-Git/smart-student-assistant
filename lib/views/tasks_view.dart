import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../animations/animaton_constants.dart';
import '../components/glass_cards.dart';
import '../controller/theme_controller.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    if (mounted) setState(() => isLoading = true);

    final data = await supabase
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (mounted) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    }
  }

  Future<void> showAddTaskDialog() async {
    final titleController = TextEditingController();
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
                      height: 300,
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
                                "Add New Task",
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
                          Expanded(
                            child: TextField(
                              controller: titleController,
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "What needs to be done?",
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
                                final user = supabase.auth.currentUser;
                                if (user == null ||
                                    titleController.text.trim().isEmpty)
                                  return;
                                final newTask = {
                                  'title': titleController.text.trim(),
                                  'user_id': user.id,
                                  'is_completed': false,
                                  'created_at': DateTime.now()
                                      .toIso8601String(),
                                };
                                Navigator.pop(context);
                                try {
                                  final response = await supabase
                                      .from('tasks')
                                      .insert(newTask)
                                      .select()
                                      .single();
                                  setState(() => tasks.insert(0, response));
                                } catch (e) {
                                  debugPrint("Error adding task: $e");
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to add task: $e"),
                                      ),
                                    );
                                }
                              },
                              child: Text(
                                "Add Task",
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

  Future<void> handleDeleteTask(String taskId, int index) async {
    try {
      setState(() => tasks.removeAt(index));
      await supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delete failed, refreshing...")),
        );
        loadTasks();
      }
    }
  }

  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool newValue,
    required int index,
  }) async {
    try {
      setState(() => tasks[index]['is_completed'] = newValue);
      await supabase
          .from('tasks')
          .update({'is_completed': newValue})
          .eq('id', taskId);
    } catch (e) {
      setState(() => tasks[index]['is_completed'] = !newValue);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Update failed")));
    }
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
                    "My Tasks",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("New Task"),
                    onPressed: () => showAddTaskDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ),
                      )
                    : tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 250,
                              child: Lottie.asset(
                                AppAssets.successConfetti,
                                repeat: false,
                              ),
                            ),
                            Text(
                              "All caught up!",
                              style: GoogleFonts.poppins(
                                color: theme.textColor,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final isCompleted = task['is_completed'] == true;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              opacity: 0.05,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    activeColor: Colors.blueAccent,
                                    checkColor: Colors.white,
                                    side: BorderSide(
                                      color: theme.secondaryText,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    value: isCompleted,
                                    onChanged: (val) {
                                      if (val != null)
                                        toggleTaskCompletion(
                                          taskId: task['id'],
                                          newValue: val,
                                          index: index,
                                        );
                                    },
                                  ),
                                ),
                                title: Text(
                                  task['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? theme.secondaryText
                                        : theme.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () =>
                                      handleDeleteTask(task['id'], index),
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
