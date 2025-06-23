import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // Untuk web, konversi gambar ke base64 data URL
          final Uint8List bytes = await image.readAsBytes();
          final String base64String = base64Encode(bytes);
          return 'data:image/jpeg;base64,$base64String';
        } else {
          return await _saveImageToLocal(image);
        }
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // Untuk web, konversi gambar ke base64 data URL
          final Uint8List bytes = await image.readAsBytes();
          final String base64String = base64Encode(bytes);
          return 'data:image/jpeg;base64,$base64String';
        } else {
          return await _saveImageToLocal(image);
        }
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Save image to local storage
  Future<String?> _saveImageToLocal(XFile image) async {
    try {
      if (kIsWeb) {
        // Untuk web, konversi ke base64 data URL
        final Uint8List bytes = await image.readAsBytes();
        final String base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      }

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      // Create images directory if it doesn't exist
      final String imagesDir = path.join(appDocPath, 'images');
      await Directory(imagesDir).create(recursive: true);

      // Generate unique filename
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = path.join(imagesDir, fileName);

      // Copy file to local storage
      await File(image.path).copy(savedPath);

      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Delete image from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // For web, we can't delete files in the same way
        // Just return true as cleanup isn't necessary
        return true;
      }

      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Check if image exists
  Future<bool> imageExists(String imagePath) async {
    try {
      if (kIsWeb) {
        // For web, assume image exists if path is not empty
        return imagePath.isNotEmpty;
      }

      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      print('Error checking image existence: $e');
      return false;
    }
  }
}
