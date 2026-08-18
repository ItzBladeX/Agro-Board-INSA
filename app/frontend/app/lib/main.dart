import 'package:flutter/material.dart';
import "profile/profile.dart";
import "crop/crop.dart";
import "home/home.dart";
import "livestock/livestock.dart";

void main() {
  runApp(const MyApp());
  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> pageList = [
    const HomePage(),
    const CropPage(),
    const LivestockPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pageList),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.green,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.grass),
              label: 'Crop',
              backgroundColor: Colors.green,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: 'LiveStock',
              backgroundColor: Colors.green,
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
