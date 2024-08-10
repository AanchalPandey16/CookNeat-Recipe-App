import 'package:cook_n_eat/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:cook_n_eat/screens/onboarding/onboarding_items.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();

  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: Colors.white24,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: isLastPage? getStarted(): Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => pageController.jumpToPage(controller.items.length - 1),
              child: Text("Skip"),
            ),
            
            SmoothPageIndicator(
              controller: pageController,
              count: controller.items.length,
              onDotClicked: (index) => pageController.animateToPage(index,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut),
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.orange,
              ),
            ),
            TextButton(
              onPressed: () => pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
              ),
              child: Text("Next"),
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: PageView.builder(
          onPageChanged: (index) => setState(()=> isLastPage = controller.items.length-1 == index),
          itemCount: controller.items.length,
          controller: pageController,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(controller.items[index].image),
                SizedBox(height: 15),
                Text(
                  controller.items[index].title,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  controller.items[index].description,
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),

      ),
    );

  }

  Widget getStarted(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.shade600,
      ),
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: TextButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
        },
      child: Text("Let's get started", style: TextStyle( color: Colors.white
      ),)),
    );
  }
}

