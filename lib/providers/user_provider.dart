import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserProvider extends ChangeNotifier {
  final CookieRequest request = CookieRequest();
  String _username = "Guest";
  bool _isAdmin = false;
  String get username => _username;
  bool get isAdmin => _isAdmin;

  bool get loggedIn => request.loggedIn;
  Map<String, dynamic> get jsonData => request.jsonData;

  void setUsername(String name, {bool isAdmin = false}) {
    _username = name;
    _isAdmin = isAdmin;
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