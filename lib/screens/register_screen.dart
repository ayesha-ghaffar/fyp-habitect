import 'dart:io';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _userType = 'client';
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;
  File? _profileImage;

  bool validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
    return regex.hasMatch(password);
  }

  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 3) {
      return '$fieldName must be at least 3 characters';
    }
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName cannot contain only numbers';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return 'Username cannot contain only numbers';
    }
    return null;
  }

  // Simple phone number validation
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!value.startsWith('+92') ||
        !RegExp(r'^\+923\d{9}$').hasMatch(value)) {
      return 'Enter a valid Pakistani phone number (e.g., +923xxxxxxxxx)';
    }
    return null;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  void register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select your date of birth")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      AppUser user = AppUser(
        uid: '',
        name: fullName,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _selectedDate!,
        gender: Gender.other,
        avatarUrl: '',
        notifications: NotificationPreferences(email: true, push: true, sms: false, marketing: false),
        role: _userType,
      );

      String? result = await _authService.registerUser(user, _passwordController.text.trim());

      setState(() {
        _isLoading = false;
      });

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _errorMessage = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabiTect', style: TextStyle(color: Colors.black54, fontSize: 14)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register Account', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey) : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text('Register as', style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 12),
              _buildUserTypeTile('architect', 'Register as Architect'),
              const SizedBox(height: 8),
              _buildUserTypeTile('client', 'Register as Client', highlight: true),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildTextField('First Name', _firstNameController, validator: (val) => validateName(val, 'First Name'))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Last Name', _lastNameController, validator: (val) => validateName(val, 'Last Name'))),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField('Username',
                  _usernameController,
                  prefixIcon: Icons.person_outline,
                  validator: validateUsername),
              const SizedBox(height: 16),

              _buildTextField(
                  'Email', _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!EmailValidator.validate(val)) return 'Enter valid email format';

                    String localPart = val.split('@')[0];
                    if (localPart.length < 3) return 'Username part must be at least 3 characters';

                    // Check if local part contains only numbers
                    if (RegExp(r'^\d+$').hasMatch(localPart)) return 'Username cannot contain only numbers';

                    return null;
                  }),
              const SizedBox(height: 16),

              _buildTextField(
                'Phone Number',
                _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hintText: '+[Country Code][Number]',
                validator: validatePhoneNumber,
              ),
              const SizedBox(height: 16),

              const Text('Date of Birth', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select your date of birth',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Date of birth is required' : null,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              const Text('Password', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Create a password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                validator: (val) => val != null && validatePassword(val)
                    ? null
                    : 'Min 6 chars, 1 digit, 1 uppercase',
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFbad012),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.black54)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Login', style: TextStyle(color: Color(0xFF4A6FFF), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeTile(String value, String label, {bool highlight = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: highlight && _userType == value ? const Color(0xFFEDF2FF) : null,
      ),
      child: RadioListTile<String>(
        title: Text(label),
        value: value,
        groupValue: _userType,
        onChanged: (val) => setState(() => _userType = val!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        activeColor: const Color(0xFFbad012),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? prefixIcon, TextInputType keyboardType = TextInputType.text, String? hintText, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ?? (val) => val == null || val.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}