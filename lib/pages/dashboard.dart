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
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.people,
                      title: 'Total Users',
                      value: users.length.toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      icon: Icons.folder,
                      title: 'Total Projects',
                      value: users.length.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
                () => const UploadProjects(),
            transition: Transition.circularReveal,
            duration: const Duration(milliseconds: 1000),
          );
        },
        tooltip: 'Upload Project',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: 200, // Fixed card width
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}