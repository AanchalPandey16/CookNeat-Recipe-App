import 'package:flutter/material.dart';

class HpRecipes extends StatelessWidget {
  final String imageUrl;
  final String ingredients;
  final String steps;

  const HpRecipes({
    Key? key,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
  }) : super(key: key);

  List<String> formatText(String text, bool isSteps) {
    if (isSteps) {
      return text.split('. ').map((step) => '$step.').toList();
    } else {
      return text.split(', ').map((ingredient) => ingredient.trim()).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // Lighter gradient background
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'Recipe Details',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Share functionality here
                    },
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Image
                      imageUrl.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              height: 250.0,
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
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 250.0,
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
                      SizedBox(height: 16.0),

                      // Recipe Ingredients
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5), // Off-white color
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 4),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: formatText(ingredients, false).map((ingredient) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 6.0, // Smaller width
                                        height: 6.0, // Smaller height
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade700,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          ingredient,
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Recipe Steps
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5), // Off-white color
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 4),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Steps',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: formatText(steps, true).map((step) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 6.0, // Smaller width
                                        height: 6.0, // Smaller height
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade700,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
