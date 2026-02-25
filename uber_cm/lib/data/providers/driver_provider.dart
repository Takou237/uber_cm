import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './models/driver_model.dart'; // Assure-toi que le chemin est correct

class DriverProvider with ChangeNotifier {
  DriverModel? _currentDriver;
  bool _isLoading = false;

  DriverModel? get currentDriver => _currentDriver;
  bool get isLoading => _isLoading;

  // Ton endpoint Railway fonctionnel
  final String apiUrl =
      "https://uberbackend-production-e8ea.up.railway.app/chauffeurs";

  Future<void> fetchDriverDetails(String driverId) async {
    _isLoading = true;
    _currentDriver = null;
    notifyListeners();

    try {
      debugPrint("Appel Railway pour le chauffeur: $driverId");
      final response = await http.get(Uri.parse('$apiUrl/$driverId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _currentDriver = DriverModel.fromJson(data);
      } else {
        // SI L'ID N'EXISTE PAS SUR RAILWAY (Erreur 404 ou 500)
        debugPrint("Erreur Railway : Code ${response.statusCode}");
        _currentDriver = DriverModel(
          id: driverId,
          name: "Chauffeur non trouvé",
          vehicle: "ID $driverId introuvable",
          plate: "ERREUR BD",
        );
      }
    } catch (e) {
      debugPrint("Erreur de connexion Railway : $e");
      // SI LE SERVEUR RAILWAY EST ÉTEINT OU INACCESSIBLE
      _currentDriver = DriverModel(
        id: driverId,
        name: "Serveur Hors Ligne",
        vehicle: "Railway éteint ?",
        plate: "---",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optionnel : Pour vider les données quand la course est terminée
  void clearDriverData() {
    _currentDriver = null;
    notifyListeners();
  }
}
