import 'package:flutter/material.dart';

/// A utility class for displaying reusable multiline text input dialogs.
class InputDialog {
  /// Displays a non-dismissible or dismissible multiline text input dialog 
  /// and returns the entered string, or `null` if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String hintText = 'Type your message here...',
    String initialValue = '',
    String confirmButtonText = 'OK',
    String cancelButtonText = 'Cancel',
    int minLines = 4,
    int? maxLines,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevents closing accidentally by tapping outside
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true, // Set to false if you want to force an explicit Cancel tap
          child: AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite, // Ensures maximum available width in dialog
              child: TextField(
                controller: controller,
                autofocus: true,
                
                // Multiline text configurations
                minLines: minLines,
                maxLines: maxLines, // null = expands indefinitely
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                
                decoration: InputDecoration(
                  hintText: hintText,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12.0),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Return null on cancellation
                  Navigator.of(dialogContext).pop(null);
                },
                child: Text(cancelButtonText),
              ),
              FilledButton(
                onPressed: () {
                  // Return trimmed text value on confirmation
                  Navigator.of(dialogContext).pop(controller.text.trim());
                },
                child: Text(confirmButtonText),
              ),
            ],
          ),
        );
      },
    );
  }
}