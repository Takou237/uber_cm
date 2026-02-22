import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Cette fonction demande les permissions et commence à écouter le GPS
  void startRealtimeTracking(String driverId) async {
    // 1. Vérification des permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. Paramètres de suivi (Précision haute, mise à jour tous les 5 mètres)
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    // 3. Écoute du flux de positions
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((
      Position position,
    ) {
      // 4. Envoi direct à Firebase Realtime Database
      _dbRef.child("drivers_online").child(driverId).set({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "last_update": ServerValue.timestamp,
        "status": "available",
      });
    });
  }

  // Pour arrêter le partage quand le chauffeur se déconnecte
  void goOffline(String driverId) {
    _dbRef.child("drivers_online").child(driverId).remove();
  }
}
