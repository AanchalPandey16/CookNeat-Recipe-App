// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<Map<String, dynamic>> getRecipe(String recipeId) async {
    DocumentSnapshot snapshot = await _db.collection('recipes').doc(recipeId).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Recipe not found');
    }
  }

  
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    QuerySnapshot snapshot = await _db.collection('recipes').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}


