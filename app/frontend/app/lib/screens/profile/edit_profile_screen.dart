import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

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
        const SnackBar(content: Text("Passwords do not match")),
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
        const SnackBar(content: Text("No changes to save")),
      );
      return;
    }

    final success = await profileProvider.updateProfile(changes);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profileProvider.errorMessage ?? "Update failed")),
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

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _middleNameController,
              decoration: const InputDecoration(labelText: "Middle Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
              validator: _validatePhone,
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _pickBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Birth Date", border: OutlineInputBorder()),
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
                    decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _landAreaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Total Land Area (Hectares)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ExpansionTile(
              title: const Text("Change Password"),
              onExpansionChanged: (expanded) => setState(() => _showPasswordSection = expanded),
              children: [
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Confirm New Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: profileProvider.isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: profileProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save Changes"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}