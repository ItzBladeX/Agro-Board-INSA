import 'package:flutter/material.dart';
import 'crop_form.dart';
import 'crop_table.dart';


class CropPage extends StatelessWidget {
  const CropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Page')),

      body: DynamicCropTableBody(
        onActionPressed: (crop) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CropForm(crop: crop)),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CropForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
