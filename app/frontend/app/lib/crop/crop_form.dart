import 'package:flutter/material.dart';

class CropForm extends StatefulWidget {
  const CropForm({super.key});

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  DateTime? plantedDate;
  DateTime? harvestDate;

  Map<String, dynamic> cropData = {};

  String? selectedCrop;

  final TextEditingController cropNameController = TextEditingController();
  final TextEditingController prodStartYearController = TextEditingController();
  final TextEditingController prodEndYearController = TextEditingController();
  final TextEditingController plantedDateController = TextEditingController();
  final TextEditingController harvestDateController = TextEditingController();
  final TextEditingController cropYieldController = TextEditingController();
  final TextEditingController prodCostController = TextEditingController();
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Form')),
      body: Form(
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Crop Name'),
              items: const [
                DropdownMenuItem(value: 'Wheat', child: Text('Wheat')),
                DropdownMenuItem(value: 'Rice', child: Text('Rice')),
                DropdownMenuItem(value: 'Corn', child: Text('Corn')),
                DropdownMenuItem(value: 'Maize', child: Text('Maize')),
                DropdownMenuItem(value: 'Tomato', child: Text('Tomato')),
                DropdownMenuItem(value: 'Potato', child: Text('Potato')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCrop = value;
                });
                // Handle dropdown change
              },
            ),
            TextFormField(
              controller: prodStartYearController,
              decoration: const InputDecoration(labelText: 'prod_start_year'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter year';
                }

                final year = int.tryParse(value);
                if (year == null) {
                  return 'please enter a valid number';
                }
                if (year < 1900 || year > 2200) {
                  return 'Year must be between 1900 & 2200';
                }
                return null;
              },
            ),
            TextFormField(
              controller: prodEndYearController,
              decoration: const InputDecoration(labelText: 'prod_end_year'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter year';
                }

                final year = int.tryParse(value);
                if (year == null) {
                  return 'please enter a valid number';
                }
                if (year < 1900 || year > 2200) {
                  return 'Year must be between 1900 & 2200';
                }
                return null;
              },
            ),
            TextButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    plantedDate = pickedDate;
                  });
                }
              },
              child: Text(
                plantedDate == null
                    ? 'Select Planting Date'
                    : 'Planted Date: ${plantedDate!.day}/${plantedDate!.month}/${plantedDate!.year}',
              ),
            ),
            TextButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    harvestDate = pickedDate;
                  });
                }
              },
              child: Text(
                harvestDate == null
                    ? 'Select Harvest Date'
                    : 'Harvest Date: ${harvestDate!.day}/${harvestDate!.month}/${harvestDate!.year}',
              ),
            ),
            TextFormField(
              controller: cropYieldController,
              decoration: const InputDecoration(labelText: 'Crop Yield in Kg'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: prodCostController,
              decoration: const InputDecoration(labelText: 'Prod Cost in ETB'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: revenueController,
              decoration: const InputDecoration(labelText: 'Revenue in ETB'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: profitController,
              decoration: const InputDecoration(labelText: 'Profit in ETB'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                cropData['Crop Name'] = selectedCrop;
                cropData['prod_start_year'] = int.parse(
                  prodStartYearController.text,
                );
                cropData['prod_end_year'] = int.parse(
                  prodEndYearController.text,
                );
                cropData['Planted date'] = plantedDate;
                cropData['Harvest date'] = harvestDate;
                cropData['Crop Yield in Kg'] = double.parse(
                  cropYieldController.text,
                );
                cropData['Prod Cost in ETB'] = double.parse(
                  prodCostController.text,
                );
                cropData['Revenue in ETB'] = double.parse(
                  revenueController.text,
                );
                cropData['Profit in ETB'] = double.parse(profitController.text);
                cropData['Notes'] = notesController.text;
                print(cropData);
              },
            ),
          ],
        ),
      ),
    );
  }
}
