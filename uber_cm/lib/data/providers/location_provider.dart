import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _currentAddress = "Localisation en cours...";
  String get currentAddress => _currentAddress;

  void updateAddress(String newAddress) {
    _currentAddress = newAddress;
    notifyListeners(); // Informe l'UI du changement
  }
}