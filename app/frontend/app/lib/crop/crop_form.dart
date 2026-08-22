import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_client.dart';

class CropForm extends StatefulWidget {
  final Map<String, dynamic>? crop; // null = Create, not null = Edit

  const CropForm({super.key, this.crop});

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  final _formKey = GlobalKey<FormState>();

  DateTime? plantedDate;
  DateTime? harvestDate;

  Map<String, dynamic> cropType = {};
  bool isLoading = true;
  String? errorMessage;

  late Map<String, dynamic> formData;

  static const Color mongoGreen = Color(0xFF00ED64);
  static const Color mongoDark = Color(0xFF001E2B);
  static const Color mongoGreenDark = Color(0xFF00684A);
  static const Color lightBg = Color(0xFFF9FBFA);

  bool get isEditMode => widget.crop != null;

  @override
  void initState() {
    super.initState();

    formData = {
      "name": widget.crop?['name'],
      "prod_start_year": widget.crop?['prod_start_year']?.toString(),
      "prod_end_year": widget.crop?['prod_end_year']?.toString(),
      "planted_date": widget.crop?['planted_date'],
      "harvest_date": widget.crop?['harvest_date'],
      "crop_yield": widget.crop?['crop_yield']?.toString(),
      "prod_cost": widget.crop?['prod_cost']?.toString(),
      "revenue": widget.crop?['revenue']?.toString(),
      "profit": widget.crop?['profit']?.toString(),
      "notes": widget.crop?['notes'],
      "crop_type_id": widget.crop?['crop_type_id'] ?? 1,
    };

    if (widget.crop?['planted_date'] != null) {
      plantedDate = DateTime.tryParse(widget.crop!['planted_date'].toString());
    }
    if (widget.crop?['harvest_date'] != null) {
      harvestDate = DateTime.tryParse(widget.crop!['harvest_date'].toString());
    }

    _loadCropTypes();
  }

  Future<void> _loadCropTypes() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get("/crop/crop_types");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            cropType = Map<String, dynamic>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message']?.toString() ?? 'Failed to load crop types';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load crop types (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: mongoDark,
          foregroundColor: Colors.white,
          title: Text(isEditMode ? 'Edit Crop' : 'Crop Form'),
        ),
        body: const Center(child: CircularProgressIndicator(color: mongoGreen)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: mongoDark,
          foregroundColor: Colors.white,
          title: Text(isEditMode ? 'Edit Crop' : 'Crop Form'),
        ),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: mongoDark,
        foregroundColor: Colors.white,
        title: Text(isEditMode ? 'Edit Crop' : 'Crop Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Crop Name'),
              style: const TextStyle(color: mongoDark),
              dropdownColor: Colors.white,
              value: cropType.containsKey(formData["name"]) ? formData["name"] as String? : null,
              items: cropType.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
              validator: (v) => v == null || v.isEmpty ? 'Please select a type' : null,
              onChanged: (value) {
                setState(() {
                  formData["name"] = value;
                  formData["crop_type_id"] = cropType[value];
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formData['prod_start_year'],
              decoration: _inputDecoration('Production Start Year'),
              keyboardType: TextInputType.number,
              validator: _yearValidator,
              onChanged: (v) => formData['prod_start_year'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formData['prod_end_year'],
              decoration: _inputDecoration('Production End Year'),
              keyboardType: TextInputType.number,
              validator: _yearValidator,
              onChanged: (v) => formData['prod_end_year'] = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dateButton(true)),
                const SizedBox(width: 16),
                Expanded(child: _dateButton(false)),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: formData["crop_yield"],
              decoration: _inputDecoration('Yield'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => formData["crop_yield"] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formData["prod_cost"],
              decoration: _inputDecoration('Production Cost'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => formData["prod_cost"] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formData["revenue"],
              decoration: _inputDecoration('Revenue'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => formData["revenue"] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formData["profit"],
              decoration: _inputDecoration('Profit'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => formData["profit"] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formData["notes"],
              decoration: _inputDecoration('Notes'),
              maxLines: 3,
              onChanged: (v) => formData["notes"] = v,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: mongoGreen, foregroundColor: mongoDark),
                onPressed: () {
                  if (_formKey.currentState!.validate() && plantedDate != null && harvestDate != null) {
                    submitCropForm(
                      context,
                      formData,
                      isEditMode: isEditMode,
                      cropId: widget.crop?['id'],
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields and dates'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(isEditMode ? 'Update Crop' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton(bool isPlanted) {
    final date = isPlanted ? plantedDate : harvestDate;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: mongoGreenDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: date ?? DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            if (isPlanted) {
              plantedDate = picked;
              formData["planted_date"] = picked;
            } else {
              harvestDate = picked;
              formData["harvest_date"] = picked;
            }
          });
        }
      },
      child: Text(
        date == null
            ? (isPlanted ? 'Select Planted Date *' : 'Select Harvest Date *')
            : '${isPlanted ? 'Planted' : 'Harvest'}: ${date.day}/${date.month}/${date.year}',
      ),
    );
  }

  String? _yearValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter year';
    final year = int.tryParse(value);
    if (year == null) return 'Invalid number';
    if (year < 1900 || year > 2200) return 'Year must be 1900-2200';
    return null;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: mongoGreen, width: 2),
      ),
    );
  }
}

Future<void> submitCropForm(
  BuildContext context,
  Map<String, dynamic> data, {
  bool isEditMode = false,
  dynamic cropId,
}) async {
  final apiClient = ApiClient();
  final path = isEditMode ? "/crop/update" : "/crop/create";

  String? formatDate(dynamic value) {
    if (value == null) return null;
    DateTime? date;
    if (value is DateTime) date = value;
    else if (value is String) date = DateTime.tryParse(value);
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  try {
    final body = {
      "name": data['name'],
      "prod_start_year": int.tryParse(data['prod_start_year']?.toString() ?? ''),
      "prod_end_year": int.tryParse(data['prod_end_year']?.toString() ?? ''),
      "planted_date": formatDate(data['planted_date']),
      "harvest_date": formatDate(data['harvest_date']),
      "crop_yield": double.tryParse(data['crop_yield']?.toString() ?? ''),
      "prod_cost": double.tryParse(data['prod_cost']?.toString() ?? ''),
      "revenue": double.tryParse(data['revenue']?.toString() ?? ''),
      "profit": double.tryParse(data['profit']?.toString() ?? ''),
      "notes": data['notes'],
      "crop_type_id": data['crop_type_id'],
    };

    if (isEditMode && cropId != null) {
      body["id"] = cropId;
    }

    final response = isEditMode
        ? await apiClient.patch(path, body: body)
        : await apiClient.post(path, body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditMode ? 'Updated successfully!' : 'Created successfully!'),
              backgroundColor: const Color(0xFF00ED64),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message']?.toString() ?? 'Failed to save'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}