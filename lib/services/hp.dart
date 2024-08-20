import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchRecipesByCategory(String category) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot querySnapshot = await firestore
        .collection('hp_recipe')
        .where('category', isEqualTo: category)
        .get();

    List<Map<String, dynamic>> recipes = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return recipes;
  } catch (e) {
    print('Error fetching recipes: $e');
    return [];
  }
}
