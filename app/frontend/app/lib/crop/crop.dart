import 'package:flutter/material.dart';
import 'crop_form.dart';

class CropPage extends StatelessWidget {
  const CropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Page')),
      
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CropForm()),
            );
          },
          child: const Icon(Icons.add),
          
        ),
    );
  }
}
