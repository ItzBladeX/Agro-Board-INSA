import 'package:flutter/material.dart';

class EditCropPage extends StatefulWidget {
  final Map<String, dynamic> crop;

  const EditCropPage({super.key, required this.crop});

  @override
  State<EditCropPage> createState() => _EditCropPageState();
}

class _EditCropPageState extends State<EditCropPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _yieldController;
  late TextEditingController _profitController;
  late TextEditingController _revenueController;
  late TextEditingController _prodCostController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.crop['name']?.toString() ?? '',
    );
    _yieldController = TextEditingController(
      text: widget.crop['crop_yield']?.toString() ?? '',
    );
    _profitController = TextEditingController(
      text: widget.crop['profit']?.toString() ?? '',
    );
    _revenueController = TextEditingController(
      text: widget.crop['revenue']?.toString() ?? '',
    );
    _prodCostController = TextEditingController(
      text: widget.crop['prod_cost']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yieldController.dispose();
    _profitController.dispose();
    _revenueController.dispose();
    _prodCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.crop['name'] ?? 'Crop'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yieldController,
                decoration: const InputDecoration(
                  labelText: 'Crop Yield',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Yield is required';
                  }
                  final number = double.tryParse(value);
                  if (number == null) {
                    return 'Enter a valid number';
                  }
                  if (number < 0) {
                    return 'Yield cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _profitController,
                decoration: const InputDecoration(
                  labelText: 'Profit',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Profit is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _revenueController,
                decoration: const InputDecoration(
                  labelText: 'Revenue',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Revenue is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prodCostController,
                decoration: const InputDecoration(
                  labelText: 'Production Cost',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Production cost is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updated = {
        ...widget.crop,
        'name': _nameController.text.trim(),
        'crop_yield': _yieldController.text.trim(),
        'profit': _profitController.text.trim(),
        'revenue': _revenueController.text.trim(),
        'prod_cost': _prodCostController.text.trim(),
      };

      // TODO: Call your update API here with `updated`
      // Example:
      // await http.put(Uri.parse('http://127.0.0.1:8000/crop/update'), body: jsonEncode(updated));

      Navigator.pop(context, updated);
    }
  }
}