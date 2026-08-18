import 'package:flutter/material.dart';

class CropForm extends StatefulWidget {
  const CropForm({super.key});

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  DateTime? plantingDate;
  DateTime? harvestDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Form')),
      body: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Crop ID'),
            ),
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
                // Handle dropdown change
              },
            ),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Quantity'),
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 25, child: Text('25')),
                DropdownMenuItem(value: 50, child: Text('50')),
                DropdownMenuItem(value: 100, child: Text('100')),
                DropdownMenuItem(value: 250, child: Text('250')),
                DropdownMenuItem(value: 500, child: Text('500')),
                DropdownMenuItem(value: 1000, child: Text('1000')),
                DropdownMenuItem(value: 2500, child: Text('2500')),
                DropdownMenuItem(value: 5000, child: Text('5000')),
              ],
              onChanged: (value) {
                // 3a  dropdown change
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Unit'),
              items: const [
                DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                DropdownMenuItem(value: 'quintal', child: Text('quintal')),
                DropdownMenuItem(value: 'ton', child: Text('ton')),
                DropdownMenuItem(value: 'bag', child: Text('bag')),
              ],
              onChanged: (value) {
                // Handle dropdown change
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
                    plantingDate = pickedDate;
                  });
                }
              },
              child: Text(
                plantingDate == null
                    ? 'Select Planting Date'
                    : 'Planting Date: ${plantingDate!.day}/${plantingDate!.month}/${plantingDate!.year}',
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
              decoration: const InputDecoration(labelText: 'Add Crop'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Update Crop'),
            ),
            TextButton(child: const Text('Submit'), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
