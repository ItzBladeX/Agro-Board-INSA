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
  final _cropIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _seasonController = TextEditingController();
  final _expectedYieldController = TextEditingController();
  final _actualYieldController = TextEditingController();

  @override
  void dispose() {
    _cropIdController.dispose();
    _nameController.dispose();
    _seasonController.dispose();
    _expectedYieldController.dispose();
    _actualYieldController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newCrop = CropRecord(
        cropId:
            double.tryParse(_cropIdController.text) ??
            DateTime.now().millisecondsSinceEpoch.toDouble(),
        name: _nameController.text,
        season: _seasonController.text,
        expectedYieldKgPerHa:
            double.tryParse(_expectedYieldController.text) ?? 0.0,
        actualYieldKgPerHa: double.tryParse(_actualYieldController.text) ?? 0.0,
      );
      widget.onSubmit(newCrop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Crop Entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cropIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Crop ID',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required ID' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required Name' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _seasonController,
              decoration: const InputDecoration(
                labelText: 'Season Window',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required Season' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expectedYieldController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Expected (kg/ha)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _actualYieldController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Actual (kg/ha)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Save Record Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
