import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LivestockForm extends StatefulWidget {
  final Map<String, dynamic>? livestock; // null = Create, not null = Edit

  const LivestockForm({super.key, this.livestock});

  @override
  State<LivestockForm> createState() => _LivestockFormState();
}

class _LivestockFormState extends State<LivestockForm> {
  final _formKey = GlobalKey<FormState>();

  DateTime? entryDate;
  DateTime? exitDate;

  Map<String, dynamic> livestockType = {};
  bool isLoading = true;
  String? errorMessage;

  late Map<String, dynamic> formData;

  static const Color mongoGreen = Color(0xFF00ED64);
  static const Color mongoDark = Color(0xFF001E2B);
  static const Color mongoGreenDark = Color(0xFF00684A);
  static const Color lightBg = Color(0xFFF9FBFA);
  static const Color softGray = Color(0xFFE8EDEB);

  bool get isEditMode => widget.livestock != null;

  @override
  void initState() {
    super.initState();

    formData = {
      "name": widget.livestock?['name'],
      "prod_start_year": widget.livestock?['prod_start_year']?.toString(),
      "prod_end_year": widget.livestock?['prod_end_year']?.toString(),
      "entry_date": widget.livestock?['entry_date'],
      "exit_date": widget.livestock?['exit_date'],
      "crop_yield": widget.livestock?['crop_yield']?.toString(),
      "prod_cost": widget.livestock?['prod_cost']?.toString(),
      "revenue": widget.livestock?['revenue']?.toString(),
      "profit": widget.livestock?['profit']?.toString(),
      "notes": widget.livestock?['notes'],
      "user_id": widget.livestock?['user_id'] ?? 1,
      "livestock_type_id": widget.livestock?['livestock_type_id'] ?? 1,
    };

    if (widget.livestock?['entry_date'] != null) {
      entryDate = DateTime.tryParse(widget.livestock!['entry_date'].toString());
    }
    if (widget.livestock?['exit_date'] != null) {
      exitDate = DateTime.tryParse(widget.livestock!['exit_date'].toString());
    }

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
          livestockType = Map<String, dynamic>.from(data['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load livestock types (${response.statusCode})';
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
          title: Text(isEditMode ? 'Edit Livestock' : 'Livestock Form'),
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
          title: Text(isEditMode ? 'Edit Livestock' : 'Livestock Form'),
        ),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: mongoDark,
        foregroundColor: Colors.white,
        title: Text(isEditMode ? 'Edit Livestock' : 'Livestock Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Livestock Name'),
              style: const TextStyle(color: mongoDark),
              dropdownColor: Colors.white,
              value: livestockType.containsKey(formData["name"])
                  ? formData["name"] as String?
                  : null,
              items: livestockType.keys
                  .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
              validator: (v) => v == null || v.isEmpty ? 'Please select a type' : null,
              onChanged: (value) {
                setState(() {
                  formData["name"] = value;
                  formData["livestock_type_id"] = livestockType[value];
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
            // Dates (same as crop)
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: mongoGreen,
                  foregroundColor: mongoDark,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      entryDate != null &&
                      exitDate != null) {
                    submitLivestockForm(
                      context,
                      formData,
                      isEditMode: isEditMode,
                      livestockId: widget.livestock?['id'],
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
                child: Text(isEditMode ? 'Update Livestock' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton(bool isEntered) {
    final date = isEntered ? entryDate : exitDate;
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
            if (isEntered) {
              entryDate = picked;
              formData["entry_date"] = picked;
            } else {
              exitDate = picked;
              formData["exit_date"] = picked;
            }
          });
        }
      },
      child: Text(
        date == null
            ? (isEntered ? 'Select Start Date *' : 'Select End Date *')
            : '${isEntered ? 'Start' : 'End'}: ${date.day}/${date.month}/${date.year}',
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

Future<void> submitLivestockForm(
  BuildContext context,
  Map<String, dynamic> data, {
  bool isEditMode = false,
  dynamic livestockId,
}) async {
  final url = isEditMode
      ? Uri.parse('http://127.0.0.1:8000/livestock/update')
      : Uri.parse('http://127.0.0.1:8000/livestock/create');

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
      "entry_date": formatDate(data['entry_date']),
      "exit_date": formatDate(data['exit_date']),
      "crop_yield": double.tryParse(data['crop_yield']?.toString() ?? ''),
      "prod_cost": double.tryParse(data['prod_cost']?.toString() ?? ''),
      "revenue": double.tryParse(data['revenue']?.toString() ?? ''),
      "profit": double.tryParse(data['profit']?.toString() ?? ''),
      "notes": data['notes'],
      "user_id": data['user_id'],
      "livestock_type_id": data['livestock_type_id'],
    };

    if (isEditMode && livestockId != null) {
      body["id"] = livestockId;
    }

    final response = isEditMode
        ? await http.patch(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        : await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

    if (response.statusCode == 200 || response.statusCode == 201) {
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