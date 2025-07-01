import 'package:flutter/material.dart';
import 'app.dart'; // Import your app's main file

void main() {
  runApp(const MyApp());
}


// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Test Icons',
//       theme: ThemeData(useMaterial3: true),
//       home: NavBarExample(),
//     );
//   }
// }

// class NavBarExample extends StatefulWidget {
//   @override
//   State<NavBarExample> createState() => _NavBarExampleState();
// }

// class _NavBarExampleState extends State<NavBarExample> {
//   int _selectedIndex = 0;
//   static const List<Widget> _widgetOptions = <Widget>[
//     Text('Home Screen'),
//     Text('Live Data'),
//     Text('Welcome Screen'),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: _widgetOptions[_selectedIndex]),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Live Data'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Welcome'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
