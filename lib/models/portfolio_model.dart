import 'dart:io';

class Profile {
  String name;
  String location;
  String bio;
  String specialty;
  File? profileImage;
  File? coverImage;
  List<CertificationItem> certifications;
  List<ProjectItem> projects;

  Profile({
    required this.name,
    required this.location,
    required this.bio,
    required this.specialty,
    this.profileImage,
    this.coverImage,
    required this.certifications,
    required this.projects,
  });

  // Create a copy of the profile with potentially new values
  Profile copyWith({
    String? name,
    String? location,
    String? bio,
    String? specialty,
    File? profileImage,
    File? coverImage,
    List<CertificationItem>? certifications,
    List<ProjectItem>? projects,
  }) {
    return Profile(
      name: name ?? this.name,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      specialty: specialty ?? this.specialty,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      certifications: certifications ?? this.certifications,
      projects: projects ?? this.projects,
    );
  }
}

class CertificationItem {
  String title;
  String year;

  CertificationItem({
    required this.title,
    required this.year,
  });
}

class ProjectItem {
  String title;
  String description;
  String completionDate;
  String? imageUrl;
  bool isLocalImage;

  ProjectItem({
    required this.title,
    required this.description,
    required this.completionDate,
    this.imageUrl,
    this.isLocalImage = false,
  });
}