import 'package:flutter/material.dart';
import 'package:lume_mobile/providers/user_provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/auth/screens/register_page.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';
import 'package:lume_mobile/admin/screens/admin_home_page.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';

class LoginPage extends StatefulWidget {
  // dipakai untuk menentukan apakah perlu tampilkan tombol back
  final bool showBack;

  const LoginPage({
    super.key,
    this.showBack = false, // default: login biasa tanpa back
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: widget.showBack
          ? const LumeAppBar(title: "Login")
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: LumeColors.darkText,
                ),
              ),
              const SizedBox(height: 40),

              // Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          String username = _usernameController.text;
                          String password = _passwordController.text;

                          final response = await request.login(
                            apiPath("/user/api/login/"),
                            {
                              'username': username,
                              'password': password,
                              'ajax': '1',
                            },
                          );

                          if (request.loggedIn) {
          if (context.mounted) {
            // --- LOGIKA BARU DI SINI ---
            
            // 1. Ambil data dari response JSON (sesuai struktur Django yang baru)
            // Struktur: { "ok": true, "user": { "username": "...", "is_staff": true } }
            final userData = response['user']; 
            String user = userData['username'];
            bool isAdmin = userData['is_staff'] ?? false; // Default false jika null
            String picUrl = userData['profile_picture'] ?? "";

            // 2. Simpan ke Provider
            context.read<UserProvider>().setUsername(user, isAdmin: isAdmin, profilePicture: picUrl);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login successful!"),
                backgroundColor: LumeColors.sageGreen,
              ),
            );

            // 3. Navigasi Berdasarkan Role
            if (isAdmin) {
              // Jika Admin -> Ke Admin Dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()),
              );
            } else {
              // Jika User Biasa -> Ke Main Scaffold
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScaffold()),
              );
            }
          }
        } else {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Login Failed'),
                content: Text(
                  response['detail'] ?? "Invalid credentials", // API kadang kirim 'detail' atau 'message'
                ),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        }
        setState(() => _isLoading = false);
      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LumeColors.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: LumeColors.mutedText),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: LumeColors.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
