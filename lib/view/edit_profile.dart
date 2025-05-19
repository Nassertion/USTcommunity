import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/constant/ConstantLinks.dart'; // تأكد أن هذا يحتوي على linkServerName
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/services/api_server.dart'; // يحتوي على دالة uploadUserProfile

class EditProfileScreen extends StatefulWidget {
  final String? currentDisplayName;
  final String? currentBio;
  final String? currentImageUrl;

  const EditProfileScreen({
    Key? key,
    this.currentDisplayName,
    this.currentBio,
    this.currentImageUrl,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  XFile? _selectedImageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.currentDisplayName ?? '');
    _bioController = TextEditingController(text: widget.currentBio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String? getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    } else if (imageUrl.startsWith('/')) {
      return '${linkServerName}storage$imageUrl';
    }
    return '${linkServerName}storage/$imageUrl';
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _selectedImageFile = picked;
        });
      }
    } catch (e) {
      print("خطأ في اختيار الصورة: $e");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await crud.uploadUserProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        imageFile: _selectedImageFile,
      );

      if (response == null) {
        _showError("فشل تحديث البيانات، حاول مرة أخرى");
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError("حدث خطأ: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = getFullImageUrl(widget.currentImageUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text("تعديل الملف الشخصي"),
        backgroundColor: kPrimaryolor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryolor))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _selectedImageFile != null
                                ? FileImage(File(_selectedImageFile!.path))
                                : (fullImageUrl != null
                                    ? NetworkImage(fullImageUrl)
                                    : AssetImage("assets/images/user.png")
                                        as ImageProvider),
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt, color: kPrimaryolor),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: "اسم المستخدم",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "الرجاء إدخال اسم المستخدم";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "الوصف الشخصي (بايو)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryolor,
                        foregroundColor: Colors.white,
                        fixedSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "حفظ التعديلات",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
