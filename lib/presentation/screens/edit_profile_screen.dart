import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/common_scaffold.dart';
import 'package:medi_exam/presentation/widgets/custom_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Dr. Sarah Johnson');
  final _emailController =
  TextEditingController(text: 'sarah.johnson@example.com');
  final _phoneController = TextEditingController(text: '+880 1234 567890');
  final _addressController = TextEditingController();
  final _bmdcController = TextEditingController(text: '123456');

  String? _selectedCollege;
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;

  DateTime? _selectedDate;
  XFile? _selectedImage;
  bool _isLoading = false;

  final List<String> _medicalColleges = const [
    'Dhaka Medical College',
    'Sir Salimullah Medical College',
    'Chittagong Medical College',
    'Rajshahi Medical College',
    'Mymensingh Medical College',
    'Sylhet MAG Osmani Medical College',
    'Rangpur Medical College',
    'Shaheed Suhrawardy Medical College',
  ];

  final List<String> _genders = const ['Male', 'Female', 'Other'];

  final List<String> _bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _divisions = const [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh'
  ];

  final Map<String, List<String>> _districts = {
    'Dhaka': ['Dhaka', 'Gazipur', 'Narayanganj', 'Tangail', 'Manikganj'],
    'Chittagong': ['Chittagong', 'Cox\'s Bazar', 'Comilla', 'Feni', 'Noakhali'],
    'Rajshahi': ['Rajshahi', 'Bogra', 'Pabna', 'Sirajganj', 'Naogaon'],
    'Khulna': ['Khulna', 'Jessore', 'Satkhira', 'Bagerhat', 'Narail'],
    'Barishal': ['Barishal', 'Patuakhali', 'Bhola', 'Jhalokati', 'Pirojpur'],
    'Sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
    'Rangpur': [
      'Rangpur',
      'Dinajpur',
      'Nilphamari',
      'Gaibandha',
      'Lalmonirhat'
    ],
    'Mymensingh': ['Mymensingh', 'Netrokona', 'Jamalpur', 'Sherpur'],
  };

  final Map<String, List<String>> _upazilas = {
    'Dhaka': ['Dhamrai', 'Dohar', 'Keraniganj', 'Nawabganj', 'Savar'],
    'Gazipur': ['Gazipur Sadar', 'Kaliakair', 'Kaliganj', 'Kapasia', 'Sreepur'],
    'Chittagong': [
      'Anwara',
      'Banshkhali',
      'Boalkhali',
      'Chandanaish',
      'Fatikchhari'
    ],
    'Cox\'s Bazar': [
      'Cox\'s Bazar Sadar',
      'Chakaria',
      'Kutubdia',
      'Maheshkhali',
      'Ramu'
    ],
    'Rajshahi': ['Bagha', 'Bagmara', 'Charghat', 'Durgapur', 'Godagari'],
    'Khulna': ['Dacope', 'Dumuria', 'Koyra', 'Paikgacha', 'Phultala'],
    'Barishal': ['Bakerganj', 'Banaripara', 'Gaurnadi', 'Hizla', 'Mehendiganj'],
    'Sylhet': ['Balaganj', 'Beanibazar', 'Bishwanath', 'Companiganj', 'Fenchuganj'],
    'Rangpur': ['Badarganj', 'Gangachara', 'Kaunia', 'Pirgacha', 'Taraganj'],
    'Mymensingh': ['Bhaluka', 'Dhobaura', 'Fulbaria', 'Gaffargaon', 'Gauripur'],
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    Get.back();
    Get.snackbar(
      'Success',
      'Profile updated successfully!',
      backgroundColor: Colors.green[100],
      colorText: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Edit Profile',
      body: SingleChildScrollView(
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

                  // Form Fields
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
                              if (value == null || value.isEmpty) {
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
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
                          const SizedBox(height: 16),

                          // BMDC Number
                          TextFormField(
                            controller: _bmdcController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'BMDC Registration Number',
                              prefixIcon: Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your BMDC number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Medical College
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return DropdownButtonFormField<String>(
                                value: _selectedCollege,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Medical College',
                                  prefixIcon: Icon(Icons.school_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items: _medicalColleges
                                    .map((college) => DropdownMenuItem(
                                  value: college,
                                  child: Text(
                                    college,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCollege = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your medical college';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date of Birth
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : '',
                            ),
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              prefixIcon:
                              const Icon(Icons.calendar_today_outlined),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_month),
                                onPressed: _selectDate,
                              ),
                            ),
                            onTap: _selectDate,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your date of birth';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            items: _genders
                                .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Blood Group
                          DropdownButtonFormField<String>(
                            value: _selectedBloodGroup,
                            decoration: const InputDecoration(
                              labelText: 'Blood Group',
                              prefixIcon: Icon(Icons.bloodtype_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: _bloodGroups
                                .map((bloodGroup) => DropdownMenuItem(
                              value: bloodGroup,
                              child: Text(bloodGroup),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBloodGroup = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your blood group';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Address Information',
                            style: TextStyle(
                              fontSize: Sizes.subTitleText(context),
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Division
                          DropdownButtonFormField<String>(
                            value: _selectedDivision,
                            decoration: const InputDecoration(
                              labelText: 'Division',
                              prefixIcon: Icon(Icons.map_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: _divisions
                                .map((division) => DropdownMenuItem(
                              value: division,
                              child: Text(division),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDivision = value;
                                _selectedDistrict = _districts[value]?.first;
                                _selectedUpazila = _upazilas.containsKey(_selectedDistrict)
                                    ? _upazilas[_selectedDistrict]?.first
                                    : null;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your division';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // District - Only show if division is selected
                          if (_selectedDivision != null)
                            DropdownButtonFormField<String>(
                              value: _selectedDistrict,
                              decoration: const InputDecoration(
                                labelText: 'District',
                                prefixIcon: Icon(Icons.location_city_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: _districts[_selectedDivision]!
                                  .map((district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDistrict = value;
                                  _selectedUpazila = _upazilas.containsKey(value)
                                      ? _upazilas[value]?.first
                                      : null;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your district';
                                }
                                return null;
                              },
                            ),
                          if (_selectedDivision != null) const SizedBox(height: 16),

                          // Upazila - Only show if district is selected and has upazilas
                          if (_selectedDistrict != null && _upazilas.containsKey(_selectedDistrict))
                            DropdownButtonFormField<String>(
                              value: _selectedUpazila,
                              decoration: const InputDecoration(
                                labelText: 'Upazila/Thana',
                                prefixIcon: Icon(Icons.location_on_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: _upazilas[_selectedDistrict]!
                                  .map((upazila) => DropdownMenuItem(
                                value: upazila,
                                child: Text(upazila),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUpazila = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your upazila/thana';
                                }
                                return null;
                              },
                            ),
                          if (_selectedDistrict != null && _upazilas.containsKey(_selectedDistrict))
                            const SizedBox(height: 16),

                          // Address Details - Only show if upazila is selected
                          if (_selectedUpazila != null)
                            TextFormField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Address Details',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.home_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your address details';
                                }
                                return null;
                              },
                            ),
                          if (_selectedUpazila != null) const SizedBox(height: 24),

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
            child: _selectedImage != null
                ? Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatar(),
            )
                : Image.network(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatar(),
            ),
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
    _addressController.dispose();
    _bmdcController.dispose();
    super.dispose();
  }
}