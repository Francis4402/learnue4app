import 'package:flutter/material.dart';
import 'package:learnue4app/pages/upload_projects.dart';
import 'package:learnue4app/services/auth_services.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    loadUsers();
    super.initState();
  }

  void loadUsers() async {
    final authService = AuthService();

    final fetchUsers = await authService.getUserData(context);

    setState(() {
      users = fetchUsers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'),),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: Center(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(padding: const EdgeInsets.all(50),
                  child: Center(child: Text('Total Users: ${users.length}', style: const TextStyle(fontSize: 20),)),),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(padding: const EdgeInsets.all(50),
                  child: Center(child: Text('Total Projects: ${users.length}', style: const TextStyle(fontSize: 20),)),),
              ),
            ),
          ],
        ),
      ),),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Get.to(() => const UploadProjects(), transition: Transition.circularReveal,
          duration: const Duration(milliseconds: 1000), );
      }, tooltip: 'Upload Project', child: const Icon(Icons.add),),
    );
  }
}
