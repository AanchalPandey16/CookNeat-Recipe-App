import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cook_n_eat/screens/recipedet.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: Duration(seconds: 0),
      maxNrOfCacheObjects: 100,
    ),
  );

  final String collectionName = 'hp_recipe';

  List<Map<String, dynamic>> _cachedRecipes = [];

  bool _isDataFetched = false;

  Future<void> _fetchRecipes() async {
    try {
      if (!_isDataFetched) {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection(collectionName).get();
        setState(() {
          _cachedRecipes = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          _isDataFetched = true;
        });
        print("Fetched from $collectionName: $_cachedRecipes");
      }
    } catch (e) {
      print("Error fetching recipes from $collectionName: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Hey Foodie!\nCraving your favorite dish?\nLet’s cook up something delicious!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      "assets/recipe.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search recipes...',
                  hintStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.orange[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Colors.orange[200]!, width: 2.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                ),
                onChanged: (text) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton("All", Icons.all_inbox),
                    _buildCategoryButton("Vegetarian", Icons.eco),
                    _buildCategoryButton("Chutneys", Icons.soup_kitchen),
                    _buildCategoryButton("Desserts", Icons.cake),
                    _buildCategoryButton("Beverages", Icons.local_drink),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Best Picks:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              _cachedRecipes.isEmpty
                  ? Center(
                      child: Text(
                        'loading...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : _buildRecipeList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    var filteredByCategory = _cachedRecipes.where((recipe) {
      if (_selectedCategory == 'All') {
        return true;
      }
      return recipe['category'] == _selectedCategory;
    }).toList();

    var searchQuery = _searchController.text.toLowerCase();
    var filteredBySearch = filteredByCategory.where((recipe) {
      var name = recipe['name']?.toLowerCase() ?? '';
      return name.contains(searchQuery);
    }).toList();

    if (filteredBySearch.isEmpty) {
      return Center(child: Text('No recipes found.'));
    }

    return Column(
      children: filteredBySearch.map((recipe) {
        return GestureDetector(
          onTap: () {
            if (recipe['imageUrl'] != null && recipe['imageUrl'].isNotEmpty) {
              precacheImage(
                CachedNetworkImageProvider(recipe['imageUrl']),
                context,
              ).then((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      recipeName: recipe['name'] ?? 'No Name',
                      imageUrl: recipe['imageUrl'] ?? '',
                      collectionName: collectionName,
                    ),
                  ),
                );
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(
                    recipeName: recipe['name'] ?? 'No Name',
                    imageUrl: recipe['imageUrl'] ?? '',
                    collectionName: collectionName,
                  ),
                ),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 226,
                    child: CachedNetworkImage(
                      imageUrl: recipe['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      cacheManager: customCacheManager,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange[200]!),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        recipe['name'] ?? 'No Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryButton(String category, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: _selectedCategory == category
              ? Colors.orange[400]
              : Colors.orange[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Text(category),
          ],
        ),
      ),
    );
  }
}
