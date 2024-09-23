import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProfileData extends GetxController {
  static ProfileData get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch user profile data by userId
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      DocumentSnapshot snapshot = await _db.collection('profiles').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>? ?? {}; // Ensure a default empty map
      } else {
        throw Exception('Profile not found');
      }
    } catch (e) {
      throw Exception('Error fetching profile: ${e.toString()}');
    }
  }

  // Create or update user profile data
  Future<void> createOrUpdateProfile(String userId, {required String username, required String bio, String? imageUrl}) async {
    // Input validation
    if (username.isEmpty || bio.isEmpty) {
      throw Exception('Username and bio cannot be empty');
    }

    try {
      await _db.collection('profiles').doc(userId).set({
        'username': username,
        'bio': bio,
        'profileImage': imageUrl ?? '', // Optional field
      }, SetOptions(merge: true)); // Use merge to update only specified fields
    } catch (e) {
      throw Exception('Error creating or updating profile: ${e.toString()}');
    }
  }
}
