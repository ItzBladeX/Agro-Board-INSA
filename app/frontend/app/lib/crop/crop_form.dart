import 'package:flutter/material.dart';

import './models/crop_model.dart';

class CropForm extends StatefulWidget {
  const CropForm({super.key, required this.onSubmit});

  final ValueChanged<CropRecord> onSubmit;

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  final _formKey = GlobalKey<FormState>();
  final _cropIdControler = TextEditingController();
  final _nameController = TextEditingController();
  final _seasonController = TextEditingController();
  final _expectedYieldController = TextEditingController();
  final _actualYieldController = TextEditingController();

  @override
  void dispose() {
    _cropIdControler.dispose();
    _nameController.dispose();
    _seasonController.dispose();
    _expectedYieldController.dispose();
    _actualYieldController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      CropRecord(
        cropId: double.parse(_cropIdControler.text.trim()),
        name: _nameController.text.trim(),
        season: _seasonController.text.trim(),
        expectedYieldKgPerHa: double.parse(
          _expectedYieldController.text.trim(),
        ),
        actualYieldKgPerHa: double.parse(_actualYieldController.text.trim()),
      ),
    );

    _formKey.currentState!.reset();
    _nameController.clear();
    _seasonController.clear();
    _expectedYieldController.clear();
    _actualYieldController.clear();
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add crop data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextFormField(
              controller: _cropIdControler,
              decoration: const InputDecoration(labelText: 'crop Id'),
              keyboardType: TextInputType.number,
              validator: _positiveNumber,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Crop name'),
              validator: _required,
            ),
            TextFormField(
              controller: _seasonController,
              decoration: const InputDecoration(
                labelText: 'Season(planting-harvestng)',
              ),
              validator: _required,
            ),
            TextFormField(
              controller: _expectedYieldController,
              decoration: const InputDecoration(
                labelText: 'Expected Yield (kg/ha)',
              ),
              keyboardType: TextInputType.number,
              validator: _positiveNumber,
            ),
            TextFormField(
              controller: _actualYieldController,
              decoration: const InputDecoration(
                labelText: 'Actual Yield (kg/ha)',
              ),
              keyboardType: TextInputType.number,
              validator: _positiveNumber,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _submit, child: const Text('Add crop')),
          ],
        ),
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number <= 0
        ? 'Enter a number greater than zero.'
        : null;
  }
}
