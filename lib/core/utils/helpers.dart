import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class Helpers {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return AppColors.pending;
      case AppConstants.statusConfirmed:
        return AppColors.confirmed;
      case AppConstants.statusCompleted:
        return AppColors.completed;
      case AppConstants.statusCancelled:
        return AppColors.cancelled;
      default:
        return AppColors.textMuted;
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return AppColors.warningLight;
      case AppConstants.statusConfirmed:
        return AppColors.primarySurface;
      case AppConstants.statusCompleted:
        return AppColors.successLight;
      case AppConstants.statusCancelled:
        return AppColors.errorLight;
      default:
        return AppColors.scaffold;
    }
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Delete',
    Color confirmColor = AppColors.error,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String truncate(String s, {int length = 40}) {
    if (s.length <= length) return s;
    return '${s.substring(0, length)}...';
  }
}
