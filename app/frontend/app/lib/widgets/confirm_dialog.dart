import 'package:flutter/material.dart';

// MongoDB LeafyGreen palette
const Color _mongoGreen = Color(0xFF00ED64);
const Color _mongoGreenDark = Color(0xFF00684A);
const Color _mongoDark = Color(0xFF001E2B);
const Color _mongoMuted = Color(0xFF5C6C75);
const Color _mongoGray = Color(0xFFE8EDEB);
const Color _destructive = Color(0xFFCF000F);

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "Confirm",
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _mongoGray),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: _mongoDark,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: _mongoMuted,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: _mongoMuted,
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? _destructive : _mongoGreenDark,
          ),
          child: Text(
            confirmText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}