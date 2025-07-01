import 'package:flutter/material.dart';
import 'package:flutter_gcs/features/home/home_screen.dart';
import 'package:flutter_gcs/features/telemetry/telemetry.dart';
import 'package:flutter_gcs/welcome_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int selectedIndex = 0;
  List<Widget> get Screens => [HomeScreen(), Telemetry(), WelcomeScreen()];

  void onTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_protected_setup_rounded),
            label: "Live Data",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Welcome Screen"),
        ],
        onTap: onTapped,
      ),
    );
  }
}
