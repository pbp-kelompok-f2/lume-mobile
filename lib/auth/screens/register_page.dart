import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: LumeColors.darkText),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text("Create Account",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: LumeColors.darkText)),
              const SizedBox(height: 40),
              
              // Input Username
              TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      labelText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 16),

              // Input Phone
              TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Min. 9 digits",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 16),

              // Input Password
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 16),

              // Input Confirm Password
              TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Confirm Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Validasi Password Match
                          if (_passwordController.text != 
                              _confirmPasswordController.text) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords do not match!")),
                             );
                             return;
                          }

                          setState(() => _isLoading = true);
                          
                          // Sesuaikan URL dengan environment Anda (Emulator: 10.0.2.2, Browser: 127.0.0.1)
                          String url = "http://localhost:8000/user/api/register/"; 
                          // String url = "http://10.0.2.2:8000/user/api/register/";

                          final response = await request.postJson(
                            url,
                            jsonEncode({
                              'username': _usernameController.text,
                              'phone': _phoneController.text, 
                              'password1': _passwordController.text, 
                              'password2': _confirmPasswordController.text, 
                            }),
                          );

                          if (response['ok'] == true) {
                            // === FIX: MANUALLY SET LOGGED IN STATE ===
                            // Karena postJson tidak otomatis mengubah status login,
                            // kita ubah manual karena backend sudah mengirim session cookie.
                            request.loggedIn = true; 
                            request.jsonData = response; 
                            // ==========================================

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Registration successful!")));
                              
                              // Redirect ke MainScaffold dengan index Home (biasanya 0)
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScaffold(initialIndex: 0),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              String msg = "Registration failed";
                              if (response['errors'] != null) {
                                msg = response['errors'].toString();
                              } else if (response['message'] != null) {
                                msg = response['message'];
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.red));
                            }
                          }
                          setState(() => _isLoading = false);
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: LumeColors.sageGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}