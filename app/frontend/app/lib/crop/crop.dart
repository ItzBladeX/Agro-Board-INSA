import 'package:flutter/material.dart';
import 'crop_form.dart';
import 'crop_table.dart';

class CropPage extends StatelessWidget {
  const CropPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tableKey = GlobalKey<DynamicCropTableBodyState>();

    Future<void> _openForm(BuildContext context, {Map<String, dynamic>? crop}) async {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => CropForm(crop: crop)),
      );

      if (result == true) {
        tableKey.currentState?.fetchCrops();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Page')),
      body: DynamicCropTableBody(
        key: tableKey,
        onActionPressed: (crop) => _openForm(context, crop: crop),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}