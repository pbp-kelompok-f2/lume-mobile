import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/auth/screens/register_page.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa, size: 80, color: LumeColors.darkGreen),
              const SizedBox(height: 20),
              const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: LumeColors.darkText)),
              const SizedBox(height: 40),
              
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    String username = _usernameController.text;
                    String password = _passwordController.text;

                    final response = await request.login("http://127.0.0.1:8000/user/login/", {
                      'username': username,
                      'password': password,
                    });

                    if (request.loggedIn) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login successful!"), backgroundColor: LumeColors.sageGreen));

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScaffold(initialIndex: 3)),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Failed'),
                            content: Text(response['message'] ?? "Invalid credentials"),
                            actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
                          ),
                        );
                      }
                    }
                    setState(() => _isLoading = false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: LumeColors.darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: LumeColors.mutedText)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                    },
                    child: const Text("Sign Up", style: TextStyle(color: LumeColors.darkGreen, fontWeight: FontWeight.bold)),
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