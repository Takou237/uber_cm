import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart'; // AJOUT : pour mettre à jour le statut
import '../../../core/services/location_service.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/services/route_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // CONFIGURATION MAPS & NAVIGATION
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final RouteService _routeService = RouteService();

  bool _isOnline = false;
  final LocationService _locationService = LocationService();
  final RideService _rideService = RideService();

  StreamSubscription? _rideSubscription;

  // --- NOUVELLES VARIABLES POUR GÉRER LA COURSE EN COURS ---
  bool _hasActiveRide = false;
  Map<dynamic, dynamic>? _activeRideData;
  String _rideStep = ""; // Peut être "accepted", "arrived", "in_progress"

  @override
  void initState() {
    super.initState();
    _listenForRides();
  }

  @override
  void dispose() {
    _rideSubscription?.cancel();
    super.dispose();
  }

  // --- LOGIQUE DE NAVIGATION VERS LE CLIENT ---

  Future<void> _getRouteToClient(Map<dynamic, dynamic> rideData) async {
    Position currentPos = await Geolocator.getCurrentPosition();
    LatLng driverLatLng = LatLng(currentPos.latitude, currentPos.longitude);

    LatLng clientLatLng = LatLng(
      rideData['pickup']['latitude'],
      rideData['pickup']['longitude'],
    );

    try {
      RouteData data = await _routeService.getRoute(driverLatLng, clientLatLng);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route_to_client"),
            points: data.points,
            color: Colors.blue,
            width: 6,
          ),
        };

        _markers = {
          Marker(
            markerId: const MarkerId("client_pickup"),
            position: clientLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(title: "Client : ${rideData['rider_name']}"),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(clientLatLng, 15),
      );
    } catch (e) {
      debugPrint("Erreur itinéraire chauffeur : $e");
    }
  }

  // --- LOGIQUE D'ÉCOUTE DES COMMANDES ---

  void _listenForRides() {
    _rideSubscription = _rideService.getNewRideRequests().listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        // N'afficher l'alerte que si le chauffeur est en ligne ET n'a pas déjà une course
        if (_isOnline && !_hasActiveRide && data['status'] == 'waiting') {
          _showRideDialog(data);
        }
      }
    });
  }

  void _showRideDialog(Map<dynamic, dynamic> rideData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("NOUVELLE COURSE !"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "👤 Client : ${rideData['rider_name']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("📍 Départ : ${rideData['pickup']['address']}"),
            const SizedBox(height: 5),
            const Divider(),
            Text(
              "💰 Prix : ${rideData['price']} F CFA",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("REFUSER", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            // CORRECTION DE L'ERREUR ICI : async + ajout de la position + 4 arguments
            onPressed: () async {
              // 1. Obtenir la position pour le calcul de l'ETA chez le client
              Position currentPos = await Geolocator.getCurrentPosition();

              // 2. Mettre un ID de chauffeur réel (Ex: "1" ou "driver_001" selon ta BDD Railway)
              String realDriverId = "1";

              // 3. Appel de la fonction avec les 4 ARGUMENTS attendus !
              await _rideService.acceptRide(
                rideData['requestId'],
                realDriverId,
                currentPos.latitude,
                currentPos.longitude,
              );

              Navigator.pop(context);

              // 4. Activer le panneau de la course en cours
              setState(() {
                _hasActiveRide = true;
                _activeRideData = rideData;
                _rideStep = "accepted";
              });

              // 5. TRACER L'ITINÉRAIRE VERS LE CLIENT
              _getRouteToClient(rideData);
            },
            child: const Text(
              "ACCEPTER",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- MISE À JOUR DU STATUT DE LA COURSE ---

  Future<void> _updateRideStatus(String newStatus) async {
    if (_activeRideData == null) return;
    String reqId = _activeRideData!['requestId'];

    // Mise à jour sur Firebase pour que le client le voie en direct
    await FirebaseDatabase.instance
        .ref()
        .child("ride_requests")
        .child(reqId)
        .update({"status": newStatus});

    setState(() {
      _rideStep = newStatus;
    });

    // Si la course est terminée, on nettoie tout
    if (newStatus == "completed") {
      setState(() {
        _hasActiveRide = false;
        _activeRideData = null;
        _rideStep = "";
        _polylines.clear();
        _markers.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course terminée avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- LOGIQUE DE STATUT EN LIGNE ---

  void _toggleStatus() {
    setState(() {
      _isOnline = !_isOnline;
      if (!_isOnline) {
        _polylines.clear();
        _markers.clear();
      }
    });

    if (_isOnline) {
      // Met ici l'ID de ton chauffeur
      _locationService.startRealtimeTracking("1");
    } else {
      _locationService.goOffline("1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.8480, 11.5021),
              zoom: 14,
            ),
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: _isOnline ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Text(
                _isOnline ? "VOUS ÊTES EN LIGNE" : "VOUS ÊTES HORS LIGNE",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // AFFICHAGE DU PANNEAU DE COURSE EN COURS
          if (_hasActiveRide)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildActiveRidePanel(),
            ),
        ],
      ),
      // On cache le bouton "Passer en Ligne/Hors ligne" s'il a une course en cours
      floatingActionButton: _hasActiveRide
          ? null
          : FloatingActionButton.extended(
              onPressed: _toggleStatus,
              backgroundColor: const Color(0xFF111727),
              label: Text(
                _isOnline ? "DÉCONNEXION" : "GO ! (PASSER EN LIGNE)",
                style: const TextStyle(color: Colors.white),
              ),
              icon: Icon(
                _isOnline ? Icons.power_settings_new : Icons.local_taxi,
                color: Colors.white,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- UI : PANNEAU DE COURSE EN COURS ---

  Widget _buildActiveRidePanel() {
    String buttonText = "";
    Color buttonColor = Colors.blue;
    String nextStatus = "";

    // Changement du bouton en fonction de l'étape
    if (_rideStep == "accepted") {
      buttonText = "JE SUIS ARRIVÉ";
      buttonColor = Colors.orange;
      nextStatus = "arrived";
    } else if (_rideStep == "arrived") {
      buttonText = "DÉMARRER LA COURSE";
      buttonColor = Colors.green;
      nextStatus = "in_progress";
    } else if (_rideStep == "in_progress") {
      buttonText = "TERMINER LA COURSE";
      buttonColor = Colors.red;
      nextStatus = "completed";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Client: ${_activeRideData?['rider_name'] ?? 'Inconnu'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Colors.green),
                    SizedBox(width: 5),
                    Text("Appeler"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${_activeRideData?['destination']['address'] ?? 'Destination...'}",
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => _updateRideStatus(nextStatus),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
