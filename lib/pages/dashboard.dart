import 'package:flutter/material.dart';
import 'package:learnue4app/pages/update_projects.dart';
import 'package:learnue4app/pages/upload_projects.dart';
import 'package:learnue4app/services/auth_services.dart';
import 'package:get/get.dart';
import 'package:learnue4app/services/bottom_navbar.dart';
import 'package:learnue4app/services/upload_project_services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final UploadService uploadService = UploadService();

  List<dynamic> users = [];
  List<dynamic> projects = [];
  bool isLoading = true;

  Future<void> loadProjects() async {
    final fetchProjects = await uploadService.getProjects(context: context);

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
  void initState() {
    loadUsers();
    loadProjects();
    super.initState();
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
                    const Text(
                      'Uploaded Projects',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final title = project['title'] ?? 'No Title';
                        final downloadUrl = project['downloadUrl'] ?? 'No url';
                        final imageUrls = project['imageUrls'] ?? 'no url';

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                if (imageUrls != 'no url' &&
                                    imageUrls.isNotEmpty)
                                  Image.network(
                                    imageUrls,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 150),
                                  )
                                else
                                  Container(
                                    height: 150,
                                    color: Colors.grey[200],
                                    child: const Center(
                                        child: Text('No image available')),
                                  ),
                                ListTile(
                                  title: Text(title),
                                  subtitle: Text(downloadUrl),
                                  trailing: Wrap(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          final shouldDelete =
                                              await Get.defaultDialog<bool>(
                                            title: "Confirm",
                                            middleText:
                                                "Are you sure you want to delete this project?",
                                            textCancel: "No",
                                            textConfirm: "Yes",
                                            confirmTextColor: Colors.white,
                                            onConfirm: () =>
                                                Get.back(result: true),
                                            onCancel: () =>
                                                Get.back(result: false),
                                          );

                                          if (shouldDelete == true) {
                                            await uploadService.deleteProject(
                                              context: context,
                                              projectId: project['_id'],
                                            );

                                            if (!mounted) return;

                                            await loadProjects();
                                          }
                                        },
                                        icon: const Icon(
                                            Icons.delete_forever_outlined),
                                        color: Colors.red,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Get.to(() => UpdateProjects(
                                              projectId: project['_id']));
                                        },
                                        icon: const Icon(Icons.edit),
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
              0,
              0,
            ),
            items: [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
                onTap: () => Get.off(() => const MainBottomNavbarScreen(), transition: Transition.circularReveal, duration: const Duration(milliseconds: 1000)),
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Upload Project'),
                ),
                onTap: () => Get.to(
                  () => const UploadProjects(),
                  transition: Transition.circularReveal,
                  duration: const Duration(milliseconds: 1000),
                ),
              ),
            ],
          );
        },
        tooltip: 'Menu',
        child: const Icon(Icons.menu), // Or keep Icons.add if you prefer
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
      width: 200,
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
