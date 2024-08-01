import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addRecipe(Map<String, dynamic> addRecipe) async {
    try {
      await FirebaseFirestore.instance.collection("Recipe").add(addRecipe);
    } catch (e) {
      print(e.toString());
    }
  }
}

