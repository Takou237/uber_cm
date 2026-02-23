import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _userEmail = "";

  String get userEmail => _userEmail;

  // Sauvegarder l'email lors de l'inscription
  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

bool verifyOTP(String code) {
  // Simulons un code correct : "123456"
  return code == "123456";
}
}