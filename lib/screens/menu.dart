import 'package:cook_n_eat/screens/recipelist.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var category in categories) {
      precacheImage(NetworkImage(category['imageUrl']!), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.5),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Menu',
              style: GoogleFonts.allura(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Colors.orange.shade500,
                ),
              ),
            ),
          ],
        ),
       
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Column(
            children: [
              _buildMenuItem(
                context,
                category['name']!,
                category['imageUrl']!,
              ),
              SizedBox(height: 20.0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String category, String imageUrl) {
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
        height: 220.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[200]!),
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
                padding: EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.black45],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 18.0,
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
