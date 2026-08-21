import 'package:flutter/material.dart';

class LivestockForm extends StatefulWidget {
  const LivestockForm({super.key});

  @override
  State<LivestockForm> createState() => _LivestockFormState();
}

class _LivestockFormState extends State<LivestockForm> {
  DateTime? entryDate;
  DateTime? exitDate;

  Map<String, dynamic> livestockData = {};

  String? selectedlivestock;

  final TextEditingController livestockController = TextEditingController();
  final TextEditingController prodStartYearController = TextEditingController();
  final TextEditingController prodEndYearController = TextEditingController();
  final TextEditingController entryDateController = TextEditingController();
  final TextEditingController exitDateController = TextEditingController();
  final TextEditingController livestockNumController = TextEditingController();
  final TextEditingController prodCostController = TextEditingController();
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiveStock Form')),
      body: Form(
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Name'),
              items: const [
                DropdownMenuItem(value: 'Sheep', child: Text('Sheep')),
                DropdownMenuItem(value: 'Cow', child: Text('Cow')),
                DropdownMenuItem(value: 'Chicken', child: Text('Chicken')),
                DropdownMenuItem(value: 'Goat', child: Text('Goat')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedlivestock = value;
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
                    entryDate = pickedDate;
                  });
                }
              },
              child: Text(
                entryDate == null
                    ? 'Select Entry Date'
                    : 'Entry Date: ${entryDate!.day}/${entryDate!.month}/${entryDate!.year}',
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
                    exitDate = pickedDate;
                  });
                }
              },
              child: Text(
                exitDate == null
                    ? 'Select Exit Date'
                    : 'Exit Date: ${exitDate!.day}/${exitDate!.month}/${exitDate!.year}',
              ),
            ),
            TextFormField(
              controller: livestockController,
              decoration: const InputDecoration(labelText: 'livestock num '),
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
                livestockData['name'] = selectedlivestock;
                livestockData['prod_start_year'] = int.parse(
                  prodStartYearController.text,
                );
                livestockData['prod_end_year'] = int.parse(
                  prodEndYearController.text,
                );
                livestockData['livestock_num'] = double.parse(
                  livestockNumController.text,
                );
                livestockData['Prod Cost in ETB'] = double.parse(
                  prodCostController.text,
                );
                livestockData['Revenue in ETB'] = double.parse(
                  revenueController.text,
                );
                livestockData['Profit in ETB'] = double.parse(profitController.text);
                livestockData['Notes'] = notesController.text;
              },
            ),
          ],
        ),
      ),
    );
  }
}
