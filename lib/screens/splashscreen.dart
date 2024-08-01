import 'package:cook_n_eat/screens/homepage.dart';
import 'package:cook_n_eat/screens/scroll.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Register())
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Positioned.fill(
            child: Image.asset(
              'assets/splash.jpeg',
              fit: BoxFit.cover,
            ),
          ),

         
          Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(80.0), 
            child: Text(
              'CookNeat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36.0, 
                fontWeight: FontWeight.bold,
              ),
             
            ),
            
          ),
          
        ),
        SizedBox(height: 50.0,),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(40.0), 
            child: Text(
              'Cook the way you like!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0, 
                fontWeight: FontWeight.bold,
              ),
             
            ),
            
          ),
          
        )


        ],
      ),
    );
  }
}




