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

  // Helper method to safely convert Firebase data to Map<String, dynamic>
  Map<String, dynamic> _convertToStringMap(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      // Convert Map<Object?, Object?> to Map<String, dynamic>
      return data.map((key, value) => MapEntry(key.toString(), value));
    }

    return {};
  }

  // Helper method to safely get string value
  String _getString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    return value?.toString() ?? defaultValue;
  }

  // Helper method to safely get list
  List<T> _getList<T>(Map<String, dynamic> data, String key, T Function(Map<String, dynamic>) fromMap) {
    final value = data[key];
    if (value == null) return <T>[];

    if (value is List) {
      return value.map((item) {
        if (item is Map) {
          return fromMap(_convertToStringMap(item));
        }
        return fromMap(<String, dynamic>{});
      }).toList();
    }

    return <T>[];
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

      // Safely convert Firebase data
      final data = _convertToStringMap(snapshot.value);

      // Parse certifications with safe type handling
      List<CertificationItem> certifications = _getList<CertificationItem>(
        data,
        'certifications',
            (certData) => CertificationItem(
          title: _getString(certData, 'title'),
          year: _getString(certData, 'year'),
        ),
      );

      // Parse projects with safe type handling
      List<ProjectItem> projects = _getList<ProjectItem>(
        data,
        'projects',
            (projectData) => ProjectItem(
          title: _getString(projectData, 'title'),
          description: _getString(projectData, 'description'),
          completionDate: _getString(projectData, 'completionDate'),
          imageUrl: _getString(projectData, 'imageUrl'),
          isLocalImage: projectData['isLocalImage'] == true,
        ),
      );

      _profile = Profile(
        name: _getString(data, 'name'),
        location: _getString(data, 'location'),
        bio: _getString(data, 'bio'),
        specialty: _getString(data, 'specialty', 'modern'),
        certifications: certifications,
        projects: projects,
      );

    } catch (e) {
      _setError('Error loading portfolio: $e');
      print('Portfolio loading error: $e'); // For debugging
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
          'imageUrl': project.imageUrl ?? '',
          'isLocalImage': project.isLocalImage,
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
      print('Portfolio saving error: $e'); // For debugging
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
      specialty: 'modern',
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