import 'package:cook_n_eat/services/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  File? selectedImage;
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        selectedImage = File(image.path);
      } else {
        selectedImage = null;
      }
    });
  }

  Future<void> uploadItem() async {
    if (selectedImage != null &&
        recipeNameController.text.isNotEmpty &&
        ingredientsController.text.isNotEmpty &&
        stepsController.text.isNotEmpty) {
      try {
        String addId = randomAlphaNumeric(10);
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String userId = user.uid;

          // Upload image to Firebase Storage
          Reference firebaseStorageRef =
              FirebaseStorage.instance.ref().child("recipeImages").child(addId);
          final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
          var downloadUrl = await (await task).ref.getDownloadURL();

          // Create recipe data with userId
          Map<String, dynamic> addRecipe = {
            "name": recipeNameController.text,
            "ingredients": ingredientsController.text,
            "steps": stepsController.text,
            "image": downloadUrl,
            "userId": userId, 
          };

          // Save recipe under user's ID in Firestore
          await DatabaseMethods().addRecipe(addRecipe);

          // Clear fields and reset state
          recipeNameController.clear();
          ingredientsController.clear();
          stepsController.clear();
          setState(() {
            selectedImage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recipe added successfully')),
          );
        }
      } catch (e) {
        print('Error adding recipe: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 50.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add Recipe',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(),
                    ),
                    child: selectedImage == null
                        ? Icon(Icons.camera_alt_outlined)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.file(
                              selectedImage!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text('Recipe Name:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.only(left: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: recipeNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '  Name of your dish',
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text('Ingredients:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.only(left: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: ingredientsController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '  From what you made your dish',
                  ),
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 20.0),
              Text('Steps to Make:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.only(left: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: stepsController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '  How did you make it',
                  ),
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 222, 80, 70), Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    onPressed: uploadItem,
                    child: Text('Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black45,
                                offset: Offset(2.0, 2.0),
                              ),
                            ])),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
