import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> convertGsToHttp(String gsUrl) async {
  final ref = FirebaseStorage.instance.refFromURL(gsUrl);
  String downloadURL = await ref.getDownloadURL();
  return downloadURL;
}

class RecipeList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Recipe').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No recipes found.'));
          }

          final recipes = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10.0),
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 0.62, // Adjust aspect ratio to fit content
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index].data() as Map<String, dynamic>;

              return Container(
               
                height: 200,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe['image'] != null)
                        FutureBuilder<String>(
                          future: convertGsToHttp(recipe['image']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Icon(Icons.error);
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                snapshot.data!,
                                width: double.infinity,
                                height: 160, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 10),
                      Text(
                        recipe['name'] ?? 'No Name',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 5,
                      ),
                      SizedBox(height: 5),
                      Text(recipe['ingredients'] ?? 'No Ingredients'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class RecipeDetail extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetail({required this.recipe});

  Future<String> convertGsToHttp(String gsUrl) async {
    final ref = FirebaseStorage.instance.refFromURL(gsUrl);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name'] ?? 'Recipe Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe['image'] != null)
                FutureBuilder<String>(
                  future: convertGsToHttp(recipe['image']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Icon(Icons.error, size: 100);
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        snapshot.data!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 100);
                        },
                      ),
                    );
                  },
                ),
              SizedBox(height: 20), // Reduced the height to 20
              Text(
                'Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(recipe['ingredients'] ?? 'No Ingredients'),
              SizedBox(height: 20),
              Text(
                'Steps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(recipe['steps'] ?? 'No Steps'),
            ],
          ),
        ),
      ),
    );
  }
}
