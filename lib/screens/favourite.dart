import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cook_n_eat/screens/recipedet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final favDocs = await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid)
            .collection('recipes')
            .get();

        setState(() {
          _favoriteRecipes = favDocs.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
              ? Center(child: Text('No favorites found'))
              : ListView.builder(
                  itemCount: _favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _favoriteRecipes[index];
                    final recipeName = recipe['recipeName'] ?? 'No name';
                    final imageUrl = recipe['imageUrl'] ?? '';
                    final ingredients = recipe['ingredients'] ?? 'No ingredients';
                    final steps = recipe['steps'] ?? 'No steps';
                    final collectionName = recipe['collectionName'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(
                              recipeName: recipeName,
                              imageUrl: imageUrl,
                              collectionName: collectionName,
                              // Pass the ingredients and steps if available
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                        child: Stack(
                          children: [
                            imageUrl.isNotEmpty
                                ? Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.image, size: 100.0, color: Colors.grey[600]),
                                    ),
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  recipeName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
