import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/confirm_dialog.dart';

// MongoDB LeafyGreen palette
const Color _mongoGreen = Color(0xFF00ED64);
const Color _mongoGreenDark = Color(0xFF00684A);
const Color _mongoGreenSoft = Color(0xFFE3FCF7);
const Color _mongoDark = Color(0xFF001E2B);
const Color _mongoMuted = Color(0xFF5C6C75);
const Color _mongoGray = Color(0xFFE8EDEB);
const Color _mongoGrayLight = Color(0xFFF9FBFA);
const Color _destructive = Color(0xFFCF000F);

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  String? _selectedRole;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ensure we know who the logged-in admin actually is, for self-action checks
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.user == null) {
        profileProvider.fetchProfile();
      }
    });
  }

  bool get _isOwnAccount {
    final myId = context.watch<ProfileProvider>().user?.id;
    return myId != null && myId == widget.user.id;
  }

  Future<void> _handleBlockToggle() async {
    final isCurrentlyActive = widget.user.isActive;
    final confirmed = await showConfirmDialog(
      context: context,
      title: isCurrentlyActive ? "Block this user?" : "Unblock this user?",
      message: isCurrentlyActive
          ? "This user will no longer be able to log in."
          : "This user will regain access to their account.",
      confirmText: isCurrentlyActive ? "Block" : "Unblock",
      isDestructive: isCurrentlyActive,
    );

    if (!confirmed) return;

    setState(() => _actionInProgress = true);
    final adminProvider = context.read<AdminProvider>();
    final result = isCurrentlyActive
        ? await adminProvider.blockUser(widget.user.id)
        : await adminProvider.unblockUser(widget.user.id);
    setState(() => _actionInProgress = false);

    if (!mounted) return;
    _showResultAndMaybePop(result);
  }

  Future<void> _handleRoleUpdate() async {
    if (_selectedRole == widget.user.role) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: "Change role to '$_selectedRole'?",
      message: "This changes what this user can access on the platform.",
      confirmText: "Update Role",
    );

    if (!confirmed) return;

    setState(() => _actionInProgress = true);
    final result = await context.read<AdminProvider>().updateUserRole(widget.user.id, _selectedRole!);
    setState(() => _actionInProgress = false);

    if (!mounted) return;
    _showResultAndMaybePop(result);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: "Delete this account?",
      message: "This permanently removes all data for this user. This cannot be undone.",
      confirmText: "Delete",
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _actionInProgress = true);
    final result = await context.read<AdminProvider>().deleteUser(widget.user.id);
    setState(() => _actionInProgress = false);

    if (!mounted) return;
    _showResultAndMaybePop(result);
  }

  void _showResultAndMaybePop(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"] ?? (result["success"] ? "Done" : "Action failed")),
        backgroundColor: _mongoDark,
      ),
    );
    if (result["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: _mongoGrayLight,
      appBar: AppBar(
        title: const Text(
          "User Details",
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: _mongoGreenSoft,
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _mongoGreenDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "${user.firstName} ${user.lastName}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: _mongoDark,
              ),
            ),
          ),
          Center(
            child: Text(
              "@${user.username}",
              style: const TextStyle(color: _mongoMuted),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoleBadge(role: user.role),
                const SizedBox(width: 8),
                StatusBadge(isActive: user.isActive),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _infoCard("Demographics", [
            _infoRow("Phone Number", user.phoneNumber),
            _infoRow("Birth Date", user.birthDate ?? "-"),
            _infoRow("Age", user.age?.toString() ?? "-"),
            _infoRow("Gender", user.gender ?? "-"),
          ]),

          _infoCard("Agricultural Data", [
            _infoRow("Total Land Area", "${user.landArea ?? 0} Hectares"),
          ]),

          if (_isOwnAccount)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: _mongoGreenSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _mongoGray),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: _mongoGreenDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This is your own account. Administration controls are hidden.",
                      style: TextStyle(
                        fontSize: 13,
                        color: _mongoDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            const SizedBox(height: 8),
            _buildAdminControls(user),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminControls(UserModel user) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _mongoGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Administration Controls",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.2,
                color: _mongoDark,
              ),
            ),
            const Divider(color: _mongoGray),

            const Text(
              "System Role",
              style: TextStyle(color: _mongoMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _mongoGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _mongoGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _mongoGreen, width: 1.5),
                      ),
                      filled: true,
                      fillColor: _mongoGrayLight,
                    ),
                    style: const TextStyle(
                      color: _mongoDark,
                      fontWeight: FontWeight.w500,
                    ),
                    items: const [
                      DropdownMenuItem(value: "user", child: Text("User")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _actionInProgress ? null : _handleRoleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mongoGreenDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Account Status",
              style: TextStyle(color: _mongoMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _actionInProgress ? null : _handleBlockToggle,
              icon: Icon(user.isActive ? Icons.block : Icons.check_circle_outline),
              label: Text(user.isActive ? "Block User" : "Unblock User"),
              style: OutlinedButton.styleFrom(
                foregroundColor: user.isActive ? const Color(0xFFB45309) : _mongoGreenDark,
                side: BorderSide(
                  color: user.isActive ? const Color(0xFFB45309) : _mongoGreenDark,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _actionInProgress ? null : _handleDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text("Delete Account"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _destructive,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _mongoGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.2,
                color: _mongoDark,
              ),
            ),
            const Divider(color: _mongoGray),
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
            style: const TextStyle(color: _mongoMuted, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: _mongoDark,
            ),
          ),
        ],
      ),
    );
  }
}