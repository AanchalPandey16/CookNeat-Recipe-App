import 'package:cook_n_eat/screens/recipedetail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cook_n_eat/screens/add_recipe.dart';
import 'package:cook_n_eat/screens/menu.dart';
import 'package:cook_n_eat/screens/profilepage.dart';
import 'package:cook_n_eat/screens/hp_recipes.dart'; // Updated import

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<String> imagePaths = [
    'assets/paneer.jpg',
    'assets/naan.jpeg',
    'assets/bundiraita.jpeg',
  ];

  final List<String> names = [
    'Kadhai Paneer',
    'Butter Naan',
    'Bundi Raita',
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchRecipe(String name) async {
    try {
      final recipeSnapshot = await FirebaseFirestore.instance
          .collection('hp_recipe')
          .where('name', isEqualTo: name)
          .get();

      if (recipeSnapshot.docs.isNotEmpty) {
        final recipeData = recipeSnapshot.docs.first.data();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HpRecipes(
              imageUrl: recipeData['imageUrl'],
              ingredients: recipeData['ingredients'],
              steps: recipeData['steps'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipe: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Handle Home tab
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Menu()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0), // Added top padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Hello,\nWant to make your\nfavourite meal?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      "assets/logo.png",
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30), // Increased space from "Hello"

              // Featured Recipes
              Text(
                "Featured Recipes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: imagePaths.asMap().entries.map((entry) {
                    int index = entry.key;
                    String path = entry.value;
                    String name = names[index];
                    return GestureDetector(
                      onTap: () {
                        _fetchRecipe(name);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Image.asset(
                                path,
                                height: 200,
                                width: 300,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    backgroundColor: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),

              // Categories Carousel
              Text(
                "Recipe Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(context, 'Vegetarian', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fvegetarian.jpg?alt=media&token=b703ffcf-53ae-4265-b53b-69da4a2e4d52'),
                    _buildCategoryItem(context, 'Desserts', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdesserts.jpg?alt=media&token=02153b7a-5476-434f-8ee3-f34c1b4a1cca'),
                    _buildCategoryItem(context, 'Snacks', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsnacks.jpg?alt=media&token=2b4b2a27-0e9d-4011-a5c4-b604af02ce60'),
                    _buildCategoryItem(context, 'Non-Vegetarian', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fnonvef.jpg?alt=media&token=a796a141-6b65-45a0-b41f-15a39ad56d14'),
                    _buildCategoryItem(context, 'Quick & Easy', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fquick%20easy.jpg?alt=media&token=1f840063-1314-49ad-98d5-67fdcea31c38'),
                    _buildCategoryItem(context, 'Soups', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsoup.jpg?alt=media&token=c975b14e-481f-493d-bc23-361d71be377d'),
                    _buildCategoryItem(context, 'Salads', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsalad.jpg?alt=media&token=35b2f112-4b69-40c3-b666-6fae69de36c7'),
                    _buildCategoryItem(context, 'Drinks', 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdrinks.jpg?alt=media&token=2393ae84-2383-4a3b-b659-e377fb89143b'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeList(),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(12.0),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
