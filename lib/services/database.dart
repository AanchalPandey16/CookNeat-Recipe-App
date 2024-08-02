import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    await _firestore.collection('recipes').add(recipeData);
  }

  Stream<QuerySnapshot> getUserRecipes(String userId) {
    return _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
