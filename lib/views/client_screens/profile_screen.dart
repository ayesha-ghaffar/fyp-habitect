import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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
  User? get user => _authService.currentUser;

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
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
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

  Future<void> _loadProfile() async {
    print('🔍 DEBUG: Starting _loadProfile');
    if (user == null) {
      print('❌ DEBUG: User is null');
      return;
    }

    print('✅ DEBUG: User found - UID: ${user!.uid}');
    setState(() => isLoading = true);

    try {
      print('📡 DEBUG: Fetching data from Firebase...');
      final snapshot = await databaseRef.child('users/${user!.uid}').get();

      if (snapshot.exists) {
        print('✅ DEBUG: Data exists in Firebase');
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        print('📊 DEBUG: Retrieved data: $data');

        setState(() {
          name = data['name']?.toString() ?? '';
          username = data['username']?.toString() ?? '';
          phone = data['phoneNumber']?.toString() ?? '';
          dateOfBirth = data['dateOfBirth']?.toString();

          String genderFromDB = data['gender']?.toString() ?? 'male';
          gender = _capitalizeGender(genderFromDB);

          final notifications = data['notifications'] != null
              ? Map<String, dynamic>.from(data['notifications'] as Map<dynamic, dynamic>)
              : <String, dynamic>{};
          emailNotify = notifications['email'] ?? true;
          pushNotify = notifications['push'] ?? true;
          smsNotify = notifications['sms'] ?? false;
          marketingNotify = notifications['marketing'] ?? false;
        });

        print('✅ DEBUG: State updated with Firebase data');
      } else {
        print('⚠️ DEBUG: No data exists for this user in Firebase');
        setState(() {
          name = user!.displayName ?? '';
        });
      }

      email = user!.email ?? '';
      print('📧 DEBUG: Email from Auth: $email');

    } catch (e) {
      print('❌ DEBUG: Error loading profile: $e');
      setState(() {
        errorMessage = 'Failed to load profile: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _capitalizeGender(String genderFromDB) {
    switch (genderFromDB.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return 'Male';
    }
  }

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

  // FIXED: Enhanced _savePersonalInfo with better validation
  Future<void> _savePersonalInfo() async {
    print('💾 DEBUG: Starting _savePersonalInfo');

    // Manual validation instead of relying on form validation
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Full Name is required');
    }
    if (username.trim().isEmpty) {
      errors.add('Username is required');
    }
    if (phone.trim().isEmpty) {
      errors.add('Phone Number is required');
    }

    // Show specific error messages
    if (errors.isNotEmpty) {
      print('❌ DEBUG: Validation failed: ${errors.join(', ')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if user exists
    if (user == null) {
      print('❌ DEBUG: User is null during save');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    print('📝 DEBUG: Saving data: name=$name, username=$username, phone=$phone, gender=$gender');

    setState(() {
      isLoading = true;
      loadingText = 'Saving Personal Info...';
      errorMessage = null;
    });

    try {
      // Prepare data to save
      final dataToSave = {
        'name': name.trim(),
        'username': username.trim(),
        'phoneNumber': phone.trim(),
        'dateOfBirth': dateOfBirth,
        'gender': gender.toLowerCase(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      print('📤 DEBUG: Data to save: $dataToSave');

      // Save to Firebase Realtime Database
      await databaseRef.child('users/${user!.uid}').update(dataToSave);
      print('✅ DEBUG: Data saved to Firebase successfully');

      // Update display name in Firebase Authentication if changed
      if (user!.displayName != name.trim()) {
        await user!.updateDisplayName(name.trim());
        print('✅ DEBUG: Display name updated in Auth');
      }

      // Update UI state
      setState(() {
        isLoading = false;
        formChanged = false;
        isEditingPersonalInfo = false;
        errorMessage = null;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal Information updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      print('✅ DEBUG: Success message shown');

      // Reload profile to confirm changes
      await _loadProfile();

    } catch (e) {
      print('❌ DEBUG: Error saving personal info: $e');

      setState(() {
        isLoading = false;
        loadingText = '';
        errorMessage = 'Failed to update profile: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // FIXED: Enhanced _changePassword with better error handling
  Future<void> _changePassword() async {
    print('🔐 DEBUG: Starting _changePassword');

    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
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
      // Re-authenticate user before changing password
      print('🔒 DEBUG: Re-authenticating user...');
      bool success = await _reAuthenticateUser();

      if (success) {
        print('✅ DEBUG: Re-authentication successful, changing password...');
        await user!.updatePassword(_newPasswordController.text);

        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();

        setState(() {
          isEditingPassword = false;
          formChanged = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        print('✅ DEBUG: Password changed successfully');
      } else {
        print('❌ DEBUG: Re-authentication failed');
        setState(() {
          errorMessage = 'Password change failed: Please enter the correct current password.';
        });
      }

    } catch (e) {
      print('❌ DEBUG: Error changing password: $e');
      setState(() {
        errorMessage = 'Failed to update password: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
    }
  }

  // FIXED: Enhanced _saveNotificationSettings
  Future<void> _saveNotificationSettings() async {
    print('🔔 DEBUG: Saving notification settings');

    setState(() {
      isLoading = true;
      loadingText = 'Saving Notification changes...';
      errorMessage = null;
    });

    try {
      final notificationData = {
        'notifications': {
          'email': emailNotify,
          'push': pushNotify,
          'sms': smsNotify,
          'marketing': marketingNotify,
        },
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await databaseRef.child('users/${user!.uid}').update(notificationData);

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      print('✅ DEBUG: Notification settings saved successfully');

    } catch (e) {
      print('❌ DEBUG: Error saving notifications: $e');
      setState(() {
        isLoading = false;
        loadingText = '';
        errorMessage = 'Failed to update notifications: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime date;
      if (RegExp(r'^\d+$').hasMatch(dateString)) {
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateString));
      } else {
        date = DateTime.parse(dateString);
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      print('Error parsing date: $e');
      return dateString;
    }
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged,
      {bool enabled = true,
        TextInputType type = TextInputType.text,
        Widget? suffixIcon,
        bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              if (isRequired && enabled)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            enabled: enabled,
            keyboardType: type,
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFbad012), width: 2),
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
            activeColor: const Color(0xFFbad012),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: gender,
          activeColor: const Color(0xFFbad012),
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

  // FIXED: Enhanced re-authentication
  Future<bool> _reAuthenticateUser() async {
    print('🔐 DEBUG: Starting re-authentication');
    final formKey = GlobalKey<FormState>();
    String? password;
    bool result = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: Form(
          key: formKey,
          child: TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter your current password',
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              return null;
            },
            onChanged: (val) => password = val,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ DEBUG: Re-authentication cancelled');
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  print('🔒 DEBUG: Attempting re-authentication...');
                  final credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: password!,
                  );
                  await user!.reauthenticateWithCredential(credential);
                  result = true;
                  print('✅ DEBUG: Re-authentication successful');
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch (e) {
                  print("❌ DEBUG: Re-authentication error: ${e.message}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Authentication failed: ${e.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
                                  backgroundColor: const Color(0xFFbad012),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Personal Information',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            print('🔄 DEBUG: Edit/Save button pressed. isEditingPersonalInfo: $isEditingPersonalInfo');
                            if (isEditingPersonalInfo) {
                              await _savePersonalInfo();
                            } else {
                              setState(() {
                                isEditingPersonalInfo = true;
                                formChanged = false;
                              });
                              print('✅ DEBUG: Editing mode enabled');
                            }
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
                    _buildTextField('Username', username, (val) => setState(() => username = val), enabled: isEditingPersonalInfo),
                    _buildTextField('Full Name', name, (val) => setState(() => name = val), enabled: isEditingPersonalInfo),
                    _buildTextField('Phone Number', phone, (val) => setState(() => phone = val), type: TextInputType.phone, enabled: isEditingPersonalInfo),

                    // Date of Birth field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date of Birth', style: TextStyle(fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: isEditingPersonalInfo ? () async {
                              DateTime initialDate = DateTime(2000, 1, 1);
                              if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
                                try {
                                  if (RegExp(r'^\d+$').hasMatch(dateOfBirth!)) {
                                    initialDate = DateTime.fromMillisecondsSinceEpoch(int.parse(dateOfBirth!));
                                  } else {
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
                                        primary: Color(0xFFbad012),
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: !isEditingPersonalInfo,
                                  fillColor: isEditingPersonalInfo ? null : Colors.grey.shade100,
                                  suffixIcon: isEditingPersonalInfo ? const Icon(Icons.calendar_today_outlined) : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('Gender', style: TextStyle(fontSize: 14, color: Colors.black87)),
                    Row(
                      children: [
                        _buildGenderOption('Male'),
                        _buildGenderOption('Female'),
                        _buildGenderOption('Other'),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Password Management',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            print('🔐 DEBUG: Password Edit/Save button pressed. isEditingPassword: $isEditingPassword');
                            if (isEditingPassword) {
                              await _changePassword();
                            } else {
                              setState(() {
                                isEditingPassword = true;
                                formChanged = false;
                              });
                              print('✅ DEBUG: Password editing mode enabled');
                            }
                          },
                          child: Text(
                            isEditingPassword ? 'Save' : 'Edit',
                            style: const TextStyle(color: Color(0xFFbad012)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField('Current Password', _currentPasswordController, _obscureCurrentPassword, () {
                      setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                    }),
                    _buildPasswordField('New Password', _newPasswordController, _obscureNewPassword, () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    }),
                    _buildPasswordField('Confirm New Password', _confirmNewPasswordController, _obscureConfirmNewPassword, () {
                      setState(() => _obscureConfirmNewPassword = !_obscureConfirmNewPassword);
                    }),

                    const SizedBox(height: 24),
                    const Text('Notification Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildToggle('Email Notifications', 'Receive updates and alerts via email', emailNotify, (val) => setState(() => emailNotify = val)),
                    _buildToggle('Push Notifications', 'Receive alerts on your device', pushNotify, (val) => setState(() => pushNotify = val)),
                    _buildToggle('SMS Notifications', 'Receive text messages for important updates', smsNotify, (val) => setState(() => smsNotify = val)),
                    _buildToggle('Marketing Communications', 'Receive promotional offers and newsletters', marketingNotify, (val) => setState(() => marketingNotify = val)),

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
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFbad012)),
                    ),
                    const SizedBox(height: 16),
                    Text(loadingText, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          if (errorMessage != null)
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