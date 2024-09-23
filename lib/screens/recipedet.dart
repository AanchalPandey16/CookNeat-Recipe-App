import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class RecipeDetailPage extends StatefulWidget {
  final String recipeName;
  final String collectionName;
  final String imageUrl;

  const RecipeDetailPage({
    Key? key,
    required this.recipeName,
    required this.imageUrl,
    required this.collectionName,
  }) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool showIngredients = true; // State variable to toggle between ingredients and steps
  Map<String, dynamic>? recipeData;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
    _checkIfFavorited(); // Check if the recipe is already favorited
  }

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.recipeName)
          .get();

      if (snapshot.exists) {
        setState(() {
          recipeData = snapshot.data() as Map<String, dynamic>?;
        });
      } else {
        throw Exception('Recipe not found.');
      }
    } catch (e) {
      print('Error fetching recipe data: $e');
    }
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final favDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .collection('recipes')
          .doc(widget.recipeName)
          .get();

      setState(() {
        isFavorited = favDoc.exists;
      });
    }
  }

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
      if (recipeData == null) {
        throw Exception('Recipe data is null.');
      }

      final imageUrl = recipeData!['imageUrl'] ?? '';
      final recipeLink = 'myapp://recipes/${widget.recipeName}';

      String? imagePath;
      if (imageUrl.isNotEmpty) {
        imagePath = await _downloadImage(imageUrl);
      }

      final shareText = 'Check out this recipe:\n\nRecipe Link: $recipeLink';

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

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final favCollection = FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .collection('recipes');

      if (isFavorited) {
        // Remove recipe from favorites
        await favCollection.doc(widget.recipeName).delete();
      } else {
        // Add recipe to favorites
        await favCollection.doc(widget.recipeName).set({
          'recipeName': widget.recipeName,
          'imageUrl': widget.imageUrl,
          'collectionName': widget.collectionName, // Ensure this field is added
        });
      }

      setState(() {
        isFavorited = !isFavorited;
      });
    }
  }

  String _formatIngredients(String ingredients) {
    return ingredients.split(',').map((ingredient) => ingredient.trim()).join('\n');
  }

  String _formatSteps(String steps) {
    return steps.split('.').map((step) => step.trim()).where((step) => step.isNotEmpty).join('.\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: recipeData == null
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[200]!)))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                recipeData!['imageUrl'].isNotEmpty
                                    ? Container(
                                        width: double.infinity,
                                        height: 300.0,
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
                                            recipeData!['imageUrl'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 300.0,
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
                                Positioned(
                                  top: 30.0,
                                  left: 10.0,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.recipeName,
                                          style: TextStyle(
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isFavorited ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorited ? Colors.orange.shade600 : Colors.black, size: 29,
                                            ),
                                            onPressed: _toggleFavorite,
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.share),
                                            onPressed: _shareRecipe,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            showIngredients = true;
                                          });
                                        },
                                        child: Text(
                                          'Ingredients',
                                          style: TextStyle(
                                            color: showIngredients ? Colors.orange.shade700 : Colors.black,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            showIngredients = false;
                                          });
                                        },
                                        child: Text(
                                          'Steps',
                                          style: TextStyle(
                                            color: !showIngredients ? Colors.orange.shade700 : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1),
                                  SizedBox(height: 16.0),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          offset: Offset(0, 4),
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          showIngredients ? 'Ingredients' : 'Steps',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Divider(
                                          color: Colors.orange.shade200,
                                          thickness: 1.5,
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          showIngredients
                                              ? _formatIngredients(recipeData!['ingredients'] ?? 'No ingredients available.')
                                              : _formatSteps(recipeData!['steps'] ?? 'No steps available.'),
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
