import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio_model.dart';

class PortfolioViewModel extends ChangeNotifier {
  // Private fields
  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;

  // Firebase instances
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get hasProfile => _profile != null;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set saving state
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load portfolio from Firebase (without images)
  Future<void> loadPortfolio() async {
    if (currentUserId == null) {
      _setError('User not authenticated');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final snapshot = await _database.child('portfolios').child(currentUserId!).get();

      if (!snapshot.exists) {
        _profile = null;
        _setLoading(false);
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // Parse certifications
      List<CertificationItem> certifications = [];
      if (data['certifications'] != null) {
        final certsData = List<Map<String, dynamic>>.from(data['certifications']);
        certifications = certsData
            .map((cert) => CertificationItem(
          title: cert['title'] ?? '',
          year: cert['year'] ?? '',
        ))
            .toList();
      }

      // Parse projects (without images)
      List<ProjectItem> projects = [];
      if (data['projects'] != null) {
        final projectsData = List<Map<String, dynamic>>.from(data['projects']);
        projects = projectsData
            .map((project) => ProjectItem(
          title: project['title'] ?? '',
          description: project['description'] ?? '',
          completionDate: project['completionDate'] ?? '',
          // No imageUrl for now
        ))
            .toList();
      }

      _profile = Profile(
        name: data['name'] ?? '',
        location: data['location'] ?? '',
        bio: data['bio'] ?? '',
        specialty: data['specialty'] ?? '',
        certifications: certifications,
        projects: projects,
      );

    } catch (e) {
      _setError('Error loading portfolio: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save portfolio to Firebase (without images)
  Future<bool> savePortfolio(Profile profile) async {
    if (currentUserId == null) {
      _setError('User not authenticated');
      return false;
    }

    _setSaving(true);
    _setError(null);

    try {
      // Prepare project data (without uploading images)
      List<Map<String, dynamic>> projectsData = [];
      for (final project in profile.projects) {
        projectsData.add({
          'title': project.title,
          'description': project.description,
          'completionDate': project.completionDate,
          // Skip imageUrl for now
        });
      }

      // Prepare certifications data
      List<Map<String, dynamic>> certificationsData = profile.certifications
          .map((cert) => {
        'title': cert.title,
        'year': cert.year,
      })
          .toList();

      // Prepare portfolio data (without images)
      Map<String, dynamic> portfolioData = {
        'name': profile.name,
        'location': profile.location,
        'bio': profile.bio,
        'specialty': profile.specialty,
        'projects': projectsData,
        'certifications': certificationsData,
        'lastUpdated': ServerValue.timestamp,
      };

      // Save to Firebase under portfolios/{architectId}
      await _database.child('portfolios').child(currentUserId!).set(portfolioData);

      // Also update user role and portfolio reference in users collection
      await _database.child('users').child(currentUserId!).update({
        'role': 'architect',
        'portfolio': 'portfolios/$currentUserId',
        'name': profile.name,
      });

      // Update local profile
      _profile = profile;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Error saving portfolio: $e');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // Update profile locally (for immediate UI updates)
  void updateProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  // Create default profile
  Profile createDefaultProfile() {
    return Profile(
      name: '',
      location: '',
      bio: '',
      specialty: '',
      certifications: [],
      projects: [],
    );
  }

  // Listen to portfolio changes in real-time
  void listenToPortfolioChanges() {
    if (currentUserId == null) return;

    _database.child('portfolios').child(currentUserId!).onValue.listen((event) {
      if (event.snapshot.exists) {
        // Update portfolio when data changes in Firebase
        loadPortfolio();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}