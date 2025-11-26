import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserProvider extends ChangeNotifier {
  final CookieRequest request = CookieRequest();

  bool get loggedIn => request.loggedIn;
  Map<String, dynamic> get jsonData => request.jsonData;

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