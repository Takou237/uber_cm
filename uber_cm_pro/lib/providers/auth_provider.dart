import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String _userEmail = "";
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isProfileComplete = false; // ✅ Ajouté pour la redirection intelligente
  String _language = "fr";
  String _selectedPreference = "";

  final String baseUrl = "https://uberbackend-production-e8ea.up.railway.app";

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
    _userEmail = prefs.getString('userEmail') ?? "";
    _language = prefs.getString('language') ?? "fr";
    notifyListeners();
  }

  // --- Getters ---
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileComplete => _isProfileComplete;
  String get language => _language;
  String get selectedPreference => _selectedPreference;

  // --- Setters ---
  void setLanguage(String lang) {
    _language = lang;
    SharedPreferences.getInstance().then((p) => p.setString('language', lang));
    notifyListeners();
  }

  void setPreference(String pref) {
    _selectedPreference = pref;
    notifyListeners();
  }

  // 1. INSCRIPTION
  Future<bool> registerChauffeur({
    required String name,
    required String email,
    required String phone,
    required String city,
    String? referralCode,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/driver/register'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name,
          "email": email.trim().toLowerCase(), // ✅ Sécurité
          "phone": phone,
          "city": city,
          "referral_code": referralCode,
        }),
      );
      _isLoading = false;
      if (response.statusCode == 201 || response.statusCode == 200) {
        _userEmail = email.trim().toLowerCase();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', _userEmail);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erreur Register: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 2. CONNEXION (LOGIN) - Envoi de l'OTP
  Future<bool> loginChauffeur(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/driver/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email.trim().toLowerCase()}),
      );
      _isLoading = false;
      if (response.statusCode == 200) {
        _userEmail = email.trim().toLowerCase();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erreur Login: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. VÉRIFICATION OTP (Modifié pour retourner les données du chauffeur)
  Future<Map<String, dynamic>?> verifyDriverOTP(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/driver/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": _userEmail, "code": code}),
      );

      _isLoading = false;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _isLoggedIn = true;
        // ✅ On récupère si le profil est complet depuis le backend
        _isProfileComplete = data['isProfileComplete'] ?? false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isProfileComplete', _isProfileComplete);
        await prefs.setString('userEmail', _userEmail);

        notifyListeners();
        return data; // ✅ On retourne toutes les infos (id, name, etc.) pour le UserProvider
      }
      return null; // Échec
    } catch (e) {
      debugPrint("Erreur Verify OTP: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 4. ENVOI DOCUMENTS (Modifié pour retourner les données mises à jour)
  Future<Map<String, dynamic>?> completeVehicleRegistration({
    required String brand,
    required String model,
    required String year,
    required String color,
    required String plate,
    required Map<String, File?> files,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/auth/driver/complete-profile'),
      );

      request.fields['email'] = _userEmail;
      request.fields['brand'] = brand;
      request.fields['model'] = model;
      request.fields['year'] = year;
      request.fields['color'] = color;
      request.fields['plate'] = plate;
      request.fields['preference'] = _selectedPreference;

      for (var entry in files.entries) {
        if (entry.value != null) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value!.path),
          );
        }
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      var response = await http.Response.fromStream(streamedResponse);

      _isLoading = false;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(
          response.body,
        ); // ✅ On récupère le retour de Railway

        _isProfileComplete = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isProfileComplete', true);
        notifyListeners();
        return data; // ✅ On retourne les infos pour mettre à jour la plaque dans le UserProvider
      }
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint("Erreur Complete Registration: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 5. DÉCONNEXION
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _isProfileComplete = false;
    _userEmail = "";
    notifyListeners();
  }
}
