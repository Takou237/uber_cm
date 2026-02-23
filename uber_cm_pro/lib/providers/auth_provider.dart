import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String _userEmail = "";
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _language = "fr"; 
  String _selectedPreference = ""; 

  final String baseUrl = "https://uberbackend-production-e8ea.up.railway.app";

  AuthProvider() {
    _init();
  }

  // Initialisation : charge les données sauvegardées
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userEmail = prefs.getString('userEmail') ?? "";
    _language = prefs.getString('language') ?? "fr";
    notifyListeners();
  }

  // Getters
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get language => _language;
  String get selectedPreference => _selectedPreference;

  // Setters
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
    required String name, required String email,
    required String phone, required String city, String? referralCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/driver/register'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name, "email": email, "phone": phone,
          "city": city, "referral_code": referralCode,
        }),
      );

      _isLoading = false;
      if (response.statusCode == 201) {
        _userEmail = email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
        notifyListeners();
        return true;
      }
      log("Erreur: ${response.body}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 2. VÉRIFICATION OTP (Persiste la connexion ici)
  Future<bool> verifyDriverOTP(String code) async {
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
        _isLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout (Utile pour tes tests)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userEmail = "";
    notifyListeners();
  }
}