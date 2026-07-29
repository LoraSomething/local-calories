// lib/utils/loading_dialog.dart
import 'package:flutter/material.dart';

class LoadingDialog {
  static BuildContext? _dialogContext;

  /// Shows an un-dismissible loading modal with custom text
  static void show(BuildContext context, {String message = 'Loading...'}) {
    if (_dialogContext != null) return; // Prevent duplicate dialogs

    showDialog(
      context: context,
      barrierDismissible: false, // 1. Prevents closing when tapping outside
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        _dialogContext = dialogContext;

        return PopScope(
          canPop: false, // 2. Prevents closing via hardware back button/swipe
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Closes the active loading dialog safely
  static void hide() {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
    }
  }
}