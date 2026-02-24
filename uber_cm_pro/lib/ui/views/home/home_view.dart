import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // N'oublie pas l'import
import '../../../core/services/location_service.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/services/route_service.dart'; // AJOUT

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
  final RouteService _routeService = RouteService(); // AJOUT

  bool _isOnline = false;
  final LocationService _locationService = LocationService();
  final RideService _rideService = RideService();
  final String _driverId = "driver_001";

  StreamSubscription? _rideSubscription;

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
    // 1. Obtenir la position actuelle du chauffeur (Infinix)
    Position currentPos = await Geolocator.getCurrentPosition();
    LatLng driverLatLng = LatLng(currentPos.latitude, currentPos.longitude);

    // 2. Obtenir la position du client depuis Firebase
    LatLng clientLatLng = LatLng(
      rideData['pickup']['latitude'],
      rideData['pickup']['longitude'],
    );

    try {
      // 3. Calculer l'itinéraire
      RouteData data = await _routeService.getRoute(driverLatLng, clientLatLng);

      setState(() {
        // Tracer la ligne bleue
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route_to_client"),
            points: data.points,
            color: Colors.blue,
            width: 6,
          ),
        };

        // Ajouter le marqueur du client
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

      // 4. Zoomer sur l'itinéraire
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
        if (_isOnline) {
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
            onPressed: () {
              _rideService.acceptRide(rideData['requestId'], _driverId);
              Navigator.pop(context);
              // TRACER L'ITINÉRAIRE VERS LE CLIENT
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

  // --- LOGIQUE DE STATUT ---

  void _toggleStatus() {
    setState(() {
      _isOnline = !_isOnline;
      if (!_isOnline) {
        // Nettoyer la carte si on se déconnecte
        _polylines.clear();
        _markers.clear();
      }
    });

    if (_isOnline) {
      _locationService.startRealtimeTracking(_driverId);
    } else {
      _locationService.goOffline(_driverId);
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
            markers: _markers, // AJOUT
            polylines: _polylines, // AJOUT
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
}