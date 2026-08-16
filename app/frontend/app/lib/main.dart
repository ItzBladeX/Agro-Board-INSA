import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AgroBoard());
  }
}

class AgroBoard extends StatelessWidget {
  const AgroBoard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agro Board')),
      bottomNavigationBar: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Text('Home'),
          ),
          ElevatedButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CropPage()),
              );
          },
           child: Text('Crop')),

          ElevatedButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LivestockPage()),
              );
          }, 
          child: Text('LiveStock')),

          ElevatedButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
          }, 
          child: Text('Profile')),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('Welcome to the Home Page!')),
    );
  }
}

class CropPage extends StatelessWidget {
  const CropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop')),
      body: Center(child: Text('Welcome to the Crop Page!')),
    );
  }
}

class LivestockPage extends StatelessWidget {
  const LivestockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LiveStock')),
      body: Center(child: Text('Welcome to the LiveStock Page!')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: Text('Welcome to the Profile Page!')),
    );
  }
}
