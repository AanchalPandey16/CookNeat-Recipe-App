import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class RecipeList extends StatefulWidget {
  @override
  _RecipeListState createState() => _RecipeListState();
}
class _RecipeListState extends State<RecipeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isAdding = false; 

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _addRecipe() async {
    if (_isAdding) return; // Prevent multiple clicks

    setState(() {
      _isAdding = true; // Set to true to disable button
    });

    try {
      // Simulate a long process
      await Future.delayed(Duration(seconds: 2));

      // Add your recipe adding logic here

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add recipe')),
      );
    } finally {
      setState(() {
        _isAdding = false; // Reset to allow further actions
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
                        border: InputBorder.none,
                      ),
                    )
                  : Text('My Recipes'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('recipes')
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange[600], // Orange shade 600
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No recipes found.'));
                  }

                  final recipes = snapshot.data!.docs
                      .where((doc) {
                        final recipe = doc.data() as Map<String, dynamic>;
                        final name = recipe['name']?.toLowerCase() ?? '';
                        return name.contains(_searchQuery);
                      })
                      .toList();

                  if (recipes.isEmpty) {
                    return Center(child: Text('No results found.'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index].data() as Map<String, dynamic>;

                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 8),
                              blurRadius: 16.0,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(recipe: recipe),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              if (recipe['image'] != null)
                                CachedNetworkImage(
                                  imageUrl: recipe['image'],
                                  height: 190,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.orange[600], // Orange shade 600
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 190,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  child: Text(
                                    recipe['name'] ?? 'No Name',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RecipeDetail extends StatefulWidget {
  final Map<String, dynamic> recipe;

  RecipeDetail({required this.recipe});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  bool _showIngredients = true;

  @override
  void initState() {
    super.initState();
    _ingredientsController = TextEditingController(text: widget.recipe['ingredients']);
    _stepsController = TextEditingController(text: widget.recipe['steps']);
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final recipeName = widget.recipe['name'];
        if (recipeName != null && recipeName.isNotEmpty) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('recipes')
              .where('name', isEqualTo: recipeName)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              await doc.reference.delete();
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recipe deleted successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recipe not found')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid Recipe Name')),
          );
        }
      } catch (e) {
        print('Error deleting recipe: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete recipe')),
        );
      }
    }
  }

  Future<void> _editRecipe() async {
    final recipeName = widget.recipe['name'];
    if (recipeName != null && recipeName.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('recipes')
            .where('name', isEqualTo: recipeName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            await doc.reference.update({
              'ingredients': _ingredientsController.text,
              'steps': _stepsController.text,
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recipe updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recipe not found')),
          );
        }
      } catch (e) {
        print('Error updating recipe: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update recipe')),
        );
      }
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
      if (widget.recipe['image'] == null) {
        throw Exception('Recipe image is null.');
      }

      final imageUrl = widget.recipe['image'];
      final recipeLink = 'myapp://recipes/${widget.recipe['name']}';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          widget.recipe['image'] != null
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
                                      widget.recipe['image'],
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
                                    widget.recipe['name'] ?? 'Recipe Name',
                                    style: TextStyle(
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                      _showIngredients = true;
                                    });
                                  },
                                  child: Text(
                                    'Ingredients',
                                    style: TextStyle(
                                      color: _showIngredients ? Colors.orange.shade700 : Colors.black,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showIngredients = false;
                                    });
                                  },
                                  child: Text(
                                    'Steps',
                                    style: TextStyle(
                                      color: !_showIngredients ? Colors.orange.shade700 : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(thickness: 1),
                            SizedBox(height: 16.0),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                                    _showIngredients ? 'Ingredients' : 'Steps',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  Divider(color: Colors.orange,),
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _showIngredients ? _ingredientsController : _stepsController,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _editRecipe,
                      style: ElevatedButton.styleFrom(
                      
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 18.0)),
                    ),
                    ElevatedButton(
                      onPressed: () => _deleteRecipe(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
                      ),
                      child: Text('Delete', style: TextStyle(fontSize: 18.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
