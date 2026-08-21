import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CropForm extends StatefulWidget {
  const CropForm({super.key});

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

  final Map<String, dynamic> cropData = {
    "name": null,
    "prod_start_year": null,
    "prod_end_year": null,
    "planted_date": null,
    "harvest_date": null,
    "crop_yield": null,
    "prod_cost": null,
    "revenue": null,
    "profit": null,
    "notes": null,
    "user_id": 1,
    "crop_type_id": 1,
  };

  // ===== MongoDB LeafyGreen palette =====
  static const Color mongoGreen = Color(0xFF00ED64);
  static const Color mongoDark = Color(0xFF001E2B);
  static const Color mongoGreenDark = Color(0xFF00684A);
  static const Color lightBg = Color(0xFFF9FBFA);
  static const Color softGray = Color(0xFFE8EDEB);

  @override
  void initState() {
    super.initState();
    _loadCropTypes();
  }

  Future<void> _loadCropTypes() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/crop/crop_types'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cropType = Map<String, dynamic>.from(data['data']);
          isLoading = false;
        });
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
    // Loading
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: mongoDark,
          foregroundColor: Colors.white,
          title: const Text(
            'Crop Form',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: mongoGreen)),
      );
    }

    // Error
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: mongoDark,
          foregroundColor: Colors.white,
          title: const Text(
            'Crop Form',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: mongoDark, fontSize: 16),
          ),
        ),
      );
    }

    // Main form
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: mongoDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Crop Form',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Crop Name
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Crop Name'),
              style: const TextStyle(color: mongoDark),
              dropdownColor: Colors.white,
              value: cropData["name"],
              items: cropType.keys.map((String name) {
                return DropdownMenuItem<String>(value: name, child: Text(name));
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a crop type';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  cropData["name"] = value;
                  cropData["crop_type_id"] = cropType[value];
                });
              },
            ),

            const SizedBox(height: 12),

            // Production Start Year
            TextFormField(
              decoration: _inputDecoration('Production Start Year'),
              style: const TextStyle(color: mongoDark),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter year';
                final year = int.tryParse(value);
                if (year == null) return 'Please enter a valid number';
                if (year < 1900 || year > 2200) {
                  return 'Year must be between 1900 & 2200';
                }
                return null;
              },
              onChanged: (value) => cropData['prod_start_year'] = value,
            ),

            const SizedBox(height: 12),

            // Production End Year
            TextFormField(
              decoration: _inputDecoration('Production End Year'),
              style: const TextStyle(color: mongoDark),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter year';
                final year = int.tryParse(value);
                if (year == null) return 'Please enter a valid number';
                if (year < 1900 || year > 2200) {
                  return 'Year must be between 1900 & 2200';
                }
                return null;
              },
              onChanged: (value) => cropData['prod_end_year'] = value,
            ),

            const SizedBox(height: 8),

            // Planted Date
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: mongoGreenDark,
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: mongoGreen,
                                onPrimary: mongoDark,
                                surface: Colors.white,
                                onSurface: mongoDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          plantedDate = picked;
                          cropData["planted_date"] = picked;
                        });
                      }
                    },
                    child: Text(
                      plantedDate == null
                          ? 'Select Planted Date *'
                          : 'Planted Date: ${plantedDate!.day}/${plantedDate!.month}/${plantedDate!.year}',
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: mongoGreenDark,
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: mongoGreen,
                                onPrimary: mongoDark,
                                surface: Colors.white,
                                onSurface: mongoDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          harvestDate = picked;
                          cropData["harvest_date"] = picked;
                        });
                      }
                    },
                    child: Text(
                      harvestDate == null
                          ? 'Select Harvest Date *'
                          : 'Harvest Date: ${harvestDate!.day}/${harvestDate!.month}/${harvestDate!.year}',
                    ),
                  ),
                ),
              ],
            ),

            // Harvest Date
            const SizedBox(height: 24),

            // Crop Yield
            TextFormField(
              decoration: _inputDecoration('Crop Yield in Kg'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => cropData["crop_yield"] = value,
            ),

            const SizedBox(height: 12),

            // Production Cost
            TextFormField(
              decoration: _inputDecoration('Prod Cost in ETB'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => cropData["prod_cost"] = value,
            ),

            const SizedBox(height: 12),

            // Revenue
            TextFormField(
              decoration: _inputDecoration('Revenue in ETB'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => cropData["revenue"] = value,
            ),

            const SizedBox(height: 12),

            // Profit
            TextFormField(
              decoration: _inputDecoration('Profit in ETB'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => cropData["profit"] = value,
            ),

            const SizedBox(height: 12),

            // Notes
            TextFormField(
              decoration: _inputDecoration('Notes'),
              style: const TextStyle(color: mongoDark),
              onChanged: (value) => cropData["notes"] = value,
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mongoGreen,
                  foregroundColor: mongoDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  final formValid = _formKey.currentState!.validate();
                  final datesValid = plantedDate != null && harvestDate != null;

                  if (!formValid || !datesValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Incorrect fields – please select both dates',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  submitCropForm(context, cropData);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: mongoDark),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: softGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: softGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: mongoGreen, width: 2),
      ),
    );
  }
}

Future<void> submitCropForm(
  BuildContext context,
  Map<String, dynamic> data,
) async {
  final url = Uri.parse('http://127.0.0.1:8000/crop/create');

  try {
    final body = {
      'name': data['name'],
      'prod_start_year': data['prod_start_year'] != null
          ? int.tryParse(data['prod_start_year'].toString())
          : null,
      'prod_end_year': data['prod_end_year'] != null
          ? int.tryParse(data['prod_end_year'].toString())
          : null,
      'planted_date': (data['planted_date'] as DateTime?)?.toIso8601String(),
      'harvest_date': (data['harvest_date'] as DateTime?)?.toIso8601String(),
      'crop_yield': data['crop_yield'] != null
          ? double.tryParse(data['crop_yield'].toString())
          : null,
      'prod_cost': data['prod_cost'] != null
          ? double.tryParse(data['prod_cost'].toString())
          : null,
      'revenue': data['revenue'] != null
          ? double.tryParse(data['revenue'].toString())
          : null,
      'profit': data['profit'] != null
          ? double.tryParse(data['profit'].toString())
          : null,
      'notes': data['notes'],
      'user_id': data['user_id'],
      'crop_type_id': data['crop_type_id'],
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submitted successfully!'),
            backgroundColor: Color(0xFF00ED64),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print(response.body);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
