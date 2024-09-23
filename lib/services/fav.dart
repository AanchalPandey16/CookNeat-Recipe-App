import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> getFavoriteRecipes() async {
    if (user == null) {
      print('No user logged in.');
      return [];
    }

    final userId = user!.uid;
    try {
      final querySnapshot = await _db
          .collection('favorites')
          .doc(userId)
          .collection('recipes')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No favorite recipes found.');
        return [];
      }

      final favoriteRecipes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Document data: $data'); // Debugging line
        return data;
      }).toList();

      print('Favorite recipes retrieved: $favoriteRecipes');
      return favoriteRecipes;
    } catch (e) {
      print('Error retrieving favorite recipes: $e');
      return [];
    }
  }
}