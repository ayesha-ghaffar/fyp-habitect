import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary/cloudinary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class _CloudinaryConfig {
  static const String cloudName = 'dftwjyeta';
  static const String apiKey = '421664387565455';
  static const String apiSecret = '90wV8T8oQeWtp893ofbll6oUOD0';
  static const String userProfilesFolder = 'user_profiles';
}

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  late Cloudinary _cloudinary;
  bool _initialized = false;

  // Initialize Cloudinary with credentials
  void initialize() {
    if (_initialized) return;

    _cloudinary = Cloudinary.signedConfig(
      cloudName: _CloudinaryConfig.cloudName,
      apiKey: _CloudinaryConfig.apiKey,
      apiSecret: _CloudinaryConfig.apiSecret,
    );
    _initialized = true;
    print('✅ Cloudinary initialized with cloud: ${_CloudinaryConfig.cloudName}');
  }

  // Upload image file to Cloudinary
  Future<CloudinaryResponse?> uploadImage({
    required File imageFile,
    required String userId,
    String? folder,
  }) async {
    if (!_initialized) initialize();

    try {
      print('🔄 Starting image upload to Cloudinary...');

      // Read file as bytes
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Create unique filename
      String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await _cloudinary.upload(
        fileBytes: imageBytes,
        resourceType: CloudinaryResourceType.image,
        folder: folder ?? _CloudinaryConfig.userProfilesFolder,
        fileName: fileName,
        progressCallback: (count, total) {
          print('📤 Upload progress: ${(count / total * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.isSuccessful) {
        print('✅ Image uploaded successfully!');
        print('🔗 Image URL: ${response.secureUrl}');
        return response;
      } else {
        print('❌ Upload failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Cloudinary using public ID
  Future<bool> deleteImage(String publicId) async {
    if (!_initialized) initialize();

    try {
      print('🗑️ Deleting image with public ID: $publicId');

      final response = await _cloudinary.destroy(publicId);

      if (response.isSuccessful) {
        print('✅ Image deleted successfully!');
        return true;
      } else {
        print('❌ Delete failed: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  // Extract public ID from Cloudinary URL
  String? extractPublicId(String cloudinaryUrl) {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final pathSegments = uri.pathSegments;

      int uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return null;

      String pathAfterVersion = pathSegments.skip(uploadIndex + 2).join('/');

      int lastDot = pathAfterVersion.lastIndexOf('.');
      if (lastDot != -1) {
        pathAfterVersion = pathAfterVersion.substring(0, lastDot);
      }

      return pathAfterVersion;
    } catch (e) {
      print('❌ Error extracting public ID: $e');
      return null;
    }
  }

  // Get optimized image URL with transformations
  String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    try {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments.toList();

      int uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return originalUrl;

      List<String> transformations = [];
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      transformations.add('q_$quality');
      transformations.add('f_$format');
      transformations.add('c_fill');

      String transformationString = transformations.join(',');
      pathSegments.insert(uploadIndex + 1, transformationString);

      return uri.replace(pathSegments: pathSegments).toString();
    } catch (e) {
      print('❌ Error creating optimized URL: $e');
      return originalUrl;
    }
  }
}