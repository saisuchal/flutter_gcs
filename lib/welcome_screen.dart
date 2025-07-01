import 'package:flutter/material.dart';
import 'package:flutter_gcs/bottom_navigation_bar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override

  void onPressed() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> CustomBottomNavigationBar()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text("Flutter GCS",
          textAlign: TextAlign.center,),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: onPressed, child: Text("Get Started"))],
        ),
      )
    );
  }
}