import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/views/auth_page.dart';
import 'shell/app_shell.dart';      // <- tambahkan import shell

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Greenhouse Coffee',
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const AppShell(), // <-- arahkan ke shell
      },
      theme: ThemeData(
        primaryColor: const Color(0xFF6D4C41),
        scaffoldBackgroundColor: Color(0xFFF0ECE8),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineSmall: GoogleFonts.poppins(
            fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }
}
