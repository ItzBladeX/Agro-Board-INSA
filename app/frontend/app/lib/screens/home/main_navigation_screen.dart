import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'home_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
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

    if (profileProvider.isLoading && profileProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileProvider.errorMessage != null && profileProvider.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileProvider.errorMessage!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => profileProvider.fetchProfile(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final isAdmin = profileProvider.user?.role == "admin";

    final screens = isAdmin
        ? const [HomeScreen(), AdminDashboardScreen(), ProfileScreen()]
        : const [HomeScreen(), ProfileScreen()];

    final navItems = isAdmin
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: screens[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
        selectedItemColor: Colors.green.shade800,
      ),
    );
  }
}