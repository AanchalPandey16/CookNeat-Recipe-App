import 'package:cook_n_eat/screens/homepage.dart';
import 'package:cook_n_eat/screens/menu.dart';
import 'package:cook_n_eat/screens/profilepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int CurrentTabIndex=0;

  late List<Widget> pages;
  late Widget currentPage;
  late Homepage home;
  late Menu menu ;
  late Profile profile;

  @override

  void initState(){
    home = Homepage();
    menu = Menu();
    profile = Profile();
    pages=[home, menu, profile];
        super.initState();
    
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: const Color.fromARGB(255, 252, 252, 251),
        color: Colors.orange.shade700,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index){
          setState(() {
            CurrentTabIndex=index;
          });
        },
        items: [
        Icon(Icons.home_filled, color: Colors.white),
        Icon(Icons.local_restaurant_outlined, color: Colors.white),
        Icon(Icons.person, color: Colors.white),
      ]),
      body: pages[CurrentTabIndex],
    );
  }
}