import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // Import to format date

import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final databaseRef = FirebaseDatabase.instance.ref();
  User? get user => _authService.currentUser; // Use getter from AuthService

  // Profile Info
  String name = '';
  String username = '';
  String email = '';
  String phone = '';
  String? dateOfBirth;
  String gender = 'Male';
  bool formChanged = false;
  bool isEditingPersonalInfo = false;

  // Password Management
  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
  TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;
  bool isEditingPassword = false;

  // Notification Toggles
  bool emailNotify = true;
  bool pushNotify = true;
  bool smsNotify = false;
  bool marketingNotify = false;

  // UI State
  bool isLoading = false;
  String loadingText = '';
  File? imageFile;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load user profile data from Firebase Authentication and Realtime Database.
  Future<void> _loadProfile() async {
    if (user == null) return;
    setState(() => isLoading = true);
    try {
      // 1. Load from Realtime Database
      final snapshot = await databaseRef.child('users/${user!.uid}').get();
      if (snapshot.exists) {
        // Fix: Properly handle the data type from Firebase
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        setState(() {
          name = data['name']?.toString() ?? '';
          username = data['username']?.toString() ?? '';
          phone = data['phoneNumber']?.toString() ?? '';
          dateOfBirth = data['dateOfBirth']?.toString();
          gender = data['gender']?.toString() ?? 'Male';

          // Handle notifications data properly
          final notifications = data['notifications'] != null
              ? Map<String, dynamic>.from(data['notifications'] as Map<dynamic, dynamic>)
              : <String, dynamic>{};
          emailNotify = notifications['email'] ?? true;
          pushNotify = notifications['push'] ?? true;
          smsNotify = notifications['sms'] ?? false;
          marketingNotify = notifications['marketing'] ?? false;
        });
      } else {
        print('No data exists for this user in the database');
        setState(() {
          name = user!.displayName ?? '';
        });
      }
      // 2. Load email from Firebase Auth. This OVERRIDES anything from the database.
      email = user!.email ?? '';

    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        errorMessage = 'Failed to load profile: $e'; // Set error message
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Function to pick an image from device gallery
  Future<void> _pickImage() async {
    if (!isEditingPersonalInfo) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        formChanged = true;
      });
    }
  }

  // Function to save personal information
  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      loadingText = 'Saving Personal Info...';
      errorMessage = null; // Clear any previous error
    });

    try {

      // Update other personal information in Realtime Database
      await _authService.updateUserData(user!.uid, {
        'name': name,
        'username': username,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      });

      // Update display name in Firebase Authentication
      if (user!.displayName != name) {
        await user!.updateDisplayName(name);
      }

      setState(() {
        isLoading = false;
        formChanged = false;
        isEditingPersonalInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Personal Information updated successfully!'),
      ));
      _loadProfile(); // Reload the profile to reflect changes.

    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
        errorMessage = 'Failed to update profile: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile: $e'),
      ));
    }
  }

  // Function to handle password change
  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmNewPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields.')),
      );
      return;
    }
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('New password must be at least 6 characters long.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      loadingText = 'Changing password...';
      errorMessage = null;
    });

    try {
      // Re-authenticate user before changing password.
      bool success = await _reAuthenticateUser();
      if(success){
        await _authService.changeUserPassword(_newPasswordController.text);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      } else {
        setState(() {
          errorMessage = 'Password change failed: Please enter the correct password.';
        });
        return;
      }

    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update password: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        loadingText = '';
        isEditingPassword = false;
      });
    }
  }

  // Function to save notification settings
  Future<void> _saveNotificationSettings() async {
    setState(() {
      isLoading = true;
      loadingText = 'Saving Notification changes...';
      errorMessage = null;
    });

    try {
      await _authService.updateUserData(user!.uid, {
        'notifications': {
          'email': emailNotify,
          'push': pushNotify,
          'sms': smsNotify,
          'marketing': marketingNotify,
        },
      });
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Notification settings updated successfully!'),
      ));
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
        errorMessage = 'Failed to update notifications: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notifications: $e')),
      );
    }
  }

  // Fixed format date function to handle both string and timestamp
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime date;
      // Check if it's a timestamp (all digits)
      if (RegExp(r'^\d+$').hasMatch(dateString)) {
        // It's a timestamp in milliseconds
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateString));
      } else {
        // It's a date string
        date = DateTime.parse(dateString);
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      print('Error parsing date: $e');
      return dateString; // Return original if parsing fails
    }
  }

  // Function to build text field
  Widget _buildTextField(String label, String value, Function(String) onChanged,
      {bool enabled = true,
        TextInputType type = TextInputType.text,
        Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            enabled: enabled,
            keyboardType: type,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onChanged: (val) {
              onChanged(val);
              if (isEditingPersonalInfo) {
                setState(() => formChanged = true);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: !enabled,
              fillColor: enabled ? null : Colors.grey.shade100,
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }

  // Function to build password field
  Widget _buildPasswordField(String label, TextEditingController controller,
      bool obscureText, Function() toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: isEditingPassword,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: IconButton(
                icon:
                Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              ),
            ),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            onChanged: (val) {
              if (isEditingPassword) {
                setState(() => formChanged = true);
              }
            },
          ),
        ],
      ),
    );
  }

  // Function to build toggle
  Widget _buildToggle(
      String label, String description, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              onChanged(val);
              _saveNotificationSettings();
            },
          ),
        ],
      ),
    );
  }

  // Function to build gender option
  Widget _buildGenderOption(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: gender,
          onChanged: isEditingPersonalInfo
              ? (val) {
            setState(() {
              gender = val!;
              formChanged = true;
            });
          }
              : null,
        ),
        Text(label),
      ],
    );
  }

  // Function to re-authenticate the user.
  Future<bool> _reAuthenticateUser() async {
    final formKey = GlobalKey<FormState>(); // Use a local form
    String? password;
    bool result = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: Form(  // Wrap with a Form
          key: formKey,
          child: TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter your password',
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Required';
              return null;
            },
            onChanged: (val) => password = val,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if(formKey.currentState?.validate() ?? false){ // Check if form is valid
                try {
                  final credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: password!,
                  );
                  await user!.reauthenticateWithCredential(credential);
                  result = true;
                  Navigator.of(context).pop(); // Return true on success
                } on FirebaseAuthException catch (e) {
                  print("Re-authentication error: ${e.message}");
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Re-authentication failed: ${e.message}')),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: isLoading && name.isEmpty && email.isEmpty
                  ? SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: const Center(
                    child: Text('Loading profile data...')),
              )
                  : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: imageFile != null
                                ? FileImage(imageFile!)
                                : const AssetImage(
                                'assets/avatar_placeholder.png')
                            as ImageProvider,
                          ),
                          if (isEditingPersonalInfo)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                  Theme.of(context).primaryColor,
                                  child: const Icon(Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Personal Information',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isEditingPersonalInfo =
                              !isEditingPersonalInfo;
                              formChanged = false;
                            });
                          },
                          child: Text(
                            isEditingPersonalInfo ? 'Save' : 'Edit',
                            style: const TextStyle(
                                color: Color(0xFFbad012)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Username',
                      username,
                          (val) => setState(() => username = val),
                      enabled: isEditingPersonalInfo,
                    ),
                    _buildTextField(
                      'Full Name',
                      name,
                          (val) => setState(() => name = val),
                      enabled: isEditingPersonalInfo,
                    ),
                    _buildTextField(
                      'Phone Number',
                      phone,
                          (val) => setState(() => phone = val),
                      type: TextInputType.phone,
                      enabled: isEditingPersonalInfo,
                    ),
                    // Date of Birth field with calendar picker
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date of Birth',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: isEditingPersonalInfo ? () async {
                              DateTime initialDate = DateTime(2000, 1, 1);

                              // Handle initial date parsing
                              if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
                                try {
                                  if (RegExp(r'^\d+$').hasMatch(dateOfBirth!)) {
                                    // It's a timestamp
                                    initialDate = DateTime.fromMillisecondsSinceEpoch(int.parse(dateOfBirth!));
                                  } else {
                                    // It's a date string
                                    initialDate = DateTime.parse(dateOfBirth!);
                                  }
                                } catch (e) {
                                  print('Error parsing initial date: $e');
                                }
                              }

                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFbad012), // Header background color
                                        onPrimary: Colors.white, // Header text color
                                        onSurface: Colors.black, // Calendar text color
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  dateOfBirth = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                  formChanged = true;
                                });
                              }
                            } : null,
                            child: AbsorbPointer(
                              child: TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: dateOfBirth != null && dateOfBirth!.isNotEmpty
                                      ? _formatDate(dateOfBirth)
                                      : '',
                                ),
                                enabled: isEditingPersonalInfo,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: !isEditingPersonalInfo,
                                  fillColor: isEditingPersonalInfo ? null : Colors.grey.shade100,
                                  suffixIcon: isEditingPersonalInfo
                                      ? const Icon(Icons.calendar_today_outlined)
                                      : null,
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Gender',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    Row(
                      children: [
                        _buildGenderOption('Male'),
                        _buildGenderOption('Female'),
                      ],
                    ),
                    if (isEditingPersonalInfo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            formChanged ? _savePersonalInfo : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFFbad012),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                            child: const Text('Save Personal Info'),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Password Management',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isEditingPassword =
                              !isEditingPassword;
                              formChanged = false;
                            });
                          },
                          child: Text(
                            isEditingPassword ? 'Save' : 'Edit',
                            style: const TextStyle(
                                color: Color(0xFFbad012)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      'Current Password',
                      _currentPasswordController,
                      _obscureCurrentPassword,
                          () {
                        setState(() {
                          _obscureCurrentPassword =
                          !_obscureCurrentPassword;
                        });
                      },
                    ),
                    _buildPasswordField(
                      'New Password',
                      _newPasswordController,
                      _obscureNewPassword,
                          () {
                        setState(() {
                          _obscureNewPassword =
                          !_obscureNewPassword;
                        });
                      },
                    ),
                    _buildPasswordField(
                      'Confirm New Password',
                      _confirmNewPasswordController,
                      _obscureConfirmNewPassword,
                          () {
                        setState(() {
                          _obscureConfirmNewPassword =
                          !_obscureConfirmNewPassword;
                        });
                      },
                    ),
                    if (isEditingPassword)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFFbad012),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                            child: const Text('Change Password'),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Text('Notification Preferences',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildToggle(
                      'Email Notifications',
                      'Receive updates and alerts via email',
                      emailNotify,
                          (val) => setState(() {
                        emailNotify = val;
                      }),
                    ),
                    _buildToggle(
                      'Push Notifications',
                      'Receive alerts on your device',
                      pushNotify,
                          (val) => setState(() {
                        pushNotify = val;
                      }),
                    ),
                    _buildToggle(
                      'SMS Notifications',
                      'Receive text messages for important updates',
                      smsNotify,
                          (val) => setState(() {
                        smsNotify = val;
                      }),
                    ),
                    _buildToggle(
                      'Marketing Communications',
                      'Receive promotional offers and newsletters',
                      marketingNotify,
                          (val) => setState(() {
                        marketingNotify = val;
                      }),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(loadingText,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          if (errorMessage != null) // Show error message.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.red.shade100,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}