import 'package:flutter/material.dart';

import './models/livestock_model.dart';

class LivestockForm extends StatefulWidget {
  const LivestockForm({super.key, required this.onSubmit});

  final ValueChanged<LivestockRecord> onSubmit;

  @override
  State<LivestockForm> createState() => _LivestockFormState();
}

class _LivestockFormState extends State<LivestockForm> {
  final _formKey = GlobalKey<FormState>();
  final _feedController = TextEditingController();
  final _outputController = TextEditingController();
  String? _species;
  String _health = 'Healthy';

  @override
  void dispose() {
    _feedController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      LivestockRecord(
        species: _species!,
        feedKgPerDay: double.parse(_feedController.text),
        outputLitersPerDay: double.parse(_outputController.text),
        health: _health,
      ),
    );

    _formKey.currentState!.reset();
    setState(() {
      _species = null;
      _health = 'Healthy';
    });
    _feedController.clear();
    _outputController.clear();
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
              'Add livestock data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            DropdownButtonFormField<String>(
              initialValue: _species,
              decoration: const InputDecoration(labelText: 'Species'),
              items: const ['Cattle', 'Goat', 'Sheep']
                  .map(
                    (species) =>
                        DropdownMenuItem(value: species, child: Text(species)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _species = value),
              validator: (value) => value == null ? 'Select a species.' : null,
            ),
            TextFormField(
              controller: _feedController,
              decoration: const InputDecoration(
                labelText: 'Feed used (kg/day)',
              ),
              keyboardType: TextInputType.number,
              validator: _positiveNumber,
            ),
            TextFormField(
              controller: _outputController,
              decoration: const InputDecoration(labelText: 'Output (L/day)'),
              keyboardType: TextInputType.number,
              validator: _positiveNumber,
            ),
            DropdownButtonFormField<String>(
              initialValue: _health,
              decoration: const InputDecoration(labelText: 'Health'),
              items: const ['Healthy', 'Moderate', 'Needs attention']
                  .map(
                    (health) =>
                        DropdownMenuItem(value: health, child: Text(health)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _health = value!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add livestock'),
            ),
          ],
        ),
      ),
    ),
  );

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number <= 0
        ? 'Enter a number greater than zero.'
        : null;
  }
}
