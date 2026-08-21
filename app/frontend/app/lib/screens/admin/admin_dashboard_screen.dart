import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/role_badge.dart';
import 'user_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _searchQuery = "";
  String _filter = "all"; // all | active | blocked | admins

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  List<UserModel> _applyFilters(List<UserModel> users) {
    var result = users;

    if (_filter == "active") {
      result = result.where((u) => u.isActive).toList();
    } else if (_filter == "blocked") {
      result = result.where((u) => !u.isActive).toList();
    } else if (_filter == "admins") {
      result = result.where((u) => u.role == "admin").toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((u) {
        return u.username.toLowerCase().contains(query) ||
            u.phoneNumber.contains(query);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    final allUsers = adminProvider.users;
    final activeCount = allUsers.where((u) => u.isActive).length;
    final blockedCount = allUsers.where((u) => !u.isActive).length;
    final adminCount = allUsers.where((u) => u.role == "admin").length;
    final filteredUsers = _applyFilters(allUsers);

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.fetchUsers(),
        child: adminProvider.isLoading && allUsers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.errorMessage != null && allUsers.isEmpty
                ? Center(child: Text(adminProvider.errorMessage!))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryCards(allUsers.length, activeCount, blockedCount, adminCount),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildFilterChips(),
                      const SizedBox(height: 16),
                      ...filteredUsers.map((user) => _buildUserTile(user)),
                      if (filteredUsers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text("No users found")),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSummaryCards(int total, int active, int blocked, int admins) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _summaryCard("Total Users", total.toString(), Colors.grey.shade100, Colors.black87),
        _summaryCard("Active Users", active.toString(), Colors.green.shade50, Colors.green.shade800),
        _summaryCard("Blocked", blocked.toString(), Colors.red.shade50, Colors.red.shade800),
        _summaryCard("Total Admins", admins.toString(), Colors.green.shade800, Colors.white, dark: true),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color bg, Color textColor, {bool dark = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 11, color: dark ? Colors.white70 : Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search by username or phone",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildFilterChips() {
    final filters = {
      "all": "All Users",
      "active": "Active",
      "blocked": "Blocked",
      "admins": "Admins",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          final selected = _filter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _filter = entry.key),
              selectedColor: Colors.green.shade100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?"),
        ),
        title: Text("${user.firstName} ${user.lastName}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.phoneNumber),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoleBadge(role: user.role),
                const SizedBox(width: 6),
                StatusBadge(isActive: user.isActive),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
          );
        },
      ),
    );
  }
}