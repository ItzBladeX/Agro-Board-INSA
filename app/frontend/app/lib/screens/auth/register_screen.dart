import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// MongoDB LeafyGreen Design System colors
class _LeafyGreen {
  static const Color black = Color(0xFF001E2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grayDark3 = Color(0xFF21313C);
  static const Color grayDark2 = Color(0xFF3D4F58);
  static const Color grayDark1 = Color(0xFF5C6C75);
  static const Color grayBase = Color(0xFF889397);
  static const Color grayLight1 = Color(0xFFC1C7C6);
  static const Color grayLight2 = Color(0xFFE8EDEB);
  static const Color grayLight3 = Color(0xFFF9FBFA);
  static const Color greenDark3 = Color(0xFF023430);
  static const Color greenDark2 = Color(0xFF00684A);
  static const Color greenDark1 = Color(0xFF00A35C);
  static const Color greenBase = Color(0xFF00ED64);
  static const Color greenLight1 = Color(0xFF71F6BA);
  static const Color greenLight2 = Color(0xFFC0FAE6);
  static const Color greenLight3 = Color(0xFFE3FCF7);
}

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _LeafyGreen.greenDark2,
              onPrimary: _LeafyGreen.white,
              surface: _LeafyGreen.white,
              onSurface: _LeafyGreen.black,
            ),
          ),
          child: child!,
        );
      },
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
        const SnackBar(
          content: Text("Registration successful. Please log in."),
          backgroundColor: _LeafyGreen.greenDark2,
        ),
      );
      Navigator.pop(context); // back to login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Registration failed"),
          backgroundColor: const Color(0xFFDB3030), // LeafyGreen red
        ),
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

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: _LeafyGreen.grayDark1,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(color: _LeafyGreen.grayBase),
      filled: true,
      fillColor: _LeafyGreen.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _LeafyGreen.grayLight1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _LeafyGreen.grayLight1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _LeafyGreen.greenDark2, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFDB3030)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFDB3030), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Theme(
      data: ThemeData(
        fontFamily: 'Roboto', // Clean sans-serif close to Euclid Circular A
        primaryColor: _LeafyGreen.greenBase,
        scaffoldBackgroundColor: _LeafyGreen.grayLight3,
        appBarTheme: const AppBarTheme(
          backgroundColor: _LeafyGreen.black,
          foregroundColor: _LeafyGreen.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: _LeafyGreen.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _LeafyGreen.greenDark2,
            foregroundColor: _LeafyGreen.white,
            disabledBackgroundColor: _LeafyGreen.grayLight1,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _LeafyGreen.greenDark2,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: _LeafyGreen.grayDark1),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Register")),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Username"),
                validator: (v) => _validateRequired(v, "Username"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _firstNameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("First Name"),
                validator: (v) => _validateRequired(v, "First name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _middleNameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Middle Name"),
                validator: (v) => _validateRequired(v, "Middle name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Last Name"),
                validator: (v) => _validateRequired(v, "Last name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Phone Number", hint: "0911234567"),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: _LeafyGreen.grayDark1,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: _inputDecoration("Birth Date (optional)"),
                  child: Text(
                    _birthDate != null
                        ? "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}"
                        : "Select date",
                    style: TextStyle(
                      color: _birthDate != null ? _LeafyGreen.black : _LeafyGreen.grayBase,
                    ),
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
                      style: const TextStyle(color: _LeafyGreen.black),
                      decoration: _inputDecoration("Age (optional)"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecoration("Gender (optional)"),
                      dropdownColor: _LeafyGreen.white,
                      style: const TextStyle(color: _LeafyGreen.black),
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
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Total Land Area in Hectares (optional)"),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _LeafyGreen.white,
                        ),
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
      ),
    );
  }
}