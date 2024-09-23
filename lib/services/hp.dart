import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getRecipe(String recipeId) async {
    try {
      DocumentSnapshot doc = await _db.collection('hp_recipe').doc(recipeId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error getting recipe: $e");
    }
    return null;
  }

  Future<void> saveRecipeNameByName(String oldRecipeName, String newRecipeName) async {
    try {
      // Query to find the document with the old recipe name
      QuerySnapshot querySnapshot = await _db.collection('hp_recipe')
          .where('name', isEqualTo: oldRecipeName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the recipe name for each matching document
        for (DocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.update({
            'name': newRecipeName,
          });
          print("Recipe name updated successfully.");
        }
      } else {
        print("No recipe found with the name: $oldRecipeName");
      }
    } catch (e) {
      print("Error updating recipe name: $e");
    }
  }
}
