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
          MaterialPageRoute(builder: (context) => const AddRecipe()),
        );
        break;
      case 3:
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
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryCard('assets/salad.png', 'Salad Recipes'),
                    _buildCategoryCard('assets/chinese.png', 'Chinese Recipes'),
                    _buildCategoryCard('assets/pasta.jpeg', 'Pasta Recipes'),
                    _buildCategoryCard('assets/soup.jpeg', 'Soup Recipes'),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book,
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        elevation: 8.0,
      ),
    );
  }

  Widget _buildCategoryCard(String imagePath, String title) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
