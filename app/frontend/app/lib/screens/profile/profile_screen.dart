import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // fetch profile once when this screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
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
          iconTheme: IconThemeData(color: _LeafyGreen.white),
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
        // Only color — leave elevation, shape, margin etc. untouched
        cardTheme: const CardThemeData(
          color: _LeafyGreen.white,
        ),
        dividerTheme: const DividerThemeData(
          color: _LeafyGreen.grayLight2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Profile"),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: profileProvider.user == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
        body: _buildBody(profileProvider),
      ),
    );
  }

  Widget _buildBody(ProfileProvider profileProvider) {
    if (profileProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _LeafyGreen.greenDark2,
        ),
      );
    }

    if (profileProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profileProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _LeafyGreen.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => profileProvider.fetchProfile(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final user = profileProvider.user;
    if (user == null) {
      return const Center(
        child: Text(
          "No profile data",
          style: TextStyle(color: _LeafyGreen.grayDark1),
        ),
      );
    }

    return RefreshIndicator(
      color: _LeafyGreen.greenDark2,
      onRefresh: () => profileProvider.fetchProfile(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _LeafyGreen.greenDark2,
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 32,
                  color: _LeafyGreen.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "${user.firstName} ${user.middleName} ${user.lastName}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _LeafyGreen.black,
              ),
            ),
          ),
          Center(
            child: Text(
              "@${user.username}",
              style: const TextStyle(color: _LeafyGreen.grayDark1),
            ),
          ),
          const SizedBox(height: 24),

          _infoCard("Personal Details", [
            _infoRow("First Name", user.firstName),
            _infoRow("Middle Name", user.middleName),
            _infoRow("Last Name", user.lastName),
            _infoRow("Gender", user.gender ?? "-"),
          ]),

          _infoCard("Contact & Demographics", [
            _infoRow("Phone Number", user.phoneNumber),
            _infoRow("Birth Date", user.birthDate ?? "-"),
            _infoRow("Age", user.age?.toString() ?? "-"),
          ]),

          _infoCard("Agricultural Data", [
            _infoRow("Total Land Area", "${user.landArea ?? 0} Hectares"),
          ]),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _LeafyGreen.black,
              ),
            ),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: _LeafyGreen.grayDark1),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: _LeafyGreen.black,
            ),
          ),
        ],
      ),
    );
  }
}