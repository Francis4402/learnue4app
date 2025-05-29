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
        title: const Text('My Profile'), centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black26,
                child: Icon(Icons.person, size: 50, color: Colors.white)
              ),

              const SizedBox(height: 50),

              Text('Name : ${user.name}'),

              const SizedBox(height: 20),

              Text('Email: ${user.email}'),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: () {
                Get.offAll(() => const MainBottomNavbarScreen());
              }, child: const Text('HomePage'))
            ],
          ),
        ),
      )
    );
  }
}
