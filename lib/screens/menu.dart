import 'package:cook_n_eat/screens/homepage.dart';
import 'package:cook_n_eat/screens/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:cook_n_eat/screens/recipelist.dart'; // Ensure this path is correct

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {
        'name': 'Vegetarian',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fvegetarian.jpg?alt=media&token=b703ffcf-53ae-4265-b53b-69da4a2e4d52'
      },
      {
        'name': 'Desserts',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdesserts.jpg?alt=media&token=02153b7a-5476-434f-8ee3-f34c1b4a1cca'
      },
      {
        'name': 'Snacks',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsnacks.jpg?alt=media&token=2b4b2a27-0e9d-4011-a5c4-b604af02ce60'
      },
      {
        'name': 'Non-Vegetarian',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fnonvef.jpg?alt=media&token=a796a141-6b65-45a0-b41f-15a39ad56d14'
      },
      {
        'name': 'Quick & Easy',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fquick%20easy.jpg?alt=media&token=1f840063-1314-49ad-98d5-67fdcea31c38'
      },
      {
        'name': 'Soups',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsoup.jpg?alt=media&token=c975b14e-481f-493d-bc23-361d71be377d'
      },
      {
        'name': 'Salads',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsalad.jpg?alt=media&token=35b2f112-4b69-40c3-b666-6fae69de36c7'
      },
      {
        'name': 'Drinks',
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdrinks.jpg?alt=media&token=2393ae84-2383-4a3b-b659-e377fb89143b'
      },
    ];

         return Scaffold(
         appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Menu'),
            ],
          ),
          centerTitle: true,
          elevation: 4.0,

        ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: categories.map((category) {
            return Column(
              children: [
                _buildMenuItem(
                    context, category['name']!, category['imageUrl']!),
                SizedBox(height: 16.0),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String category, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeListPage(category: category),
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
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
