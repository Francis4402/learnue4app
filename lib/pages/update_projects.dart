import 'package:flutter/material.dart';
import 'package:learnue4app/pages/dashboard.dart';
import 'package:learnue4app/services/upload_project_services.dart';
import 'package:get/get.dart';



class UpdateProjects extends StatefulWidget {
  const UpdateProjects({super.key, required this.projectId});

  final String projectId;

  @override
  State<UpdateProjects> createState() => _UploadProjectsState();
}

class _UploadProjectsState extends State<UpdateProjects> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController projectUrlController = TextEditingController();
  final TextEditingController uploadImageUrlController = TextEditingController();

  final UploadService uploadService = UploadService();

  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    _loadProjectDetails();
    super.initState();
  }

  Future<void> _loadProjectDetails() async {
    try {
      final data = await uploadService.getProjectDetails(
        context: context,
        projectId: widget.projectId,
      );

      setState(() {
        titleController.text = data['title'] ?? '';
        projectUrlController.text = data['downloadUrl'] ?? '';
        uploadImageUrlController.text = data['imageUrls'] ?? '';
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load project details: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isUpdating = true;
    });

    await uploadService.updateProject(
      context: context,
      projectId: widget.projectId,
      title: titleController.text,
      downloadUrl: projectUrlController.text,
      imageUrls: uploadImageUrlController.text,
    ).then((_) {
      isUpdating = false;
      Get.off(() => const Dashboard());
    });
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
      appBar: AppBar(
        title: const Text('Update Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
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
                  if (!Uri.tryParse(value)!.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Image URL Field
              TextFormField(
                controller: uploadImageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.image, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUpdating ? null : _updateProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Project'),
                ),
              ),
            ],
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