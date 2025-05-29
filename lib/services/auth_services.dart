import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:learnue4app/models/user_model.dart';
import 'package:learnue4app/pages/profilepage.dart';
import 'package:learnue4app/services/bottom_navbar.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:get/get.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:learnue4app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  void signUpUser({
    required context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        role: '',
        accessToken: ''
      );

      final res = await http.post(
        Uri.parse('${Constants.uri}/api/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toMap()),
      );

      print('Status Code: ${res.statusCode}');
      print('Response Body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          Get.snackbar(
            "Success",
            "Registration Successful",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black45,
            colorText: Colors.white,
          );

          Get.offAll(() => const MainBottomNavbarScreen());
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  void signInUser({
    required context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/auth/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          final responseData = jsonDecode(res.body);
          final token = responseData['data']['accessToken'];

          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);


          if (token == null) {
            Get.snackbar(
              "Error",
              "Token not found",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          final user = User.fromJson({
            'data': {
              ...decodedToken,
              'accessToken': token,
            }
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('x-auth-token', token);
          await prefs.setString('user', jsonEncode(decodedToken));

          userProvider.setUserFromModel(user);

          Get.to(() => const ProfilePage());
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // get user data
  Future<List<dynamic>> getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/allusers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.accessToken,
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body)['data'];
        print('Fetched ${data.length} users');
        return data;
      } else {
        print('Failed to load users: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void signOut(context) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear shared preferences
    await prefs.remove('x-auth-token');
    await prefs.remove('user');

    // Clear user from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();

    Get.snackbar(
      "Success",
      "You Are Logged Out",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black45,
      colorText: Colors.white,
    );

    // Navigate to main screen
    Get.offAll(() => const MainBottomNavbarScreen());
  }

}