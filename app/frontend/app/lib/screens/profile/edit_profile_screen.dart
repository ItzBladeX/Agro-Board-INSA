import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _landAreaController;
  DateTime? _birthDate;
  String? _gender;

  bool _showPasswordSection = false;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<ProfileProvider>().user;
      _usernameController = TextEditingController(text: user?.username ?? "");
      _firstNameController = TextEditingController(text: user?.firstName ?? "");
      _middleNameController = TextEditingController(text: user?.middleName ?? "");
      _lastNameController = TextEditingController(text: user?.lastName ?? "");
      _phoneController = TextEditingController(text: user?.phoneNumber ?? "");
      _ageController = TextEditingController(text: user?.age?.toString() ?? "");
      _landAreaController = TextEditingController(text: user?.landArea?.toString() ?? "");
      _gender = user?.gender;
      _birthDate = user?.birthDate != null ? DateTime.tryParse(user!.birthDate!) : null;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _landAreaController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Color(0xFFDB3030),
        ),
      );
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user;
    final changes = <String, dynamic>{};

    // only include fields that actually changed
    if (_usernameController.text != user?.username) {
      changes["username"] = _usernameController.text;
    }
    if (_firstNameController.text != user?.firstName) {
      changes["first_name"] = _firstNameController.text;
    }
    if (_middleNameController.text != user?.middleName) {
      changes["middle_name"] = _middleNameController.text;
    }
    if (_lastNameController.text != user?.lastName) {
      changes["last_name"] = _lastNameController.text;
    }
    if (_phoneController.text != user?.phoneNumber) {
      changes["phone_number"] = _phoneController.text;
    }
    if (_ageController.text.isNotEmpty &&
        int.tryParse(_ageController.text) != user?.age) {
      changes["age"] = int.tryParse(_ageController.text);
    }
    if (_landAreaController.text.isNotEmpty &&
        double.tryParse(_landAreaController.text) != user?.landArea) {
      changes["land_area"] = double.tryParse(_landAreaController.text);
    }
    if (_gender != user?.gender) {
      changes["gender"] = _gender;
    }
    if (_birthDate != null) {
      final formatted =
          "${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}";
      if (formatted != user?.birthDate) {
        changes["birth_date"] = formatted;
      }
    }
    if (_newPasswordController.text.isNotEmpty) {
      changes["passwd"] = _newPasswordController.text;
    }

    if (changes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No changes to save"),
          backgroundColor: _LeafyGreen.grayDark1,
        ),
      );
      return;
    }

    final success = await profileProvider.updateProfile(changes);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: _LeafyGreen.greenDark2,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.errorMessage ?? "Update failed"),
          backgroundColor: const Color(0xFFDB3030),
        ),
      );
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // optional on update
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return "Enter a valid 10-digit number";
    if (!value.startsWith("09") && !value.startsWith("07")) {
      return "Must start with 09 or 07";
    }
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
    final profileProvider = context.watch<ProfileProvider>();

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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _LeafyGreen.greenDark2,
            side: const BorderSide(color: _LeafyGreen.greenDark2),
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
        expansionTileTheme: const ExpansionTileThemeData(
          textColor: _LeafyGreen.black,
          iconColor: _LeafyGreen.greenDark2,
          collapsedTextColor: _LeafyGreen.black,
          collapsedIconColor: _LeafyGreen.grayDark1,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _LeafyGreen.black,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Username"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _firstNameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("First Name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _middleNameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Middle Name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameController,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Last Name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Phone Number"),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: _inputDecoration("Birth Date"),
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
                      decoration: _inputDecoration("Age"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: _inputDecoration("Gender"),
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
              const SizedBox(height: 24),

              const Text(
                "Agricultural Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _LeafyGreen.black,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _landAreaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: _LeafyGreen.black),
                decoration: _inputDecoration("Total Land Area (Hectares)"),
              ),
              const SizedBox(height: 24),

              ExpansionTile(
                title: const Text(
                  "Change Password",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onExpansionChanged: (expanded) => setState(() => _showPasswordSection = expanded),
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: _LeafyGreen.black),
                    decoration: _inputDecoration("New Password"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: _LeafyGreen.black),
                    decoration: _inputDecoration("Confirm New Password"),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: profileProvider.isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: profileProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _LeafyGreen.white,
                        ),
                      )
                    : const Text("Save Changes"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}