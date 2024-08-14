import 'package:cook_n_eat/screens/recipedetail.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
    'Boondi Raita',
  ];

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
              dishName: recipeData['name'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0), // Added top padding
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
                        fontSize: 25.0,
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
              SizedBox(height: 30), 

             
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
            ],
          ),
        ),
      ),
    );
  }
}
