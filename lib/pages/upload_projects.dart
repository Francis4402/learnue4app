import 'package:flutter/material.dart';
import 'package:learnue4app/pages/dashboard.dart';
import 'package:learnue4app/services/upload_project_services.dart';
import 'package:get/get.dart';

class UploadProjects extends StatefulWidget {
  const UploadProjects({super.key});

  @override
  State<UploadProjects> createState() => _UploadProjectsState();
}

class _UploadProjectsState extends State<UploadProjects> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController projectUrlController = TextEditingController();
  final TextEditingController uploadImageUrlController = TextEditingController();

  final UploadService uploadService = UploadService();


  void _uploadProject() async {
    if (_formKey.currentState!.validate()) {
      String title = titleController.text.trim();
      String url = projectUrlController.text.trim();
      String imageUrl = uploadImageUrlController.text.trim();

      await uploadService.uploadProject(
        context: context,
        title: title,
        downloadUrl: url, imageUrls: imageUrl,

      ).then((_) {
        _clearForm();
        Get.off(() => const Dashboard());
      });
    }
  }

  void _clearForm() {
    titleController.clear();
    projectUrlController.clear();
    uploadImageUrlController.clear();

    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Project')),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.title, color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter project title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Project URL Field
                TextFormField(
                  controller: projectUrlController,
                  decoration: InputDecoration(
                    labelText: 'Project URL',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.link, color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter project URL';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: uploadImageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image Url',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.link, color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter project URL';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),


                ElevatedButton(
                  onPressed: () {
                    _uploadProject();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Upload Project'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    projectUrlController.dispose();
    uploadImageUrlController.dispose();
    super.dispose();
  }

}
