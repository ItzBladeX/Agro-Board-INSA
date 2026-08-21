import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/role_badge.dart';
import 'user_detail_screen.dart';

// MongoDB LeafyGreen palette
const Color _mongoGreen = Color(0xFF00ED64);       // Primary leaf green
const Color _mongoGreenDark = Color(0xFF00684A);   // Forest / dark green
const Color _mongoGreenSoft = Color(0xFFE3FCF7);   // Soft green surface
const Color _mongoDark = Color(0xFF001E2B);        // Deep slate / text
const Color _mongoGrayLight = Color(0xFFF9FBFA);   // Light background
const Color _mongoGray = Color(0xFFE8EDEB);        // Subtle surface
const Color _mongoMuted = Color(0xFF5C6C75);       // Muted text

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
      backgroundColor: _mongoGrayLight,
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: _mongoDark,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _mongoDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: _mongoGreenDark,
        onRefresh: () => adminProvider.fetchUsers(),
        child: adminProvider.isLoading && allUsers.isEmpty
            ? const Center(child: CircularProgressIndicator(color: _mongoGreenDark))
            : adminProvider.errorMessage != null && allUsers.isEmpty
                ? Center(
                    child: Text(
                      adminProvider.errorMessage!,
                      style: const TextStyle(color: _mongoMuted),
                    ),
                  )
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
                          child: Center(
                            child: Text(
                              "No users found",
                              style: TextStyle(
                                color: _mongoMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
        _summaryCard("Total Users", total.toString(), _mongoGray, _mongoDark),
        _summaryCard("Active Users", active.toString(), _mongoGreenSoft, _mongoGreenDark),
        _summaryCard("Blocked", blocked.toString(), const Color(0xFFFCE8E8), const Color(0xFFCF000F)),
        _summaryCard("Total Admins", admins.toString(), _mongoGreenDark, Colors.white, dark: true),
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: dark ? Colors.white70 : _mongoMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      style: const TextStyle(color: _mongoDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: "Search by username or phone",
        hintStyle: const TextStyle(color: _mongoMuted),
        prefixIcon: const Icon(Icons.search, color: _mongoMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _mongoGreen, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
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
              label: Text(
                entry.value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? _mongoDark : _mongoMuted,
                ),
              ),
              selected: selected,
              onSelected: (_) => setState(() => _filter = entry.key),
              selectedColor: _mongoGreenSoft,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? _mongoGreen : _mongoGray,
              ),
              checkmarkColor: _mongoGreenDark,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _mongoGray),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _mongoGreenSoft,
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
            style: const TextStyle(
              color: _mongoGreenDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          "${user.firstName} ${user.lastName}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _mongoDark,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.phoneNumber,
              style: const TextStyle(color: _mongoMuted),
            ),
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