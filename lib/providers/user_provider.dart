import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserProvider extends ChangeNotifier {
  final CookieRequest request = CookieRequest();
  String _username = "Guest";
  String _profilePicture = "";
  bool _isAdmin = false;
  String get username => _username;
  String get profilePicture => _profilePicture;
  bool get isAdmin => _isAdmin;

  bool get loggedIn => request.loggedIn;
  Map<String, dynamic> get jsonData => request.jsonData;

  void setUsername(String name, {bool isAdmin = false, String profilePicture = ""}) {
    _username = name;
    _isAdmin = isAdmin;
    _profilePicture = profilePicture;
    notifyListeners(); 
  }

  Future<dynamic> login(String url, Map<String, dynamic> data) async {
    final response = await request.login(url, data);
    notifyListeners(); 
    return response;
  }

  Future<dynamic> logout(String url) async {
    final response = await request.logout(url);
    notifyListeners(); 
    return response;
  }
}