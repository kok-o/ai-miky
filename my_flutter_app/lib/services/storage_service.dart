import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile photo - uses Uint8List for all platforms
  Future<String?> uploadProfilePhoto(String userId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('profile_photos').child('$userId.jpg');
      await ref.putData(imageBytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos').child('$userId.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting profile photo: $e');
    }
  }
}
