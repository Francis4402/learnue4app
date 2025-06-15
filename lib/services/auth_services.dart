import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:learnue4app/auth/loginpage.dart';
import 'package:learnue4app/models/user_model.dart';
import 'package:learnue4app/pages/reset_password.dart';
import 'package:learnue4app/services/bottom_navbar.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:get/get.dart';
import 'package:learnue4app/utils/user_provider.dart';
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
          accessToken: '');

      final res = await http.post(
        Uri.parse('${Constants.uri}/api/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toMap()),
      );

      final responseData = jsonDecode(res.body);

      if (res.statusCode == 200) {
        Get.offAll(() => const MainBottomNavbarScreen());

        Get.snackbar(
          "Success",
          "Registration Successful",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black45,
          colorText: Colors.white,
        );
      } else {
        throw Exception(responseData['message'] ?? 'Failed to SignUp');
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        'Please Enter Validate User Data',
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

      final responseData = jsonDecode(res.body);
      final token = responseData['data']['accessToken'];

      if (res.statusCode == 200) {

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

        Get.off(() => const MainBottomNavbarScreen());
      } else {
        throw Exception(responseData['message'] ?? 'Failed To Login');
      }
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

  Future<bool> hasUnread({required String receiverId, required String senderId}) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/messages/hasUnread/$receiverId/$senderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hasUnread'] == true;
      } else {
        print('Failed to check hasUnread: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error in hasUnread: $e');
      return false;
    }
  }


  Future<List<String>> getUnreadStatus(
      String currentUserId, BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse('${Constants.uri}/api/messages/unreadCount/$currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': userProvider.user.accessToken,
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((entry) => entry['_id'] as String).toList();
      } else {
        throw Exception(
            'Failed to fetch unread statuses: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getUnreadStatus: $e');
      throw Exception('Failed to fetch unread statuses');
    }
  }

  void changePassword({
    required context,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/auth/change-password'),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.accessToken,
        },
      );

      final responseData = jsonDecode(res.body);
      final token = responseData['data']['accessToken'];

      if (res.statusCode == 200) {
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

        Get.off(() => const MainBottomNavbarScreen());
      } else {
        throw Exception(responseData['message'] ?? 'Failed To change password');
      }

    } catch (e) {
      Get.snackbar(
        "Error",
        "Password didn't change",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> forgotPassword({required context, required String email}) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.uri}/api/auth/forgot-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(res.body);
      final resetToken = responseData['data']['resetToken'];

      if (res.statusCode == 200) {
        Get.off(() => ResetPasswordPage(resetToken: resetToken));
        Get.snackbar("Success", "Password reset link added",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to get reset token');
      }

    } catch (e) {
      Get.snackbar(
        "Error",
        'User is not Validate',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resetPassword(
      {required context,
      required String token,
      required String newPassword}) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final res = await http.post(
        Uri.parse('${Constants.uri}/api/auth/reset-password'),
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(res.body);

      if (res.statusCode == 200) {
        Get.snackbar("Success", "Password reset successfully",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Get.offAll(() => const LoginPage());
      } else {
        throw Exception(responseData['message'] ?? 'Failed to reset password');
      }

    } catch (e) {
      Get.snackbar(
        "Error",
        'Failed to reset password',
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
