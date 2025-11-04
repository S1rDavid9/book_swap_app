import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Upload book cover image
  Future<String> uploadBookCover(File imageFile) async {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      // Generate unique filename
      final String fileName = '${const Uuid().v4()}.jpg';
      final String filePath = '${AppConstants.bookCoversPath}/$currentUserId/$fileName';

      // Upload file
      final Reference storageRef = _storage.ref().child(filePath);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Error uploading image: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Delete book cover image
  Future<void> deleteBookCover(String imageUrl) async {
    try {
      // Extract path from URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      
      // Delete file
      await storageRef.delete();
    } on FirebaseException catch (e) {
      // If file doesn't exist, just log and continue
      if (e.code == 'object-not-found') {
        return;
      }
      throw Exception('Error deleting image: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      // Generate unique filename
      final String fileName = '${const Uuid().v4()}.jpg';
      final String filePath = '${AppConstants.profilePicturesPath}/$currentUserId/$fileName';

      // Upload file
      final Reference storageRef = _storage.ref().child(filePath);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Error uploading profile picture: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      // Extract path from URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      
      // Delete file
      await storageRef.delete();
    } on FirebaseException catch (e) {
      // If file doesn't exist, just log and continue
      if (e.code == 'object-not-found') {
        return;
      }
      throw Exception('Error deleting profile picture: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting profile picture: $e');
    }
  }

  // Delete all user's files (called when deleting account)
  Future<void> deleteAllUserFiles() async {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      // Delete book covers
      final bookCoversRef = _storage.ref().child('${AppConstants.bookCoversPath}/$currentUserId');
      try {
        final ListResult bookCovers = await bookCoversRef.listAll();
        for (Reference ref in bookCovers.items) {
          await ref.delete();
        }
      } catch (e) {
        // Directory might not exist, continue
      }

      // Delete profile pictures
      final profilePicsRef = _storage.ref().child('${AppConstants.profilePicturesPath}/$currentUserId');
      try {
        final ListResult profilePics = await profilePicsRef.listAll();
        for (Reference ref in profilePics.items) {
          await ref.delete();
        }
      } catch (e) {
        // Directory might not exist, continue
      }
    } catch (e) {
      throw Exception('Error deleting user files: $e');
    }
  }
}