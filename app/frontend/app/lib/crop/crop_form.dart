import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  late Map<String, dynamic> cropData;

  // ===== MongoDB LeafyGreen palette =====
  static const Color mongoGreen = Color(0xFF00ED64);
  static const Color mongoDark = Color(0xFF001E2B);
  static const Color mongoGreenDark = Color(0xFF00684A);
  static const Color lightBg = Color(0xFFF9FBFA);
  static const Color softGray = Color(0xFFE8EDEB);

  bool get isEditMode => widget.crop != null;

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if editing
    cropData = {
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
      "user_id": widget.crop?['user_id'] ?? 1,
      "crop_type_id": widget.crop?['crop_type_id'] ?? 1,
    };

    // Parse dates if they exist
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: mongoDark,
          foregroundColor: Colors.white,
          title: Text(
            isEditMode ? 'Edit Crop' : 'Crop Form',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
          title: Text(
            isEditMode ? 'Edit Crop' : 'Crop Form',
            style: const TextStyle(fontWeight: FontWeight.w600),
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

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: mongoDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditMode ? 'Edit Crop' : 'Crop Form',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
              initialValue: cropData['prod_start_year'],
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
              initialValue: cropData['prod_end_year'],
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

            // Dates
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
                        initialDate: plantedDate ?? DateTime.now(),
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
                          : 'Planted: ${plantedDate!.day}/${plantedDate!.month}/${plantedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        initialDate: harvestDate ?? DateTime.now(),
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
                          : 'Harvest: ${harvestDate!.day}/${harvestDate!.month}/${harvestDate!.year}',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Crop Yield
            TextFormField(
              initialValue: cropData["crop_yield"],
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
              initialValue: cropData["prod_cost"],
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
              initialValue: cropData["revenue"],
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
              initialValue: cropData["profit"],
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
              initialValue: cropData["notes"],
              decoration: _inputDecoration('Notes'),
              style: const TextStyle(color: mongoDark),
              maxLines: 3,
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
                          'Please fill all required fields and select both dates',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  submitCropForm(
                    context,
                    cropData,
                    isEditMode: isEditMode,
                    cropId: widget.crop?['id'],
                  );
                },
                child: Text(isEditMode ? 'Update Crop' : 'Submit'),
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
  Map<String, dynamic> data, {
  bool isEditMode = false,
  dynamic cropId,
}) async {
  final url = isEditMode
      ? Uri.parse('http://127.0.0.1:8000/crop/update')
      : Uri.parse('http://127.0.0.1:8000/crop/create');

  // Format date as "yyyy-MM-dd"
  String? formatDate(dynamic value) {
    if (value == null) return null;

    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) return null;

    // Return only the date part → "2026-08-21"
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  try {
    final body = {
      "name": data['name'],
      "prod_start_year": data['prod_start_year'] != null
          ? int.tryParse(data['prod_start_year'].toString())
          : null,
      "prod_end_year": data['prod_end_year'] != null
          ? int.tryParse(data['prod_end_year'].toString())
          : null,
      "planted_date": formatDate(data['planted_date']),
      "harvest_date": formatDate(data['harvest_date']),
      "crop_yield": data['crop_yield'] != null
          ? double.tryParse(data['crop_yield'].toString())
          : null,
      "prod_cost": data['prod_cost'] != null
          ? double.tryParse(data['prod_cost'].toString())
          : null,
      "revenue": data['revenue'] != null
          ? double.tryParse(data['revenue'].toString())
          : null,
      "profit": data['profit'] != null
          ? double.tryParse(data['profit'].toString())
          : null,
      "notes": data['notes'],
      "user_id": data['user_id'],
      "crop_type_id": data['crop_type_id'],
    };

    // Add id only when updating
    if (isEditMode && cropId != null) {
      body["id"] = cropId;
    }

    final response = isEditMode
        ? await http.patch(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          )
        : await http.post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? 'Updated successfully!' : 'Submitted successfully!',
            ),
            backgroundColor: const Color(0xFF00ED64),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${response.statusCode}'),
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
