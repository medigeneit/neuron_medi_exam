// lib/presentation/screens/edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medi_exam/data/models/update_profile_model.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/update_profile_service.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _phoneController = TextEditingController(text: '');

  final _updateService = UpdateProfileService();

  XFile? _selectedImage; // newly picked image (local)
  String? _photoUrl; // existing photo from storage (URL or local path)
  bool _isLoading = false;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    await LocalStorageService.init();

    final name = LocalStorageService.getDoctorName();
    final email = LocalStorageService.getDoctorEmail();
    final phone = LocalStorageService.getDoctorPhone();
    final photo = LocalStorageService.getDoctorPhoto();

    setState(() {
      if (name != null && name.isNotEmpty) _nameController.text = name;
      if (email != null && email.isNotEmpty) _emailController.text = email;
      if (phone != null && phone.isNotEmpty) _phoneController.text = phone;
      _photoUrl = photo; // can be URL or a local file path, or null
      _initializing = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Call API: name + email + (optional) photo
    final NetworkResponse resp = await _updateService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      photo: _selectedImage != null ? File(_selectedImage!.path) : null,
    );

    if (resp.isSuccess) {
      // Try to normalize into UpdateProfileResponse
      UpdateProfileResponse? model;
      final raw = resp.responseData;

      if (raw is UpdateProfileResponse) {
        model = raw;
      } else if (raw is Map<String, dynamic>) {
        model = UpdateProfileResponse.fromJson(raw);
      } else if (raw is String) {
        model = UpdateProfileResponse.fromJsonString(raw);
      }

      final doc = model?.doctor;

      // Persist locally (prefer server values; fallback to current UI/local values)
      await LocalStorageService.setDoctorFields(
        name: doc?.name ?? _nameController.text.trim(),
        email: doc?.email ?? _emailController.text.trim(),
        phone: doc?.phoneNumber ?? _phoneController.text.trim(),
        photo: doc?.photo ??
            (_selectedImage != null ? _selectedImage!.path : _photoUrl),
      );

      setState(() {
        _photoUrl = doc?.photo ??
            (_selectedImage != null ? _selectedImage!.path : _photoUrl);
        _selectedImage = null; // clear picker after upload
        _isLoading = false;
      });

      Get.offAllNamed(RouteNames.navBar, arguments: 4);
      Get.snackbar(
        'Success',
        model?.message?.isNotEmpty == true
            ? model!.message!
            : 'Profile updated successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.black,
      );
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Update failed',
        (resp.errorMessage?.toString().trim().isNotEmpty ?? false)
            ? resp.errorMessage!
            : 'Something went wrong. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Edit Profile',
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Image
                        _buildProfileImageSection(),
                        const SizedBox(height: 24),

                        // Card with fields
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: Sizes.subTitleText(context),
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final v = value?.trim() ?? '';
                                    if (v.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                        .hasMatch(v)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone (disabled)
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: false,
                                ),
                                const SizedBox(height: 24),

                                // Save Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Save Changes',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.secondaryColor.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildProfileImageContent(),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
            onPressed: _pickImage,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageContent() {
    // Priority: newly picked image -> stored URL -> stored local path -> default avatar
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      );
    }

    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      final p = _photoUrl!;
      if (p.startsWith('http://') || p.startsWith('https://')) {
        return Image.network(
          p,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        );
      } else {
        // treat as local file path
        return Image.file(
          File(p),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        );
      }
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: AppColor.whiteColor,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
