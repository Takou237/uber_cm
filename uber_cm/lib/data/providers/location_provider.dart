import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class LocationProvider extends ChangeNotifier {
  String _currentAddress = "Localisation en cours...";
  LatLng? _driverPosition;
  double _bearing = 0.0;

  // Getters
  String get currentAddress => _currentAddress;
  LatLng? get driverPosition => _driverPosition;
  double get bearing => _bearing;

  void updateAddress(String newAddress) {
    _currentAddress = newAddress;
    notifyListeners();
  }

  // ✅ NOUVEAU : Met à jour la position et calcule l'angle
  void updateDriverPosition(LatLng newPos) {
    if (_driverPosition != null) {
      // Calcule l'angle entre l'ancienne et la nouvelle position
      _bearing = _calculateBearing(_driverPosition!, newPos);
    }
    _driverPosition = newPos;
    notifyListeners();
  }

  // Fonction mathématique pour calculer la rotation (le "Bearing")
  double _calculateBearing(LatLng startPoint, LatLng endPoint) {
    double lat1 = startPoint.latitude * pi / 180;
    double lon1 = startPoint.longitude * pi / 180;
    double lat2 = endPoint.latitude * pi / 180;
    double lon2 = endPoint.longitude * pi / 180;

    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double brng = atan2(y, x);

    return (brng * 180 / pi + 360) % 360;
  }
}
