import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/providers/user_provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  
  bool _isLoading = false;
  final String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _usernameController.text = userProvider.username;
    _imageController.text = userProvider.profilePicture;

    final request = context.read<CookieRequest>();
    if (request.jsonData['user'] != null && request.jsonData['user']['phone'] != null) {
       _phoneController.text = request.jsonData['user']['phone'];
       if (_imageController.text.isEmpty) {
         _imageController.text = request.jsonData['user']['profile_picture'] ?? "";
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(title: "Edit Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Username"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                decoration: _inputDecoration("Enter your username"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),

              _buildLabel("Profile Picture URL"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageController,
                decoration: _inputDecoration("Enter image URL"),
                keyboardType: TextInputType.url,
              ),
              
              _buildLabel("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Enter your phone number"),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      
                      final response = await request.postJson(
                        "$baseUrl/user/api/profile/update/",
                        jsonEncode({
                          "username": _usernameController.text,
                          "phone": _phoneController.text,
                          "profile_picture": _imageController.text,
                        }),
                      );

                      if (context.mounted) {
                        if (response['ok'] == true) {
                          context.read<UserProvider>().setUsername(
                            response['user']['username'],
                            isAdmin: context.read<UserProvider>().isAdmin,
                            profilePicture: response['user']['profile_picture'] ?? ""
                          );
                          
                          request.jsonData['user'] = response['user'];

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile updated successfully!"),
                              backgroundColor: LumeColors.sageGreen,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['detail'] ?? "Update failed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LumeColors.sageGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Save Changes",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: LumeColors.darkText,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LumeColors.sageGreen, width: 1.5),
      ),
    );
  }
}
