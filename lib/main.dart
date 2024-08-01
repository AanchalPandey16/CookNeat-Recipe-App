import 'dart:async';
import 'package:cook_n_eat/screens/homepage.dart';
import 'package:cook_n_eat/screens/menu.dart';
import 'package:cook_n_eat/screens/profilepage.dart';
import 'package:cook_n_eat/screens/scroll.dart';
import 'package:cook_n_eat/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookNeat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: Splash(),
    );
  }
}
