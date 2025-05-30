import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnue4app/models/uploadproject_model.dart';
import 'package:learnue4app/pages/dashboard.dart';
import 'package:learnue4app/utils/key.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:learnue4app/utils/utils.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class UploadService {
  void uploadProject({
    required context,
    required String title,
    required String downloadUrl,
    required String? imageUrls,
  }) async {
    try {
      UploadModel upload = UploadModel(
        title: '',
        downloadUrl: '',
      );

      final res = await http.post(
        Uri.parse('${Constants.uri}/api/posts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(upload),
      );

      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            Get.snackbar(
              "Success",
              "Upload Successful",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.black45,
              colorText: Colors.white,
            );

            Get.offAll(() => const Dashboard());
          });
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }


}
