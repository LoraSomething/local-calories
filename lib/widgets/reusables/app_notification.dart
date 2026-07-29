import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/globals.dart';

class AppNotification {
  
  static void showInfo(String message) {
    snackbarKey.currentState?.hideCurrentSnackBar();
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  static void showSucces(String message) {
    snackbarKey.currentState?.hideCurrentSnackBar();
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
  
  static void showError(String message) {
    snackbarKey.currentState?.hideCurrentSnackBar();
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}