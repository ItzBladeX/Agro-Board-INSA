import 'package:flutter/material.dart';
import './models/crop_model.dart';
import 'chart.dart';
import 'crop_form.dart';
import 'crop_table.dart';

class CropsPage extends StatefulWidget {
  const CropsPage({super.key});

  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  final List<CropRecord> _cropRecords = [
    const CropRecord(
      cropId: 101.0,
      name: 'Wheat',
      season: 'Jan - Apr',
      expectedYieldKgPerHa: 450,
      actualYieldKgPerHa: 480,
    ),
    const CropRecord(
      cropId: 102.0,
      name: 'Corn',
      season: 'May - Aug',
      expectedYieldKgPerHa: 700,
      actualYieldKgPerHa: 620,
    ),
    const CropRecord(
      cropId: 103.0,
      name: 'Rice',
      season: 'Sep - Dec',
      expectedYieldKgPerHa: 600,
      actualYieldKgPerHa: 610,
    ),
  ];

  void _addNewCrop(CropRecord newCrop) {
    setState(() {
      _cropRecords.add(newCrop);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crops Management board'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Yield Graph Analysis
            CropChart(crops: _cropRecords),
            const SizedBox(height: 10),
            // Responsive Datatable layout
            CropTable(crops: _cropRecords),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => Padding(
                // FIXED: Changed viewInsets.top to viewInsets.bottom so keyboard pushes form up smoothly
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: CropForm(
                  onSubmit: (newCrop) {
                    _addNewCrop(newCrop);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ), // Fixed matching closing bracket
      ),
    );
  }
}
