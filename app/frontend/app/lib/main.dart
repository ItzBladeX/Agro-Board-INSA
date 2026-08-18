import 'package:flutter/material.dart';
import "profile/profile.dart";
import "crop/crop.dart";
import "home/home.dart";
import "livestock/livestock.dart";
import 'crop/crop_form.dart';

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
    return MaterialApp(debugShowCheckedModeBanner: false, home: CropForm());
  }
}
