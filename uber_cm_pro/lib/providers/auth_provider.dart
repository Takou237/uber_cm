import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class AuthProvider extends ChangeNotifier {
  String _userEmail = "";
  bool _isLoading = false;

  // ✅ URL corrigée : Pas de slash à la fin pour éviter les erreurs 404
  final String baseUrl = "https://uberbackend-production-e8ea.up.railway.app";

  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  // 1. INSCRIPTION CHAUFFEUR
  Future<bool> registerChauffeur({
    required String name,
    required String email,
    required String phone,
    required String city,
    String? referralCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/auth/driver/register');

    try {
      log("🚀 Tentative d'inscription vers : $url");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name,
          "email": email,
          "phone": phone,
          "city": city,
          "referral_code": referralCode,
        }),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        _userEmail = email; 
        log("✅ Inscription réussie !");
        return true;
      } else {
        // C'est ici que tu verras la vraie erreur si ça échoue encore
        log("❌ Erreur Serveur (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      log("⚠️ Erreur Réseau critique : $e");
      return false;
    }
  }

  // 2. VÉRIFICATION OTP CHAUFFEUR
  Future<bool> verifyDriverOTP(String code) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/auth/driver/verify-otp');

    try {
      log("🚀 Vérification OTP pour : $_userEmail");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": _userEmail,
          "code": code,
        }),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        log("✅ OTP Validé !");
        return true;
      } else {
        log("❌ OTP Incorrect ou expiré : ${response.body}");
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      log("⚠️ Erreur Réseau OTP : $e");
      return false;
    }
  }
}