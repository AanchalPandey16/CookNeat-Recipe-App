import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cook_n_eat/screens/recipedet.dart'; // Ensure this path is correct

class RecipeListPage extends StatelessWidget {
  final String category;

  const RecipeListPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recipes = _getRecipesForCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Recipes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: recipes.map((recipe) {
            return Column(
              children: [
                _buildRecipeItem(context, recipe['name']!, recipe['imageUrl']!),
                SizedBox(height: 16.0), // Space between containers
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Map<String, String>> _getRecipesForCategory(String category) {
   
    switch (category) {
      case 'Vegetarian':
        return [
          {'name': 'Matar Paneer', 'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2FVegetarian%2Fpaneer.jpg?alt=media&token=95a11507-c09c-4f12-91e7-d62545cd52a9'},
          {'name': 'Dal Makhni', 'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2FVegetarian%2Fdalmakhni.jpg?alt=media&token=0aeff17f-b371-4f6c-b912-7d2e0871dc9b'},
          {'name': 'Palak Paneer', 'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2FVegetarian%2Fpalakpaneer.jpg?alt=media&token=ddb930d3-1c90-45b8-a9a9-d82280d885d7'},
          {'name': 'Chole Bhature', 'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2FVegetarian%2Fcholee.jpg?alt=media&token=6b379c3a-4301-4144-807a-0cb6c56289e7'},
        ];
        case 'Desserts':
        return[
        {'name': 'Gulab Jamun', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdesserts%2Fgj.jpg?alt=media&token=7a53d06c-9d93-4c66-a742-71071bbac594'},
        {'name': 'Rasmalai', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdesserts%2Frasmalai.jpg?alt=media&token=8d81d968-08f7-4d44-a5c5-7404f30bb2a1'},
        {'name': 'Gajar ka Halwa', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdesserts%2Fgh.jpg?alt=media&token=572cfd4b-cbb1-4f77-83d7-e9c89779fd0f'},
        {'name': 'Kheer', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdesserts%2Fkheer.jpg?alt=media&token=977996db-d162-4621-8b1d-4477f7f83d28'},
        ];
        case 'Snacks':
        return[
          {'name':'Samosa', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsnacks%2Fsamosa.jpg?alt=media&token=ed2e10ee-6967-4c79-905c-7df68b796b57'},
          {'name':'Pyaaz Pakoda', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsnacks%2Fpyaazpakoda.jpg?alt=media&token=12416f76-6a77-45e3-821f-5e2e5cadd4b8'},
          {'name':'Pani Puri', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsnacks%2Fpp.jpg?alt=media&token=dd954412-7b35-490d-bea4-7a0bb59e72d3'},
          {'name':'Poha', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsnacks%2Fpoha.jpg?alt=media&token=6bfd4081-31bd-42e7-9445-76333ec8e592'},
       
          ];
          case 'Non-Vegetarian':
          return[
            {'name':'Chicken Curry', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fnon%20veg%2Fchickencurry.jpg?alt=media&token=ce8b436e-5e72-43b0-9a66-5aedaaa808f2'},
            {'name':'Chicken Biryani', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fnon%20veg%2Fbiryani.jpg?alt=media&token=0a8530ed-6a9c-43e1-9763-30e57618c875'},
            {'name':'Fish Fry', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fnon%20veg%2Ffish.jpg?alt=media&token=24b90ed3-0d31-4cce-99b7-164390fb6137'},
            {'name':'Chicken Kebab', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fnon%20veg%2Fkebab.jpg?alt=media&token=8318edb1-1d68-41e6-9330-2572a799c0c7'},
          ];
          case 'Quick & Easy':
          return[
          {'name': 'Aloo Paratha', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fquick%20and%20easy%2Falooparatha.jpg?alt=media&token=6c6479b7-1333-4d4f-97ee-784767e24dcc'},
          {'name': 'Besan Chilla', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fquick%20and%20easy%2Fbesan.jpg?alt=media&token=28db24c7-22e9-457e-bed8-b47d715d400a'},
          {'name': 'Corn Chaat', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fquick%20and%20easy%2Fcornchaat.jpg?alt=media&token=ee44ca90-d3f7-4442-9aed-42a2a9f617f1'},
          {'name': 'Sandwich', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fquick%20and%20easy%2Fsandwich.jpg?alt=media&token=d10d17ae-3952-4ffa-a967-fa26c5cc3dd1'},
          ];
          case 'Soups':
          return[
          {'name': 'Cabbage egg roll Soup', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsoups%2Fcabbageeggroll.jpg?alt=media&token=370aa6d8-9792-45f6-bfee-9e5fbc4d0314'},
          {'name': 'Chicken Soup', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsoups%2Fchicken.jpg?alt=media&token=79ac0adb-3112-4a4c-86a9-4804ddc700de'},
          {'name': 'Vegetable Soup', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsoups%2Fvegsoup.jpg?alt=media&token=e2868fcd-bc67-410d-a3a6-4a5990561468'},
          {'name': 'Tomato Soup', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsoups%2Ftom.jpg?alt=media&token=bb17ba29-cf3e-4eb7-ac38-36e45afbe3a9'},
          ];
         case 'Salads':
          return[
          {'name': 'Chicken Salad', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsalads%2Fchickensalad.jpg?alt=media&token=dbaf19d1-839f-427a-a5b9-eb3738662197'},
          {'name': 'Cucumber Tomato Salad', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsalads%2Fcucumbettomsalad.jpg?alt=media&token=d554a49b-0d28-4126-ad5b-d9a8f2a46570'},
          {'name': 'Italian Salad', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsalads%2Fitaliansalad.jpg?alt=media&token=9ab938e2-7b81-4868-9a77-7b8a24139efc'},
          {'name': 'Shirazi Salad', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fsalads%2Fshirazisalad.jpg?alt=media&token=658a6403-3b7f-4092-bf7f-e3d0ede6b17d'},
          ];
          case 'Drinks':
          return[
          {'name': 'Lassi', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdrinks%2Flassi.jpg?alt=media&token=5a7d99b7-e3e3-4001-9dda-1a72522a9013'},
          {'name': 'Thandai', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdrinks%2Fthandai.jpg?alt=media&token=2545004a-b150-4feb-8d6c-49730537bd7d'},
          {'name': 'Nimbu Pani', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdrinks%2Fnimbu.jpg?alt=media&token=fd19e96a-9c51-46ed-a901-f953fad9ddee'},
          {'name': 'Badam Milk', 'imageUrl':'https://firebasestorage.googleapis.com/v0/b/cookneat-4c30e.appspot.com/o/menu%2Fdrinks%2Fbadam%20milk.jpg?alt=media&token=5365cac6-1d9d-4583-926f-c14e33e85247'},
          ];
        
      default:
        return [];
    }
  }
Widget _buildRecipeItem(BuildContext context, String recipeName, String imageUrl) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailPage(
            recipeName: recipeName,
            imageUrl: imageUrl, collectionName: 'recipe_detail',
          ),
        ),
      );
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 150.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[200]!),)),
              errorWidget: (context, url, error) => Icon(Icons.error),
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
                recipeName,
                style: TextStyle(
                  fontSize: 18,
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