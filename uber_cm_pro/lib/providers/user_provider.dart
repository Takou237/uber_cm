import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _id = "";
  String _name = "Chauffeur";
  String _phone = "";
  String _plate = "";

  // Getters pour lire les données n'importe où
  String get id => _id;
  String get name => _name;
  String get phone => _phone;
  String get plate => _plate;

  // Vérifier si un chauffeur est connecté
  bool get isAuthenticated => _id.isNotEmpty;

  // 1. CHARGER les données au démarrage de l'application
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('driver_id') ?? "";
    _name = prefs.getString('driver_name') ?? "Chauffeur";
    _phone = prefs.getString('driver_phone') ?? "";
    _plate = prefs.getString('driver_plate') ?? "";
    notifyListeners();
  }

  // 2. SAUVEGARDER les données (À appeler quand le chauffeur réussit à se connecter / Login)
  Future<void> saveUserData({
    required String id,
    required String name,
    required String phone,
    required String plate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Sauvegarde dans la mémoire du téléphone
    await prefs.setString('driver_id', id);
    await prefs.setString('driver_name', name);
    await prefs.setString('driver_phone', phone);
    await prefs.setString('driver_plate', plate);

    // Mise à jour des variables en direct
    _id = id;
    _name = name;
    _phone = phone;
    _plate = plate;

    notifyListeners();
  }

  // 3. DÉCONNEXION (Efface la mémoire)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Vide tout

    _id = "";
    _name = "Chauffeur";
    _phone = "";
    _plate = "";

    notifyListeners();
  }
}
