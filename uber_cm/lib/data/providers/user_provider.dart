import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = "Utilisateur";
  String _phone = "";

  String get name => _name;
  String get phone => _phone;

  // Charger les données sauvegardées
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? "Utilisateur";
    _phone = prefs.getString('user_phone') ?? "";
    notifyListeners();
  }

  // Sauvegarder les données (à appeler lors de l'inscription/connexion)
  Future<void> setUser(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);
    _name = name;
    _phone = phone;
    notifyListeners();
  }
}