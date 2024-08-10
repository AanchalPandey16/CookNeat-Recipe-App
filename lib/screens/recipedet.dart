import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class RecipeDetailPage extends StatelessWidget {
  final String recipeName;

  const RecipeDetailPage({Key? key, required this.recipeName}) : super(key: key);

  // Download image from URL and save it to a temporary file
  Future<String?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = Directory.systemTemp;
        final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<void> _shareRecipe() async {
    try {
      // Retrieve recipe data from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('recipe_detail')
          .doc(recipeName)
          .get();

      if (!snapshot.exists) {
        throw Exception('Recipe not found.');
      }

      final recipeData = snapshot.data() as Map<String, dynamic>?;

      if (recipeData == null) {
        throw Exception('Recipe data is null.');
      }

      final imageUrl = recipeData['imageUrl'] ?? '';
 
      // Create a deep link to the recipe in the app
      final recipeLink = 'myapp://recipes/$recipeName';

      String? imagePath;
      if (imageUrl.isNotEmpty) {
        imagePath = await _downloadImage(imageUrl);
      }

      // Prepare text to share
      final shareText = 'Check out this recipe:\n\n'
                        'Recipe Link: $recipeLink';

      // Share image and text
      if (imagePath != null) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
        );
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      print('Error sharing recipe: $e');
    }
  }

  // Function to format ingredients
  String _formatIngredients(String ingredients) {
    return ingredients.split(',').map((ingredient) => ingredient.trim()).join('\n');
  }

  // Function to format steps
  String _formatSteps(String steps) {
    return steps.split('.').map((step) => step.trim()).where((step) => step.isNotEmpty).join('.\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  recipeName,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: Icon(Icons.share, color: const Color.fromARGB(255, 16, 16, 16)),
                    onPressed: _shareRecipe,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('recipe_detail')
                        .doc(recipeName)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(child: Text('Recipe not found.'));
                      }

                      final recipeData = snapshot.data!.data() as Map<String, dynamic>?;

                      if (recipeData == null) {
                        return Center(child: Text('Recipe data is null.'));
                      }

                      final imageUrl = recipeData['imageUrl'] ?? '';
                      final ingredients = recipeData['ingredients'] ?? 'No ingredients available.';
                      final steps = recipeData['steps'] ?? 'No steps available.';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imageUrl.isNotEmpty
                              ? Container(
                                  width: double.infinity,
                                  height: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 6),
                                        blurRadius: 12.0,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 250.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 6),
                                        blurRadius: 12.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(Icons.image, size: 60.0, color: Colors.grey[600]),
                                  ),
                                ),
                          SizedBox(height: 16.0),
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5), // Off-white color
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 4),
                                  blurRadius: 8.0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  _formatIngredients(ingredients),
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5), // Off-white color
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 4),
                                  blurRadius: 8.0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Steps',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  _formatSteps(steps),
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
