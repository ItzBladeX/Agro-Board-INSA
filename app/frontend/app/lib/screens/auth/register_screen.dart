import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _landAreaController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _landAreaController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final userData = <String, dynamic>{
      "username": _usernameController.text.trim(),
      "first_name": _firstNameController.text.trim(),
      "middle_name": _middleNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "passwd": _passwordController.text,
    };

    if (_birthDate != null) {
      userData["birth_date"] =
          "${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}";
    }
    if (_ageController.text.isNotEmpty) {
      userData["age"] = int.tryParse(_ageController.text);
    }
    if (_gender != null) {
      userData["gender"] = _gender;
    }
    if (_landAreaController.text.isNotEmpty) {
      userData["land_area"] = double.tryParse(_landAreaController.text);
    }

    final success = await authProvider.register(userData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful. Please log in.")),
      );
      Navigator.pop(context); // back to login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Registration failed")),
      );
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return "$label is required";
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Phone number is required";
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return "Enter a valid 10-digit number";
    if (!value.startsWith("09") && !value.startsWith("07")) {
      return "Must start with 09 or 07";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) return "At least 8 characters";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
              validator: (v) => _validateRequired(v, "Username"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder()),
              validator: (v) => _validateRequired(v, "First name"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _middleNameController,
              decoration: const InputDecoration(labelText: "Middle Name", border: OutlineInputBorder()),
              validator: (v) => _validateRequired(v, "Middle name"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder()),
              validator: (v) => _validateRequired(v, "Last name"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "0911234567",
                border: OutlineInputBorder(),
              ),
              validator: _validatePhone,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _pickBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Birth Date (optional)", border: OutlineInputBorder()),
                child: Text(
                  _birthDate != null
                      ? "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}"
                      : "Select date",
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Age (optional)", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: "Gender (optional)", border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: "M", child: Text("Male")),
                      DropdownMenuItem(value: "F", child: Text("Female")),
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _landAreaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Total Land Area in Hectares (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Register"),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}