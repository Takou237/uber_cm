import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  String _id = "";
  String _name = "Utilisateur";
  String _phone = "";
  String _email = "utilisateur@email.com";
  String? _profileImage; 
  File? _localImage; // ✅ Pour l'affichage instantané

  String get id => _id;
  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String? get profileImage => _profileImage;
  File? get localImage => _localImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('user_id') ?? "";
    _name = prefs.getString('user_name') ?? "Utilisateur";
    _phone = prefs.getString('user_phone') ?? "";
    _email = prefs.getString('user_email') ?? "utilisateur@email.com";
    _profileImage = prefs.getString('user_photo');
    notifyListeners();
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, 
      );

      if (pickedFile == null) return;

      // ✅ 1. Affichage local immédiat
      _localImage = File(pickedFile.path);
      notifyListeners();
      
      // 🚀 2. Envoi direct au Backend Railway
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://uberbackend-production-e8ea.up.railway.app/api/auth/upload-profile-pic')
      );

      // On ajoute l'ID ou le téléphone pour savoir à qui appartient l'image
      request.fields['phone'] = _phone;
      
      // On ajoute le fichier
      request.files.add(await http.MultipartFile.fromPath('image', _localImage!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String serverUrl = data['photo_url']; // L'URL renvoyée par ton serveur

        // 3. Sauvegarde de l'URL renvoyée
        _profileImage = serverUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo', serverUrl);
        
        // On peut vider le local une fois que le serveur a pris le relais
        _localImage = null; 
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur upload Railway: $e");
    }
  }

  Future<void> setUser(String id, String name, String phone, {String email = ""}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_email', email);
    _id = id; _name = name; _phone = phone; _email = email;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _id = ""; _name = "Utilisateur"; _phone = ""; _email = ""; _profileImage = null; _localImage = null;
    notifyListeners();
  }
}