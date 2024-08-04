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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[200]!, Colors.orange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text('Add Recipe', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[100]!, Colors.orange[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: getImage,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: selectedImage == null
                          ? Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                _buildTextField(
                  controller: recipeNameController,
                  label: 'Recipe Name',
                  hintText: 'Enter the name of your dish',
                  minLines: 1,
                ),
                SizedBox(height: 20.0),
                _buildTextField(
                  controller: ingredientsController,
                  label: 'Ingredients',
                  hintText: 'List the ingredients used',
                  minLines: 3,
                ),
                SizedBox(height: 20.0),
                _buildTextField(
                  controller: stepsController,
                  label: 'Steps to Make',
                  hintText: 'Describe the steps to make the dish',
                  minLines: 3,
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 231, 105, 67),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 160.0, vertical: 15.0),
                      elevation: 5.0,
                    ),
                    onPressed: uploadItem,
                    child: Text('Save', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int minLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
            minLines: minLines,
            maxLines: null, // Allows the field to expand vertically
          ),
        ),
      ],
    );
  }
}
