import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';

class UploadProjects extends StatefulWidget {
  const UploadProjects({super.key});

  @override
  State<UploadProjects> createState() => _UploadProjectsState();
}

class _UploadProjectsState extends State<UploadProjects> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController projectUrl = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
                // Project Title Field
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
                  controller: projectUrl,
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

                // Image Picker Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Image',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: _selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      color: Colors.white70, size: 40),
                                  SizedBox(height: 8),
                                  Text('Tap to select image',
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedImage != null) {
                      // Handle form submission
                      _uploadProject();
                    } else if (_selectedImage == null) {
                      Get.snackbar('Upload', 'Please Select An Image',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.black45,
                          colorText: Colors.white
                      );
                    }
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

  Future<void> _uploadProject() async {
    try {
      Get.snackbar('Upload', 'Project uploaded successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black45,
          colorText: Colors.white
      );

      // Clear form
      titleController.clear();
      projectUrl.clear();
      setState(() => _selectedImage = null);
    } catch (e) {
      Get.snackbar('Upload', 'Error Upload $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black45,
          colorText: Colors.white
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    projectUrl.dispose();
    super.dispose();
  }
}
