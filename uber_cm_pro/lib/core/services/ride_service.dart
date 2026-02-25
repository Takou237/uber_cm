import 'package:firebase_database/firebase_database.dart';

class RideService {
  final DatabaseReference _rideRequestRef = FirebaseDatabase.instance
      .ref()
      .child("ride_requests");

  // On écoute uniquement les nouvelles demandes en attente
  Stream<DatabaseEvent> getNewRideRequests() {
    return _rideRequestRef
        .orderByChild("status")
        .equalTo("waiting")
        .onChildAdded;
  }

  // Fonction pour accepter la course
  Future<void> acceptRide(
    String requestId,
    String driverId,
    double lat,
    double lng,
  ) async {
    await _rideRequestRef.child(requestId).update({
      "status": "accepted",
      "driver_id": driverId,
      "driver_lat": lat, // AJOUT : On envoie la position du chauffeur
      "driver_lng": lng, // AJOUT : On envoie la position du chauffeur
    });
  }
}
