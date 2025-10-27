import 'package:flutter/material.dart';

class ProfileController {
  const ProfileController();

  void goToAccountSettings(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Setting Akun')),
    );
  }

  void goToChangePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ganti Password')),
    );
  }

  void goToAbout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tentang Aplikasi')),
    );
  }

  Future<void> confirmLogout(BuildContext context) async {
    // Taruh proses logout sebenarnya di sini (auth.signOut(), clear prefs, dsb)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout berhasil')),
    );
  }
}
