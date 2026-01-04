import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ssap/pages/dashboard.dart';
import 'pages/landing_page.dart';
import 'controller/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await Supabase.initialize(
    url: "https://jqnmznrhkztwmwyulrmg.supabase.co",
    anonKey: "sb_publishable_Su-Yr-f38TvvgkuL186izA_-gNQheH1",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp(
          title: "Smart Student Assistant",
          debugShowCheckedModeBanner: false,
          theme: ThemeController.instance.isDarkMode
              ? ThemeData.dark()
              : ThemeData.light(),
          initialRoute: session != null ? '/dashboard' : '/',
          routes: {
            '/': (_) => const LandingPage(),
            '/dashboard': (_) => const DashboardPage(),
          },
        );
      },
    );
  }
}