import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view.dart';
import 'signup_view.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF6D4C41), // coklat header
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Title
              Text(
                "Smart Greenhouse Coffee",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Heading
              Text(
                "GET STARTED NOW!",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              // Subtext
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: Text(
                  "Create an account or log in to explore about our app",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Body container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Tab wrapper (diperkecil vertikalnya)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorPadding: const EdgeInsets.symmetric(
                              vertical: 4), // indikator diperkecil vertikal
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: const EdgeInsets.symmetric(vertical: 2),
                          labelColor: const Color(0xFF6D4C41),
                          unselectedLabelColor: Colors.grey,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: "Log In"),
                            Tab(text: "Sign Up"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Expanded(
                        child: TabBarView(
                          children: [
                            LoginView(),
                            SignUpView(),
                          ],
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
    );
  }
}
