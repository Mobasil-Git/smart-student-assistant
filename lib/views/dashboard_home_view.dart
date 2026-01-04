import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import '../animations/animaton_constants.dart';
import '../components/glass_cards.dart';
import '../controller/theme_controller.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => DashboardHomeViewState();
}

class DashboardHomeViewState extends State<DashboardHomeView> {
  final supabase = Supabase.instance.client;

  String fullName = "Student";
  String? avatarUrl;
  int taskCount = 0;
  int assignmentCount = 0;
  int noteCount = 0;
  double totalStudyHours = 0;
  List<double> weeklyChartData = List.filled(7, 0);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final tasks = await supabase
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .eq('is_completed', false);
      final assignments = await supabase
          .from('assignments')
          .select()
          .eq('user_id', user.id)
          .eq('is_submitted', false);
      final notes = await supabase
          .from('notes')
          .select()
          .eq('user_id', user.id);
      final profile = await supabase
          .from('profile')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        fullName = profile['full_name'] ?? "Student";
        avatarUrl = profile['profile_image'];
      }

      final sessions = await supabase
          .from('study_sessions')
          .select()
          .eq('user_id', user.id);

      double tempTotal = 0;
      List<double> tempWeekly = List.filled(7, 0);

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      for (var session in sessions) {
        final hours = (session['study_hours'] as num).toDouble();
        final rawDate = DateTime.parse(session['session_date']);
        final sessionDate = DateTime(rawDate.year, rawDate.month, rawDate.day);
        final diff = sessionDate.difference(startOfWeekDate).inDays;

        if (diff >= 0 && diff < 7) {
          tempTotal += hours;

          int index = sessionDate.weekday - 1;
          if (index >= 0 && index < 7) {
            tempWeekly[index] += hours;
          }
        }
      }
      if (mounted) {
        setState(() {
          taskCount = tasks.length;
          assignmentCount = assignments.length;
          noteCount = notes.length;
          totalStudyHours = tempTotal;
          weeklyChartData = tempWeekly;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard Refresh Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> addStudySession() async {
    final theme = ThemeController.instance;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final size = MediaQuery.of(context).size;

    double? hours;
    DateTime selectedDate = DateTime.now();

    String? errorText;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: theme.dialogBackground,
              insetPadding: const EdgeInsets.all(20),
              content: SizedBox(
                width: size.width > 400 ? 300 : size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Log Study Session",
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(color: theme.textColor),
                      decoration: InputDecoration(
                        labelText: "Hours",
                        labelStyle: TextStyle(color: theme.secondaryText),
                        errorText: errorText,
                        errorStyle: const TextStyle(color: Colors.redAccent),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.secondaryText),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          final parsed = double.tryParse(val);
                          if (parsed == null) {
                            hours = null;
                            if (val.isNotEmpty) {
                              errorText = "Invalid number";
                            } else
                              errorText = null;
                          } else if (parsed > 24) {
                            hours = null;
                            errorText = "Cannot exceed 24 hours";
                          } else if (parsed < 0) {
                            hours = null;
                            errorText = "Cannot be negative";
                          } else {
                            hours = parsed;
                            errorText = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: theme.isDarkMode
                                ? ThemeData.dark()
                                : ThemeData.light(),
                            child: child!,
                          ),
                        );
                        if (picked != null)
                          setStateDialog(() => selectedDate = picked);
                      },
                      child: Text(
                        selectedDate.toString().split(' ')[0],
                        style: TextStyle(color: theme.textColor),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: theme.secondaryText),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (hours != null && errorText == null) {
                      await supabase.from('study_sessions').insert({
                        'user_id': user.id,
                        'study_hours': hours,
                        'session_date': selectedDate.toIso8601String(),
                      });
                      if (mounted) {
                        Navigator.pop(context);
                        loadData();
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 800;

    final double nameFontSize = isMobile ? 22 : 34;
    final double headerSpacing = isMobile ? 25 : 40;
    final double chartHeight = isMobile ? 220 : 300;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addStudySession,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.access_time_filled),
        label: const Text("Log Study"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: isMobile ? 80 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMobile) ...[
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    (avatarUrl != null && avatarUrl!.isNotEmpty)
                                    ? NetworkImage(avatarUrl!)
                                    : null,
                                child: (avatarUrl == null || avatarUrl!.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 20),
                            ],

                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome back,",
                                    style: GoogleFonts.poppins(
                                      color: theme.secondaryText,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: nameFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isMobile)
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              (avatarUrl != null && avatarUrl!.isNotEmpty)
                              ? NetworkImage(avatarUrl!)
                              : null,
                          child: (avatarUrl == null || avatarUrl!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  theme.toggleTheme(!theme.isDarkMode),
                              icon: Icon(
                                theme.isDarkMode
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: theme.textColor,
                              ),
                              tooltip: "Toggle Theme",
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: _handleLogout,
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.redAccent,
                              ),
                              tooltip: "Logout",
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: headerSpacing),

                  _buildResponsiveStatsGrid(isMobile, width),

                  const SizedBox(height: 30),

                  GlassCard(
                    opacity: 0.05,
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 15 : 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Weekly Activity",
                                style: GoogleFonts.poppins(
                                  color: theme.textColor,
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (theme.isDarkMode && !isMobile)
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Lottie.asset(AppAssets.graphGrowth),
                                ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 15 : 20),
                          SizedBox(
                            height: chartHeight,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: theme.secondaryText.withValues(
                                      alpha: 0.2,
                                    ),
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        const days = [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun',
                                        ];
                                        int idx = value.toInt();
                                        if (idx >= 0 && idx < 7) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              days[idx],
                                              style: TextStyle(
                                                color: theme.secondaryText,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY:
                                    (weeklyChartData.reduce(
                                      (a, b) => a > b ? a : b,
                                    )) +
                                    2,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weeklyChartData
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) =>
                                              FlSpot(e.key.toDouble(), e.value),
                                        )
                                        .toList(),
                                    isCurved: true,
                                    color: Colors.blueAccent,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blueAccent.withValues(
                                            alpha: 0.3,
                                          ),
                                          Colors.blueAccent.withValues(
                                            alpha: 0.0,
                                          ),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResponsiveStatsGrid(bool isMobile, double width) {
    final bool isTablet = width >= 650 && width < 1100;

    final List<Widget> statCards = [
      _buildStatGlass(
        "Tasks",
        "$taskCount",
        Icons.task_alt,
        Colors.orange,
        isMobile,
      ),
      _buildStatGlass(
        "Assignments",
        "$assignmentCount",
        Icons.assignment,
        Colors.blue,
        isMobile,
      ),
      _buildStatGlass(
        "Notes",
        "$noteCount",
        Icons.note,
        Colors.purple,
        isMobile,
      ),
      _buildStatGlass(
        "Study Hrs",
        totalStudyHours.toStringAsFixed(1),
        Icons.timer,
        Colors.green,
        isMobile,
      ),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
        children: statCards,
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 60,
          runSpacing: 20,
          alignment: WrapAlignment.start,
          children: statCards.map((card) {
            return SizedBox(width: isTablet ? 160 : 180, child: card);
          }).toList(),
        ),
      );
    }
  }

  Widget _buildStatGlass(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    final theme = ThemeController.instance;
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 15),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
