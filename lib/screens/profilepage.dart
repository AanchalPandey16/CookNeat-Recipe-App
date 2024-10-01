import 'dart:typed_data';
import 'package:cook_n_eat/screens/favourite.dart';
import 'package:cook_n_eat/screens/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_recipe.dart';
import 'login.dart';
import 'myrecipes.dart';
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

        await _uploadImageAndSaveProfile(imageBytes);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
          title: Center(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade600,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.orange.shade600),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: Colors.orange.shade600),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 10),

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
              child: Text(
                'Save',
                style: TextStyle(color: Colors.orange.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveProfile() async {
    await _saveProfile();
  }

  void _showSettingsDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.feedback,
                  color: Colors.orange[600],
                ),
                title: Text('Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  _showFeedbackDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController _feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Enter your feedback here',
                    labelStyle: TextStyle(color: Colors.orange[600]),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () async {
                String feedback = _feedbackController.text.trim();
                if (feedback.isNotEmpty) {
                  try {
                    final User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('profiles')
                          .doc(user.uid)
                          .update({
                        'feedback': feedback,
                        'time': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Feedback sent successfully')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No user logged in')));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send feedback')));
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Feedback cannot be empty')));
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange[600],
              ),
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: GoogleFonts.allura(
              textStyle: TextStyle(
                fontSize: 35,
                color: Colors.orange.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.orange.shade600),
              onPressed: _showSettingsDrawer,
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showOptionsDialog,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Colors.orange.shade400,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? Image.memory(
                              _image!,
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                            )
                          : _profileImageUrl.isNotEmpty
                              ? Image.network(
                                  _profileImageUrl,
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 140,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                    ),
                  ),
                ),
                SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username.isNotEmpty ? _username : 'Username',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _bio.isNotEmpty ? _bio : 'Bio',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _showEditProfileDialog,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 140, vertical: 8),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
              side: BorderSide(
                color: Colors.orange.shade200,
                width: 1.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: Colors.orange[100],
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.orange[600],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.orange[200]),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Material(
                    elevation: 5,
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.add_circle,
                          color: Colors.orange[600], size: 30),
                      title: Text(
                        'Add Recipe',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddRecipe()),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Material(
                  elevation: 5,
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.book,
                        color: Colors.orange.shade600, size: 30),
                    title: Text(
                      'My Recipes',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeList()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),
                Material(
                  elevation: 5,
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.add_circle,
                        color: Colors.orange[600], size: 30),
                    title: Text(
                      'Favourite Recipe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoritePage()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),
                Material(
                  elevation: 5,
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red, size: 30),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Confirmation",
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel",
                                    style: TextStyle(color: Colors.black)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Logout",
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('isLogin', false);
                                  await _auth.signOut();
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ])));
  }
}
