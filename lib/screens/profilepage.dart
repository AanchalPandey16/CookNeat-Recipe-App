import 'dart:typed_data';
import 'package:cook_n_eat/screens/recipedetail.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Uint8List? _image;
  String _username = ''; 
  String _bio = ''; 
  String _profileImageUrl = ''; // Current profile image URL
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot profileSnapshot = await _firestore.collection('profiles').doc(user.uid).get();
      if (profileSnapshot.exists) {
        setState(() {
          _username = profileSnapshot['username'] ?? '';
          _bio = profileSnapshot['bio'] ?? '';
          _profileImageUrl = profileSnapshot['profileImage'] ?? '';
        });
      }
    }
  }

  Future<void> selectImage() async {
    try {
      final ImagePicker _imagePicker = ImagePicker();
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _image = imageBytes;
        });
        // Upload the image in the background
        _uploadImageAndSaveProfile(imageBytes);
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      String fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> _uploadImageAndSaveProfile(Uint8List imageBytes) async {
    String? imageUrl = await uploadImage(imageBytes);
    await _saveProfile(imageUrl: imageUrl);
  }

  Future<void> removeImage() async {
    if (_profileImageUrl.isNotEmpty) {
      await deleteImage(_profileImageUrl);
    }
    await _saveProfile(imageUrl: '');
    setState(() {
      _profileImageUrl = '';
      _image = null;
    });
  }

  Future<void> _saveProfile({String? imageUrl}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('profiles').doc(user.uid).set({
          'username': _username,
          'bio': _bio,
          'profileImage': imageUrl ?? _profileImageUrl,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error saving profile: $e');
      }
    }
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_profileImageUrl.isNotEmpty || _image != null)
                ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('Remove Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await removeImage();
                  },
                ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Change Photo'),
                onTap: () {
                  Navigator.pop(context);
                  selectImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUsernameDialog() {
    TextEditingController _controller = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _username = _controller.text;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username cannot be empty')));
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showBioDialog() {
    TextEditingController _controller = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Bio'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Bio',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _bio = _controller.text;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bio cannot be empty')));
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveProfile() async {
    await _saveProfile();
  }

  void _navigateToMyRecipes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Padding from the top

            // Profile Picture, Username, and Bio Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _showOptionsDialog,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      child: _image != null
                          ? ClipOval(
                              child: Image.memory(
                                _image!,
                                fit: BoxFit.cover,
                                width: 140,
                                height: 140,
                              ),
                            )
                          : _profileImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _profileImageUrl,
                                    fit: BoxFit.cover,
                                    width: 140,
                                    height: 140,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.network(
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgkL2Fnam9wpeHJuVZ_dHapQFwK3_qw9V1-w&s',
                                    fit: BoxFit.cover,
                                    width: 140,
                                    height: 140,
                                  ),
                                ),
                    ),
                  ),
                  SizedBox(width: 20),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _showUsernameDialog,
                          child: Text(
                            _username.isEmpty ? 'Username' : _username,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        GestureDetector(
                          onTap: _showBioDialog,
                          child: Text(
                            _bio.isEmpty ? 'Bio' : _bio,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: saveProfile,
                child: Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                ),
              ),
            ),
            
            // My Recipes Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _navigateToMyRecipes,
                child: Text('My Recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
