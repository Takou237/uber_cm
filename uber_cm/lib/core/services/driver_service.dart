import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    "drivers_online",
  );

  // Cette fonction renvoie un flux (Stream) de marqueurs pour la carte
  Stream<List<Marker>> getNearbyDrivers() {
    return _dbRef.onValue.map((event) {
      List<Marker> markers = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          markers.add(
            Marker(
              markerId: MarkerId(
                key,
              ), // C'est l'ID du chauffeur (ex: driver_001)
              position: LatLng(value['latitude'], value['longitude']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ), // Une voiture bleue pour le test
              infoWindow: InfoWindow(title: "Chauffeur Disponible"),
            ),
          );
        });
      }
      return markers;
    });
  }
}
