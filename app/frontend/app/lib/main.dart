import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agro Board'),
        ),
        body: const Center(
          child: Text('Agro Board'),

        ),
        bottomNavigationBar: Row(
          children:[
            ElevatedButton(
              onPressed:(){},
              child:Text('Home'),
            ),
            ElevatedButton(
              onPressed:(){},
              child:Text('Crop'),
            ),
            ElevatedButton(
              onPressed:(){},
              child:Text('Livestock'),
            ),
            ElevatedButton(
              onPressed:(){},
              child:Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
