import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ====== EMAIL FIELD ======
          Text(
            "Nomor Telepon",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Nomor Telepon",
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ====== PASSWORD FIELD ======
          Text(
            "Password",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: const Icon(Icons.visibility_off, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ====== REMEMBER + FORGOT ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    activeColor: const Color(0xFF6D4C41),
                  ),
                  Text("Remember me",
                      style: GoogleFonts.poppins(fontSize: 13)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blueAccent,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          // ====== LOGIN BUTTON ======
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text(
                "Log In",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
