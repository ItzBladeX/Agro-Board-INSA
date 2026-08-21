import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LivestockForm extends StatefulWidget {
  const LivestockForm({super.key});

  @override
  State<LivestockForm> createState() => _LivestockFormState();
}

class _LivestockFormState extends State<LivestockForm> {
  final _formKey = GlobalKey<FormState>();

  DateTime? entryDate;
  DateTime? exitDate;

  Map<String, dynamic> livestockTypes = {};
  bool isLoading = true;
  String? errorMessage;

  final Map<String, dynamic> livestockData = {
    "name": null,
    "prod_start_year": null,
    "prod_end_year": null,
    "entry_date": null,
    "exit_date": null,
    "livestock_num": null,
    "prod_cost": null,
    "revenue": null,
    "profit": null,
    "notes": null,
    "user_id": 1,
    "livestock_type_id": 1,
  };

  // ===== MongoDB LeafyGreen + App Green palette =====
  static const Color mongoGreen = Color(0xFF00ED64);     // Bright MongoDB green
  static const Color mongoDark = Color(0xFF001E2B);      // Dark evergreen
  static const Color mongoGreenDark = Color(0xFF00684A); // Deep green
  static const Color lightBg = Color(0xFFF9FBFA);        // Very light background
  static const Color softGray = Color(0xFFE8EDEB);       // Soft border gray

  @override
  void initState() {
    super.initState();
    _loadLivestockTypes();
  }

  Future<void> _loadLivestockTypes() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/livestock/livestock_types'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          livestockTypes = Map<String, dynamic>.from(data['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load livestock types (${response.statusCode})';
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
            'Livestock Form',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: mongoGreen),
        ),
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
            'Livestock Form',
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
          'Livestock Form',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Livestock Name
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Livestock Name'),
              style: const TextStyle(color: mongoDark),
              dropdownColor: Colors.white,
              value: livestockData["name"],
              items: livestockTypes.keys.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a livestock type';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  livestockData["name"] = value;
                  livestockData["livestock_type_id"] = livestockTypes[value];
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
              onChanged: (value) => livestockData['prod_start_year'] = value,
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
              onChanged: (value) => livestockData['prod_end_year'] = value,
            ),

            const SizedBox(height: 8),

            // Entry Date
            Row(children: [
              Expanded(child: 
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: mongoGreenDark,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0))
                
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
                    entryDate = picked;
                    livestockData["entry_date"] = picked;
                  });
                }
              },
              child: Text(
                entryDate == null
                    ? 'Select Entry Date *'
                    : 'Entry Date: ${entryDate!.day}/${entryDate!.month}/${entryDate!.year}',
              ),
            ),
              ),
            const SizedBox(width: 24),
            Expanded(child: 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: mongoGreenDark,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
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
                    exitDate = picked;
                    livestockData["exit_date"] = picked;
                  });
                }
              },
              child: Text(
                exitDate == null
                    ? 'Select Exit Date *'
                    : 'Exit Date: ${exitDate!.day}/${exitDate!.month}/${exitDate!.year}',
              ),
            ),
            ),


            ],),
            
            // Exit Date
            
            const SizedBox(height: 24),

            // Livestock Number
            TextFormField(
              decoration: _inputDecoration('Livestock Number'),
              style: const TextStyle(color: mongoDark),
              keyboardType: TextInputType.number,
              onChanged: (value) => livestockData["livestock_num"] = value,
            ),

            const SizedBox(height: 12),

            // Production Cost
            TextFormField(
              decoration: _inputDecoration('Productoin Cost in ETB'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => livestockData["prod_cost"] = value,
            ),

            const SizedBox(height: 12),

            // Revenue
            TextFormField(
              decoration: _inputDecoration('Revenue in ETB'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => livestockData["revenue"] = value,
            ),

            const SizedBox(height: 12),

            // Profit
            TextFormField(
              decoration: _inputDecoration('Profit in ETB'),
              style: const TextStyle(color: mongoDark),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => livestockData["profit"] = value,
            ),

            const SizedBox(height: 12),

            // Notes
            TextFormField(
              decoration: _inputDecoration('Notes'),
              style: const TextStyle(color: mongoDark),
              onChanged: (value) => livestockData["notes"] = value,
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
                  final datesValid = entryDate != null && exitDate != null;

                  if (!formValid || !datesValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Incorrect fields – please select both dates'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  submitLivestockForm(context, livestockData);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Consistent input style
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

Future<void> submitLivestockForm(
  BuildContext context,
  Map<String, dynamic> data,
) async {
  final url = Uri.parse('http://127.0.0.1:8000/livestock/create');

  try {
    final body = {
      'name': data['name'],
      'prod_start_year': data['prod_start_year'] != null
          ? int.tryParse(data['prod_start_year'].toString())
          : null,
      'prod_end_year': data['prod_end_year'] != null
          ? int.tryParse(data['prod_end_year'].toString())
          : null,
      'entry_date': (data['entry_date'] as DateTime?)?.toIso8601String(),
      'exit_date': (data['exit_date'] as DateTime?)?.toIso8601String(),
      'livestock_num': data['livestock_num'] != null
          ? int.tryParse(data['livestock_num'].toString())
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
      'livestock_type_id': data['livestock_type_id'],
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