import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnue4app/utils/key.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadService {
  Future<void> uploadProject({
    required context,
    required String title,
    required String downloadUrl,
    required String imageUrls,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user.role != 'admin') {
        Get.snackbar(
          'Error',
          'Only Admins can upload projects',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (imageUrls.isEmpty) {
        throw Exception('Please provide at least one image URL');
      }


      final response = await http.post(
        Uri.parse('${Constants.uri}/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': userProvider.user.accessToken,
        },
        body: jsonEncode({
          'title': title,
          'downloadUrl': downloadUrl,
          'imageUrls': imageUrls,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Project Uploaded successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black45,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to Upload Project');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error Uploading Project',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteProject({
    required context,
    required String projectId,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user.role != 'admin') {
        Get.snackbar(
          'Error',
          'Only Admins can delete projects',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      http.Response res = await http.delete(
        Uri.parse('${Constants.uri}/api/posts/$projectId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.accessToken,
        },
      );


      if (res.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Project deleted successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black45,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to delete');
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Error Deleting Project',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateProject({
    required context,
    required String projectId,
    required String title,
    required String downloadUrl,
    required String imageUrls,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user.role != 'admin') {
        Get.snackbar(
          'Error',
          'Only Admins can update projects',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (imageUrls.isEmpty) {
        throw Exception('Please provide at least one image URL');
      }

      final response = await http.put(
        Uri.parse('${Constants.uri}/api/posts/$projectId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': userProvider.user.accessToken,
        },
        body: jsonEncode({
          'title': title,
          'downloadUrl': downloadUrl,
          'imageUrls': imageUrls,
        }),
      );

      if(response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Project Updated successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black45,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to Update Project');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error Updating Project',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List> getProjects({required BuildContext context}) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/posts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.accessToken,
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body)['data'];
        return data;
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getProjectDetails({
    required context,
    required String projectId,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/posts/$projectId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.accessToken,
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      } else {
        throw Exception('Failed to load project details');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }
}
