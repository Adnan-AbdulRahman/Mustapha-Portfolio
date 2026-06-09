import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codesController = TextEditingController();
  final List<TextEditingController> _techControllers = [
    TextEditingController()
  ];

  Uint8List? _mainImage;
  List<Uint8List> _galleryImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // ───────── PICK MAIN IMAGE ─────────
  Future<void> _pickMainImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _mainImage = bytes;
      });
    }
  }

  // ───────── PICK GALLERY IMAGES ─────────
  Future<void> _pickGalleryImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final images = await Future.wait(
        pickedFiles.map((e) => e.readAsBytes()),
      );

      setState(() {
        _galleryImages = images;
      });
    }
  }

  // ───────── UPLOAD IMAGE ─────────
  Future<String> _uploadImageToStorage(Uint8List file) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('projects/${const Uuid().v4()}.jpg');

    await storageRef.putData(file);
    return await storageRef.getDownloadURL();
  }

  // ───────── SAVE PROJECT ─────────
  Future<void> _saveProject() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload main image
      String? mainImageUrl;
      if (_mainImage != null) {
        mainImageUrl = await _uploadImageToStorage(_mainImage!);
      }

      // Upload gallery images
      List<String> galleryUrls = [];
      for (var file in _galleryImages) {
        String url = await _uploadImageToStorage(file);
        galleryUrls.add(url);
      }

      // Tech stack list
      List<String> techStacks = _techControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Save project in Firestore
      await FirebaseFirestore.instance.collection('projects').add({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "image": mainImageUrl,
        "projectImages": galleryUrls,
        "techStacks": techStacks,
        "codes": _codesController.text.trim(),
        "status": "Available", // IMPORTANT for your homepage
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Project uploaded successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _codesController.clear();
      _techControllers.clear();

      setState(() {
        _mainImage = null;
        _galleryImages.clear();
        _techControllers.add(TextEditingController());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Project'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Project Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Codes
            TextField(
              controller: _codesController,
              decoration: const InputDecoration(
                labelText: 'Project Code or Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Tech Stack
            const Text(
              'Tech Stack',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: _techControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Technology (e.g. Flutter)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            _techControllers.remove(controller);
                          });
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _techControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Another Tech"),
            ),

            const SizedBox(height: 20),

            // Main Image
            const Text(
              'Main Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickMainImage,
              child: _mainImage == null
                  ? Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child:
                const Center(child: Text('Tap to upload main image')),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  _mainImage!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gallery Images
            const Text(
              'Gallery Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickGalleryImages,
              icon: const Icon(Icons.photo_library),
              label: const Text("Select Gallery Images"),
            ),
            const SizedBox(height: 10),

            if (_galleryImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _galleryImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _galleryImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            // Submit
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProject,
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.cloud_upload),
                label:
                Text(_isLoading ? "Uploading..." : "Upload Project"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}