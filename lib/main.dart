import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// === TAMBAHAN: import Supabase ===
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/views/auth_page.dart';
import 'shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: ganti dengan URL & anon key punyamu sendiri
  const supabaseUrl = 'https://frlcdjedwexsipxhikfn.supabase.co';
  const supabaseAnonKey = 'sb_publishable_VJGyAFJVngHpUDFt6PVobQ_6eklYVEc'; // yang di API Keys (Publishable key)

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Greenhouse Coffee',
      initialRoute: '/home',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const AppShell(),
      },
      theme: ThemeData(
        primaryColor: const Color(0xFF6D4C41),
        scaffoldBackgroundColor: const Color(0xFFF0ECE8),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineSmall: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
