import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_recipe.dart';
import 'login.dart';
import 'recipedetail.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Uint8List? _image;
  String _username = '';
  String _bio = '';
  String _profileImageUrl = '';
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
      DocumentSnapshot profileSnapshot =
          await _firestore.collection('profiles').doc(user.uid).get();
      if (profileSnapshot.exists) {
        if (mounted) {
          setState(() {
            _username = profileSnapshot['username'] ?? '';
            _bio = profileSnapshot['bio'] ?? '';
            _profileImageUrl = profileSnapshot['profileImage'] ?? '';
            // Debug print to verify URL
            print('Loaded profile image URL: $_profileImageUrl');
          });
        }
      }
    }
  }

  Future<void> selectImage() async {
    try {
      final ImagePicker _imagePicker = ImagePicker();
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _image = imageBytes;
          });
        }

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
      String fileName =
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';
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
    if (imageUrl != null) {
      await _saveProfile(imageUrl: imageUrl);
      if (mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
          _image = null;
        });
      }
    }
  }

  Future<void> removeImage() async {
    if (_profileImageUrl.isNotEmpty) {
      await deleteImage(_profileImageUrl);
    }
    await _saveProfile(imageUrl: '');
    if (mounted) {
      setState(() {
        _profileImageUrl = '';
        _image = null;
      });
    }
  }

  Future<void> _saveProfile({String? imageUrl}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('profiles').doc(user.uid).set({
          'username': _username,
          'bio': _bio,
          'profileImage': imageUrl ?? _profileImageUrl,
        }, SetOptions(merge: true)).then((_) {
          print('Profile updated with image URL: $imageUrl');
        }).catchError((error) {
          print('Failed to update profile: $error');
        });
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

  void _showEditProfileDialog() {
    TextEditingController _usernameController =
        TextEditingController(text: _username);
    TextEditingController _bioController = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_usernameController.text.isNotEmpty &&
                    _bioController.text.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      _username = _usernameController.text;
                      _bio = _bioController.text;
                    });
                  }
                  Navigator.pop(context);
                  _saveProfile();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fields cannot be empty')));
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout'),
                onTap: () async {
                  SharedPreferences prefs;
                  prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isLogin', false);
                  await _auth.signOut();
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
              ),
              if (!_isProfileSaved)
                ListTile(
                  leading: Icon(Icons.save),
                  title: Text('Save Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    saveProfile();
                    setState(() {
                      _isProfileSaved = true;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isProfileSaved = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.satisfy(
              textStyle: TextStyle(
                color: const Color.fromARGB(255, 11, 11, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.black),
              onPressed: _showSettingsDialog,
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showOptionsDialog,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[200],
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
                            : Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.grey,
                              ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_username.isNotEmpty ? _username : 'Username',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 5),
                      Text(_bio.isNotEmpty ? _bio : 'Bio',
                          style: TextStyle(
                            fontSize: 15,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _showEditProfileDialog,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 145, vertical: 2),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              side: BorderSide(
                color: Colors.black,
                width: 1.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: Text('Edit Profile'),
          ),
          Divider(
            thickness: 1.0,
            color: Colors.grey,
            indent: 16.0,
            endIndent: 16.0,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.book, color: Colors.black),
                  title:
                      Text('My Recipes', style: TextStyle(color: Colors.black)),
                  onTap: _navigateToMyRecipes,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.add_circle, color: Colors.black),
                  title:
                      Text('Add Recipe', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddRecipe()),
                    );
                  },
                ),
              ],
            ),
          ),
        ])));
  }
}
