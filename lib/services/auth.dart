import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to log in users with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error: ${e.toString()}");
      return null;
    }
  }

  // Method to register a new user with email and password
  Future<User?> registerWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateProfile(displayName: name);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");  // Print the specific error message
      return null;
    } catch (e) {
      print("Unexpected error: ${e.toString()}");
      return null;
    }
  }
}