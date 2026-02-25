import 'dart:async'; // Indispensable pour le StreamSubscription
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // NOUVEAU : On sauvegarde la connexion au GPS pour pouvoir l'arrêter
  StreamSubscription<Position>? _positionStream;

  // Cette fonction demande les permissions et commence à écouter le GPS
  Future<void> startRealtimeTracking(String driverId) async {
    // 1. Vérification des permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint("Les permissions GPS sont refusées définitivement.");
      return;
    }

    try {
      // 2. CORRECTION CLÉ : Prendre la position tout de suite !
      // Cela évite d'attendre que le chauffeur bouge de 5 mètres
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateFirebasePosition(driverId, initialPosition);

      // 3. Paramètres de suivi (Précision haute, mise à jour tous les 5 mètres)
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      // 4. Écoute du flux de positions (et sauvegarde du flux)
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            _updateFirebasePosition(driverId, position);
          });
    } catch (e) {
      debugPrint("Erreur lors de la récupération du GPS : $e");
    }
  }

  // NOUVEAU : Fonction factorisée pour écrire dans Firebase proprement
  void _updateFirebasePosition(String driverId, Position position) {
    _dbRef.child("drivers_online").child(driverId).set({
      "latitude": position.latitude,
      "longitude": position.longitude,
      "last_update": ServerValue.timestamp,
      "status": "available",
    });
  }

  // Pour arrêter le partage quand le chauffeur se déconnecte
  void goOffline(String driverId) {
    // CORRECTION CLÉ : On éteint l'écoute du capteur GPS pour économiser la batterie
    _positionStream?.cancel();

    // On efface le chauffeur de la carte
    _dbRef.child("drivers_online").child(driverId).remove();
  }
}
