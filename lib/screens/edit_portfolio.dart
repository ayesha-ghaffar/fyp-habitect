import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'svg_icon.dart';
import 'package:fyp/models/portfolio_model.dart';

class EditPortfolioPage extends StatefulWidget {
  final Profile profile;
  final Function(Profile) onSave;

  const EditPortfolioPage({
    Key? key,
    required this.profile,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditPortfolioPageState createState() => _EditPortfolioPageState();
}

class _EditPortfolioPageState extends State<EditPortfolioPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late String _specialty;
  File? _profileImage;
  File? _coverImage;
  late List<CertificationItem> _certifications;
  late List<ProjectItem> _projects;
  bool _isToastVisible = false;
  String _toastMessage = "";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _locationController = TextEditingController(text: widget.profile.location);
    _bioController = TextEditingController(text: widget.profile.bio);
    _specialty = widget.profile.specialty;
    _profileImage = widget.profile.profileImage;
    _coverImage = widget.profile.coverImage;

    // Deep copy the lists to avoid modifying the original lists
    _certifications = widget.profile.certifications.map((cert) =>
        CertificationItem(title: cert.title, year: cert.year)).toList();

    _projects = widget.profile.projects.map((proj) =>
        ProjectItem(
          title: proj.title,
          description: proj.description,
          completionDate: proj.completionDate,
          imageUrl: proj.imageUrl,
          isLocalImage: proj.isLocalImage,
        )).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    setState(() {
      _toastMessage = message;
      _isToastVisible = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isToastVisible = false;
        });
      }
    });
  }

  Future<void> _pickImage(ImageSource source, {bool forCover = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          if (forCover) {
            _coverImage = File(image.path);
          } else {
            _profileImage = File(image.path);
          }
        });
      }
    } catch (e) {
      _showToast("Error picking image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, {required Function(String) onDateSelected}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B8E23),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedDate = DateFormat('yyyy').format(picked);
      onDateSelected(formattedDate);
    }
  }

  Future<void> _selectFullDate(BuildContext context, ProjectItem project) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B8E23),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Just update the model
        project.completionDate = DateFormat('MMMM yyyy').format(picked);
      });
    }
  }

  void _addCertification() {
    setState(() {
      _certifications.add(CertificationItem(title: "", year: ""));
    });
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  void _addProject() {
    setState(() {
      _projects.add(ProjectItem(
        title: "",
        description: "",
        completionDate: "",
        imageUrl: "assets/images/placeholder.jpg",
      ));
    });
  }

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
    });
  }

  void _savePortfolio() {
    // Validate form
    if (_nameController.text.isEmpty) {
      _showToast("Please enter your name");
      return;
    }
    if (_specialty.isEmpty) {
      _showToast("Please select your specialty");
      return;
    }
    if (_locationController.text.isEmpty) {
      _showToast("Please enter your location");
      return;
    }
    if (_bioController.text.isEmpty) {
      _showToast("Please enter your professional bio");
      return;
    }

    // Create updated profile
    final updatedProfile = Profile(
      name: _nameController.text,
      location: _locationController.text,
      bio: _bioController.text,
      specialty: _specialty,
      profileImage: _profileImage,
      coverImage: _coverImage,
      certifications: _certifications,
      projects: _projects,
    );

    // Call the onSave callback with the updated profile
    widget.onSave(updatedProfile);

    // Close the edit page
    Navigator.of(context).pop();
  }

  Widget _buildCertificationItem(int index) {
    final certification = _certifications[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: certification.title),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Certification/Award Title",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixIcon: Icon(Icons.edit, color: Colors.grey, size: 16),
                  ),
                  onChanged: (value) {
                    certification.title = value;
                  },
                ),
              ),
              IconButton(
                onPressed: () => _removeCertification(index),
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context, onDateSelected: (date) {
                  setState(() {
                    certification.year = date;
                  });
                }),
                child: SvgIcon(iconName: 'calendar', size: 14, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: certification.year),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Year",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    certification.year = value;
                  },
                  readOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(int index) {
    final project = _projects[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image
          GestureDetector(
            onTap: () async {
              try {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    project.imageUrl = pickedFile.path;
                    project.isLocalImage = true;
                  });
                }
              } catch (e) {
                _showToast("Error picking image: $e");
              }
            },
            child: Container(
              height: 192,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Stack(
                children: [
                  if (project.isLocalImage && project.imageUrl?.isNotEmpty == true)
                    Image.file(
                      File(project.imageUrl!),
                      height: 192,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else if (project.imageUrl?.isNotEmpty == true)
                    Image.asset(
                      project.imageUrl!,
                      height: 192,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                        );
                      },
                    ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Project Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Title
                TextField(
                  controller: TextEditingController(text: project.title),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Project Title",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixIcon: Icon(Icons.edit, color: Colors.grey, size: 16),
                  ),
                  onChanged: (value) {
                    project.title = value;
                  },
                ),
                const SizedBox(height: 8),

                // Project Description
                TextField(
                  controller: TextEditingController(text: project.description),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Project Description",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixIcon: Icon(Icons.edit, color: Colors.grey, size: 16),
                  ),
                  onChanged: (value) {
                    project.description = value;
                  },
                ),
                const SizedBox(height: 8),

                // Completion Date
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _selectFullDate(context, project),
                      child: SvgIcon(iconName: 'calendar', size: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: project.completionDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        decoration: const InputDecoration(
                          hintText: "Completion Date",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (value) {
                          project.completionDate = value;
                        },
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Project Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _removeProject(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                  label: const Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgIcon(iconName: 'close', color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Portfolio",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _savePortfolio,
            child: const Text(
              "Save",
              style: TextStyle(
                color: Color(0xFF6B8E23),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Section
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery, forCover: true),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: Stack(
                  children: [
                    if (_coverImage != null)
                      Image.file(
                        _coverImage!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    else
                      Center(
                        child: Image.asset(
                          "assets/images/cover_placeholder.jpg",
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                            );
                          },
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add Cover Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Profile Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),

            // Profile section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile image
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6B8E23), width: 2),
                      ),
                      child: Stack(
                        children: [
                          // Base profile image or empty container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: _profileImage != null
                                ? Image.file(
                              _profileImage!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 96,
                              height: 96,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          // Camera overlay for selection
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(48),
                                onTap: () async {
                                  // Image picker functionality
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                                  if (pickedFile != null) {
                                    setState(() {
                                      _profileImage = File(pickedFile.path);
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: Icon(Icons.edit, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Specialty
                  DropdownButtonFormField<String>(
                    value: _specialty,
                    decoration: const InputDecoration(
                      labelText: "Specialty",
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: [
                      DropdownMenuItem(value: "residential", child: Text("Residential Architecture")),
                      DropdownMenuItem(value: "commercial", child: Text("Commercial Architecture")),
                      DropdownMenuItem(value: "interior", child: Text("Interior Design")),
                      DropdownMenuItem(value: "landscape", child: Text("Landscape Architecture")),
                      DropdownMenuItem(value: "urban", child: Text("Urban Planning")),
                      DropdownMenuItem(value: "industrial", child: Text("Industrial Architecture")),
                      DropdownMenuItem(value: "sustainable", child: Text("Sustainable Design")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _specialty = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: Icon(Icons.location_on_rounded, color: Color(0xFF6B8E23)),
                      suffixIcon: Icon(Icons.edit, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            // Bio Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Professional Bio",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Text(
                        "${_bioController.text.length}/500",
                        style: TextStyle(
                          fontSize: 12,
                          color: _bioController.text.length > 500 ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: "Write a brief description about your professional background, approach, and expertise...",
                      filled: true,
                      fillColor: Color(0xFFF9F9F7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.all(16),
                      counterText: "",
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // Certifications Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Certifications & Awards",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addCertification,
                        icon: const Icon(Icons.add, color: Color(0xFF6B8E23), size: 16),
                        label: const Text(
                          "Add",
                          style: TextStyle(
                            color: Color(0xFF6B8E23),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _certifications.length,
                    itemBuilder: (context, index) {
                      return _buildCertificationItem(index);
                    },
                  ),
                ],
              ),
            ),

            // Portfolio Projects Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Portfolio Projects",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addProject,
                        icon: const Icon(Icons.add, color: Color(0xFF6B8E23), size: 16),
                        label: const Text(
                          "Add Project",
                          style: TextStyle(
                            color: Color(0xFF6B8E23),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectItem(index);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _isToastVisible
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _toastMessage,
          style: const TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }
}