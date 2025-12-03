import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserProvider extends ChangeNotifier {
  final CookieRequest request = CookieRequest();
  String _username = "Guest";
  String get username => _username;

  bool get loggedIn => request.loggedIn;
  Map<String, dynamic> get jsonData => request.jsonData;

  void setUsername(String name) {
    _username = name;
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