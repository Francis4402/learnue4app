import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnue4app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(id: '', name: '', email: '', accessToken: '', password: '', role: '');

  User get user => _user;

  void setUser(String userJson) {
    final userMap = jsonDecode(userJson);
    _user = User.fromJson(userMap);
    notifyListeners();
  }

  void setUserFromModel(User user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user.fullJson()); // ✅ full details
    await prefs.setString('x-auth-token', user.accessToken); // optional
    notifyListeners();
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromFullJson(userJson);
      notifyListeners();
    }
  }

  /// ✅ Optional: clear user on logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('x-auth-token');
    _user = User(id: '', name: '', email: '', accessToken: '', password: '', role: '');
    notifyListeners();
  }
}