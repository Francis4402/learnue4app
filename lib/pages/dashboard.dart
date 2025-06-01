import 'package:flutter/material.dart';
import 'package:learnue4app/pages/upload_projects.dart';
import 'package:learnue4app/services/auth_services.dart';
import 'package:get/get.dart';
import 'package:learnue4app/services/upload_project_services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> users = [];
  List<dynamic> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    loadUsers();
    loadProjects();
    super.initState();
  }

  Future<void> loadProjects() async {
    final uploadService = UploadService();

    final fetchProjects = await uploadService.getProjects(context: context);

    print(fetchProjects);

    setState(() {
      projects = fetchProjects;
      isLoading = false;
    });
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat cards at the top
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
                      value: projects.length.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Heading for Projects
              const Text(
                'Uploaded Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // List of projects
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final title = project['title'] ?? 'No Title';
                  final downloadUrl = project['downloadUrl'] ?? 'No url';
                  final imageUrls = (project['imageUrls'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                      [];

                  final firstImage = imageUrls.isNotEmpty ? imageUrls.first : null;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: firstImage != null
                            ? SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            firstImage,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(Icons.image_not_supported),
                        title: Text(title),
                        subtitle: Text(downloadUrl),
                        trailing: Wrap(
                          children: [
                            IconButton(onPressed: (){}, icon: const Icon(Icons.delete_forever_outlined)),
                            IconButton(onPressed: (){}, icon: const Icon(Icons.edit)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
