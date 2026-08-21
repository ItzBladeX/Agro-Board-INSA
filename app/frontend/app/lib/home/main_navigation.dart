import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

import './home.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

// import '../crop/crop_screen.dart';
// import '../livestock/livestock_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    // -------------------------
    // Loading
    // -------------------------
    if (profileProvider.isLoading &&
        profileProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // -------------------------
    // Error
    // -------------------------
    if (profileProvider.errorMessage != null &&
        profileProvider.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileProvider.errorMessage!),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  profileProvider.fetchProfile();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // -------------------------
    // Check admin
    // -------------------------
    final isAdmin = profileProvider.user?.role == "admin";

    // -------------------------
    // Screens
    // -------------------------
    final List<Widget> screens;

    if (isAdmin) {
      screens = const [
        HomePage(),
        // CropScreen(),
        // LivestockScreen(),
        AdminDashboardScreen(),
        ProfileScreen(),
      ];
    } else {
      screens = const [
        HomePage(),
        // CropScreen(),
        // LivestockScreen(),
        ProfileScreen(),
      ];
    }

    // -------------------------
    // Navigation items
    // -------------------------
    final List<BottomNavigationBarItem> navItems;

    if (isAdmin) {
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.grass),
          label: "Crop",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: "LiveStock",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    } else {
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.grass),
          label: "Crop",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: "LiveStock",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ];
    }

    // Safety check
    final safeIndex =
        _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: screens[safeIndex],

      // -------------------------
      // Bottom navigation
      // -------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,

        selectedItemColor: const Color(0xFF008060),

        unselectedItemColor: Colors.grey,

        selectedFontSize: 16,

        unselectedFontSize: 14,

        showUnselectedLabels: true,

        elevation: 0,

        items: navItems,
      ),
    );
  }
}