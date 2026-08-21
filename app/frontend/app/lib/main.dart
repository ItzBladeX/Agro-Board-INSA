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

  // MongoDB Leaf-inspired colors
  static const Color leafGreen = Color(0xFF00684A);
  static const Color softGreen = Color(0xFFE3FCF7);
  static const Color darkText = Color(0xFF001E2B);

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
      theme: ThemeData(
        primaryColor: leafGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: leafGreen,
          primary: leafGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: leafGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: leafGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "AgroBoard",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          backgroundColor: leafGreen,
          centerTitle: true,
        ),
        body: IndexedStack(index: _currentIndex, children: pageList),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: leafGreen,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Crop'),
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'LiveStock'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
