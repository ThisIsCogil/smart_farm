import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    final confirmController = TextEditingController();

    InputDecoration _decoration(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF6F6F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );

    Text _label(String text) => Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ====== NAME ======
          _label("Name"),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: _decoration("Enter your full name"),
          ),
          const SizedBox(height: 16),

          // ====== PHONE ======
          _label("Phone Number"),
          const SizedBox(height: 6),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: _decoration("Enter your phone number"),
          ),
          const SizedBox(height: 16),

          // ====== EMAIL ======
          _label("Email"),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _decoration("Enter your email"),
          ),
          const SizedBox(height: 16),

          // ====== PASSWORD ======
          _label("Password"),
          const SizedBox(height: 6),
          TextField(
            controller: passController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: _decoration("Create a password").copyWith(
              suffixIcon: const Icon(Icons.visibility_off, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // ====== CONFIRM PASSWORD ======
          _label("Confirm Password"),
          const SizedBox(height: 6),
          TextField(
            controller: confirmController,
            obscureText: true,
            decoration: _decoration("Re-enter your password").copyWith(
              suffixIcon: const Icon(Icons.visibility_off, size: 20),
            ),
          ),
          const SizedBox(height: 22),

          // ====== TERMS (opsional, UI saja) ======
          Row(
            children: [
              Checkbox(
                value: true,
                onChanged: (_) {},
                activeColor: const Color(0xFF6D4C41),
              ),
              Expanded(
                child: Text(
                  "I agree to the Terms & Privacy Policy",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ====== SIGN UP BUTTON ======
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
                // UI only; logic nanti
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("UI only: Sign Up pressed")),
                );
              },
              child: Text(
                "Sign Up",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
