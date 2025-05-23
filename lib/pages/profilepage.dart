import 'package:flutter/material.dart';
import 'package:learnue4app/services/bottom_navbar.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('id: ${user.id}'),
            Text('Email: ${user.email}'),
            Text('Name: ${user.name}'),
            Text('Role: ${user.role}'),
            Text('Token: ${user.accessToken}'),
            ElevatedButton(
                onPressed: () {
                  Get.to(const MainBottomNavbarScreen());
                },
                child: const Text('Home Page'))
          ],
        ),
      ),
    );
  }
}
