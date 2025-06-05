import 'package:flutter/material.dart';
import 'package:learnue4app/services/upload_project_services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class ProjectFilesReview extends StatefulWidget {
  const ProjectFilesReview({super.key});

  @override
  State<ProjectFilesReview> createState() => _ProjectFilesReviewState();
}

class _ProjectFilesReviewState extends State<ProjectFilesReview> {
  final UploadService uploadService = UploadService();
  List<dynamic> projects = [];
  bool isLoading = true;

  Future<void> loadProjects() async {
    final fetchProjects = await uploadService.getProjects(context: context);
    setState(() {
      projects = fetchProjects;
      isLoading = false;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  @override
  void initState() {
    loadProjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Projects'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final title = project['title'] ?? 'No Title';
              final downloadUrl = project['downloadUrl'] ?? 'No Url';
              final imageUrls = project['imageUrls'] ?? "No Url";

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      if (imageUrls != 'no url' && imageUrls.isNotEmpty)
                        Image.network(
                          imageUrls,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 200),
                        )
                      else
                        Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                              child: Text('No image available')),
                        ),
                      ListTile(
                        title: Text(title, style: const TextStyle(fontSize: 20),),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final shouldDownload =
                                await Get.defaultDialog<bool>(
                                  title: "Download",
                                  middleText:
                                  "Are you sure you want to download this project?",
                                  textCancel: "No",
                                  textConfirm: "Yes",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () => Get.back(result: true),
                                  onCancel: () => Get.back(result: false),
                                );

                                if (shouldDownload == true && downloadUrl != 'No Url') {
                                  _launchUrl(downloadUrl);
                                }
                              },
                              icon: const Icon(Icons.download),
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
        ),
      ),
    );
  }
}