import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgetin_app/screen/partials/color.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: _currentUser?.displayName ??
          _currentUser?.email?.split('@')[0] ??
          '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateUserProfile() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final oldPassword = _oldPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();

      // ================= VALIDASI PASSWORD BARU =================
      // Jika user ingin ganti password
      if (newPassword.isNotEmpty) {
        // 1. Previous password wajib diisi
        if (oldPassword.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-old-password',
          );
        }

        // 2. Minimal 6 karakter
        if (newPassword.length < 6) {
          throw FirebaseAuthException(
            code: 'weak-password',
          );
        }
      }

      // ================= UPDATE USERNAME =================
      if (_usernameController.text.trim() !=
          (_currentUser?.displayName ?? '')) {
        await _currentUser?.updateDisplayName(
          _usernameController.text.trim(),
        );
      }

      // ================= UPDATE PASSWORD =================
      if (newPassword.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: _currentUser!.email!,
          password: oldPassword,
        );

        // cek previous password
        await _currentUser!.reauthenticateWithCredential(credential);

        // update password baru
        await _currentUser!.updatePassword(newPassword);
      }

      await _currentUser?.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == 'wrong-password') {
        message = "Previous password is incorrect";
      } else if (e.code == 'weak-password') {
        message = "Password should be at least 6 characters";
      } else if (e.code == 'missing-old-password') {
        message = "Please enter previous password";
      } else if (e.code == 'requires-recent-login') {
        message = "Please login again";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final photoURL = _currentUser?.photoURL;
    final displayName = _usernameController.text;

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ================= WHITE CARD =================
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  children: [
                    const SizedBox(height: 70),
                    Center(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Account Settings",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    const Text("Username"),
                    const SizedBox(height: 8),
                    _buildUsernameField(),

                    const SizedBox(height: 20),
                    const Text("New Password"),
                    const SizedBox(height: 8),
                    _buildNewPasswordField(),
                    const Text(
                      "new password should be at least 6 characters",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 12),
                    _buildOldPasswordField(),
                    const Text(
                      "previous password should be correct",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                        _isLoading ? null : _updateUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          minimumSize: const Size(220, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Update Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ================= AVATAR =================
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: photoURL != null
                      ? NetworkImage(photoURL)
                      : const AssetImage(
                    "assets/images/john_smith.png",
                  ) as ImageProvider,
                ),
              ),
            ),

            // ================= HEADER =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================
  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      decoration: _inputDecoration(),
    );
  }

  Widget _buildOldPasswordField() {
    return TextField(
      controller: _oldPasswordController,
      obscureText: !_oldPasswordVisible,
      decoration: _inputDecoration(
        icon: _oldPasswordVisible
            ? Icons.visibility
            : Icons.visibility_off,
        onTap: () =>
            setState(() => _oldPasswordVisible = !_oldPasswordVisible),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return TextField(
      controller: _newPasswordController,
      obscureText: !_newPasswordVisible,
      decoration: _inputDecoration(
        icon: _newPasswordVisible
            ? Icons.visibility
            : Icons.visibility_off,
        onTap: () =>
            setState(() => _newPasswordVisible = !_newPasswordVisible),
      ),
    );
  }

  InputDecoration _inputDecoration({IconData? icon, VoidCallback? onTap}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      suffixIcon: icon != null
          ? IconButton(
        icon: Icon(icon, color: Colors.grey),
        onPressed: onTap,
      )
          : null,
    );
  }

  Widget _buildSwitchOption({
    required String title,
    required bool value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Switch(value: value, onChanged: (_) {}, activeColor: primary),
      ],
    );
  }
}