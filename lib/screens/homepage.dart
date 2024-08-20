import 'package:cook_n_eat/screens/recipedetail.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All'; // Default category
  List<Map<String, dynamic>> _recipes = []; // Placeholder for recipes

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Fetch recipes for default category
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchRecipes();
    });
  }

  void _fetchRecipes() {
    // This is where you'd normally fetch recipes from a database.
    // For this example, it's just an empty function.
    setState(() {
      _recipes = []; // Replace with actual data fetching logic
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Hello Foodie,\nWant to make your\nfavourite meal?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      "assets/recipe.png",
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search bar
              Container(
                height: 80,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    hintStyle: TextStyle(fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.orange[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                  onChanged: (query) {
                    // Implement search functionality here if needed
                  },
                ),
              ),
              Divider(
                thickness: 2,
              ),

              const SizedBox(height: 10),

              // Category buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton("All", Icons.all_inbox),
                    _buildCategoryButton("Vegetarian", Icons.eco),
                    _buildCategoryButton("Snack", Icons.fastfood),
                    _buildCategoryButton("Chutneys", Icons.soup_kitchen),
                    _buildCategoryButton("Desserts", Icons.cake),
                    _buildCategoryButton("Beverages", Icons.local_drink),
                  ],
                ),
              ),

              const SizedBox(height: 10), 
              Divider(
                thickness: 2,
              ),

              const SizedBox(height: 20),

              // Display recipes
              _recipes.isEmpty
                  ? Center(child: Text('No recipes found.'))
                  : Column(
                      children: _recipes.map((recipe) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 200, // Height of the image container
                                  child: recipe['imageUrl'] != null
                                      ? Image.network(
                                          recipe['imageUrl'],
                                          fit: BoxFit.cover,
                                        )
                                      : Container(color: Colors.grey[300]), // Fallback color
                                ),
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: double.infinity, // Ensures it stretches to the full width
                                    padding: EdgeInsets.all(8.0),
                                    color: Colors.black.withOpacity(0.5), // Transparent line
                                    child: Text(
                                      recipe['name'] ?? 'No Name',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis, 
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetail(recipe: recipe),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton.icon(
        onPressed: () {
          _onCategorySelected(title);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: Colors.black,
        ),
        label: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
