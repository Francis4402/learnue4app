import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:learnue4app/pages/dashboard.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:learnue4app/utils/utils.dart';
import 'package:provider/provider.dart';

class UploadService {
  Future<void> uploadProject({
    required context,
    required String title,
    required String downloadUrl,
    required File? images,
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

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.uri}/api/posts'),
      );

      // Add headers
      request.headers['x-auth-token'] = userProvider.user.accessToken;

      // Add fields
      request.fields['title'] = title;
      request.fields['downloadUrl'] = downloadUrl;

      // Add image file if exists
      if (images != null) {
        var fileStream = http.ByteStream(images.openRead());
        var length = await images.length();

        var multipartFile = http.MultipartFile(
          'images',
          fileStream,
          length,
          filename: images.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          Get.snackbar(
            "Success",
            "Upload Successful",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black45,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List> getProjects({required BuildContext context}) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user.role != 'admin') {
        Get.snackbar('Error', 'You are not admin',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return [];
      }

      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/posts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.accessToken,
        },
      );

      print(res);

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
}
