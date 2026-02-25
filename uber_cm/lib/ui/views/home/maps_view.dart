import 'dart:async';
import 'dart:math'; // AJOUT pour les calculs de rotation
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:provider/provider.dart';
import 'destination_view.dart';
import '../../../core/services/route_service.dart';
import '../../../data/providers/driver_provider.dart';
//import '../../../data/providers/location_provider.dart'; // Pour ton LocationProvider
import 'dart:ui' as ui; // Nécessaire pour le redimensionnement
import 'package:flutter/services.dart';
import 'dart:typed_data'; // ✅ Indispensable pour utiliser Uint8List

// Modèle de véhicule basé sur la grille Yango Yaoundé
class VehicleType {
  final String name;
  final IconData icon;
  final double pricePerKm;
  final double baseFare;

  VehicleType({
    required this.name,
    required this.icon,
    required this.pricePerKm,
    required this.baseFare,
  });
}

class MapsView extends StatefulWidget {
  final String lang;
  const MapsView({super.key, this.lang = "EN"});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  final Completer<GoogleMapController> _controller =
      Completer(); // Mis à jour pour Animarker
  GoogleMapController? _mapController;
  String _currentAddress = "Localisation en cours...";
  String _startAddress = "";
  String _destinationAddress = "";
  LatLng? _userLocation;

  // --- VARIABLES POUR L'ANIMATION ET ROTATION ---
  Map<String, double> _driverRotations =
      {}; // Stocke la rotation de chaque chauffeur
  Map<String, LatLng> _prevDriverPositions =
      {}; // Pour comparer et calculer l'angle
  BitmapDescriptor? _carIcon; // L'icône de la voiture

  // LOGIQUE FIREBASE
  final DatabaseReference _driversRef = FirebaseDatabase.instance.ref().child(
    "drivers_online",
  );
  final DatabaseReference _rideRequestRef = FirebaseDatabase.instance
      .ref()
      .child("ride_requests");

  StreamSubscription<DatabaseEvent>? _rideStatusSubscription;

  bool _isRideAccepted = false;
  String _estimatedArrivalTime = "5";
  Map<dynamic, dynamic> _driverData = {};

  String _paymentMethod = "Espèces";
  IconData _paymentIcon = Icons.payments;

  int _selectedVehicleIndex = 1;
  final List<VehicleType> _vehicles = [
    VehicleType(
      name: "Moto",
      icon: Icons.motorcycle,
      pricePerKm: 150,
      baseFare: 100,
    ),
    VehicleType(
      name: "Éco",
      icon: Icons.directions_car,
      pricePerKm: 300,
      baseFare: 200,
    ),
    VehicleType(
      name: "Confort",
      icon: Icons.local_taxi,
      pricePerKm: 500,
      baseFare: 400,
    ),
  ];

  double _rawDistanceKm = 0;
  StreamSubscription<Position>? _positionStream;
  Set<Marker> _routeMarkers = {};
  Set<Polyline> _polylines = {};
  final RouteService _routeService = RouteService();

  static const CameraPosition _kInitialPos = CameraPosition(
    target: LatLng(3.8480, 11.5021),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarker(); // Charger l'image de la voiture au démarrage
  }

  // Charger l'icône de voiture personnalisée
  void _loadCustomMarker() async {
    // On charge l'image avec une largeur fixe de 100 pixels
    final Uint8List markerIcon = await getBytesFromAsset(
      'assets/images/car_top_view.png',
      100,
    );

    setState(() {
      _carIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _rideStatusSubscription?.cancel();
    super.dispose();
  }

  // --- CALCUL MATHÉMATIQUE DE LA ROTATION ---
  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  void _calculateETA(double driverLat, double driverLng) {
    if (_userLocation == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      driverLat,
      driverLng,
      _userLocation!.latitude,
      _userLocation!.longitude,
    );

    double distanceInKm = distanceInMeters / 1000;
    int minutes = (distanceInKm * 3 + 2).round();

    setState(() {
      _estimatedArrivalTime = minutes.toString();
    });
  }

  void _sendRideRequest() {
    if (_userLocation == null || _destinationAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une destination")),
      );
      return;
    }

    double finalPrice =
        _vehicles[_selectedVehicleIndex].baseFare +
        (_vehicles[_selectedVehicleIndex].pricePerKm * _rawDistanceKm);

    String requestId = _rideRequestRef.push().key!;

    Map<String, dynamic> requestData = {
      "requestId": requestId,
      "rider_name": "Arrel",
      "pickup": {
        "address": _startAddress.isEmpty ? _currentAddress : _startAddress,
        "latitude": _userLocation!.latitude,
        "longitude": _userLocation!.longitude,
      },
      "destination": {
        "address": _destinationAddress,
        "latitude": _routeMarkers
            .firstWhere((m) => m.markerId.value == "destination")
            .position
            .latitude,
        "longitude": _routeMarkers
            .firstWhere((m) => m.markerId.value == "destination")
            .position
            .longitude,
      },
      "status": "waiting",
      "price": finalPrice.toStringAsFixed(0),
      "vehicle_type": _vehicles[_selectedVehicleIndex].name,
      "created_at": ServerValue.timestamp,
    };

    _rideRequestRef.child(requestId).set(requestData).then((_) {
      _listenToRideStatus(requestId);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Recherche en cours"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFF04B5E)),
              SizedBox(height: 20),
              Text("Nous cherchons le chauffeur le plus proche..."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _rideStatusSubscription?.cancel();
                _rideRequestRef.child(requestId).remove();
                Navigator.pop(context);
              },
              child: const Text("Annuler", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    });
  }

  void _listenToRideStatus(String requestId) {
    _rideStatusSubscription = _rideRequestRef.child(requestId).onValue.listen((
      event,
    ) async {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        String status = data['status'];

        if (status == "accepted") {
          _rideStatusSubscription?.cancel();
          Navigator.pop(context);

          if (data['driver_id'] != null) {
            await Provider.of<DriverProvider>(
              context,
              listen: false,
            ).fetchDriverDetails(data['driver_id'].toString());
          }

          if (data['driver_lat'] != null && data['driver_lng'] != null) {
            _calculateETA(data['driver_lat'], data['driver_lng']);
          }

          setState(() {
            _isRideAccepted = true;
            _driverData = data;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Course acceptée ! Votre chauffeur est en route."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    });
  }

  void _calculatePrice() {
    if (_rawDistanceKm == 0) return;
    setState(() {});
  }

  void _resetNavigation() {
    setState(() {
      _polylines.clear();
      _routeMarkers.clear();
      _rawDistanceKm = 0;
      _destinationAddress = "";
      _startAddress = "";
      _isRideAccepted = false;
    });
    if (_userLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 16),
      );
    }
  }

  void _drawRoute(LatLng destination) async {
    if (_userLocation == null) return;
    try {
      RouteData data = await _routeService.getRoute(
        _userLocation!,
        destination,
      );
      _rawDistanceKm = data.distanceInMeters / 1000;
      setState(() {
        _calculatePrice();
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: data.points,
            color: const Color(0xFF4CAF50),
            width: 6,
          ),
        };
        _routeMarkers = {
          Marker(
            markerId: const MarkerId("origin"),
            position: _userLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
          Marker(
            markerId: const MarkerId("destination"),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });
    } catch (e) {
      debugPrint("Erreur itinéraire : $e");
    }
  }

  void _addDestinationMarker(Place place) {
    LatLng target = LatLng(place.lat, place.lon);
    setState(() {
      _startAddress = _currentAddress;
      _destinationAddress = place.displayName.split(',')[0];
    });
    _drawRoute(target);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 14));
  }

  void _handleMapTap(LatLng latLng) async {
    setState(() {
      _startAddress = _currentAddress;
      _destinationAddress = "Chargement...";
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _destinationAddress = placemarks[0].street ?? 'Lieu sélectionné';
        });
      }
    } catch (e) {
      setState(() => _destinationAddress = "Point sur la carte");
    }
    _drawRoute(latLng);
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  @override
  Widget build(BuildContext context) {
    bool isFR = widget.lang.toUpperCase() == "FR";
    bool hasRoute = _polylines.isNotEmpty;

    return Scaffold(
      body: StreamBuilder(
        stream: _driversRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          Set<Marker> allMarkers = Set.from(_routeMarkers);
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            var rawData = snapshot.data!.snapshot.value;
            Map<dynamic, dynamic> drivers = {};

            if (rawData is Map) {
              drivers = Map<dynamic, dynamic>.from(rawData);
            } else if (rawData is List) {
              for (int i = 0; i < rawData.length; i++) {
                if (rawData[i] != null) {
                  drivers[i.toString()] = rawData[i];
                }
              }
            }

            drivers.forEach((key, value) {
              LatLng currentPos = LatLng(value['latitude'], value['longitude']);

              // CALCUL DE LA ROTATION DYNAMIQUE
              if (_prevDriverPositions.containsKey(key)) {
                _driverRotations[key] = _calculateBearing(
                  _prevDriverPositions[key]!,
                  currentPos,
                );
              }
              _prevDriverPositions[key] = currentPos;

              allMarkers.add(
                Marker(
                  markerId: MarkerId(key),
                  position: currentPos,
                  rotation: _driverRotations[key] ?? 0.0, // ✅ Rotation !
                  anchor: const Offset(
                    0.5,
                    0.5,
                  ), // ✅ Rotation sur l'axe central
                  icon:
                      _carIcon ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow,
                      ),
                  infoWindow: const InfoWindow(title: "Chauffeur Uber CM"),
                ),
              );
            });
          }

          return Stack(
            children: [
              // ✅ AJOUT : GoogleMap avec markers gérés directement
              GoogleMap(
                initialCameraPosition: _kInitialPos,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _controller.complete(controller);
                  _determinePosition();
                },
                onTap: _handleMapTap,
                polylines: _polylines,
                markers: allMarkers,
              ),
              if (!hasRoute)
                Positioned(
                  top: 50,
                  left: 20,
                  child: _buildCircleButton(Icons.menu),
                ),
              if (hasRoute && !_isRideAccepted)
                Positioned(
                  bottom: 360,
                  left: 20,
                  child: _buildCircleButton(
                    Icons.arrow_back,
                    onTap: _resetNavigation,
                  ),
                ),
              if (!hasRoute)
                Positioned(
                  right: 20,
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      _buildCircleButton(
                        Icons.my_location,
                        onTap: _determinePosition,
                      ),
                      const SizedBox(height: 15),
                      _buildCircleButton(Icons.search, onTap: _openSearch),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _isRideAccepted
                    ? _buildDriverArrivingPanel(isFR)
                    : (hasRoute
                          ? _buildRideSelectionPanel(isFR)
                          : _buildBottomPanel(isFR)),
              ),
              if (!hasRoute)
                Positioned(
                  bottom: 275,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildScanButton()),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS UI (Inchauffés) ---

  Widget _buildDriverArrivingPanel(bool isFR) {
    final driverProv = Provider.of<DriverProvider>(context);
    final driver = driverProv.currentDriver;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFR ? "Le chauffeur arrive" : "Driver is arriving",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isFR
                              ? "Retrouvez-le au point de départ"
                              : "Meet your driver at the pick up spot",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111727),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$_estimatedArrivalTime\nmin",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: driver?.photoUrl != null
                          ? NetworkImage(driver!.photoUrl!)
                          : null,
                      child: driver?.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver?.name ?? "Chargement...",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            driver?.vehicle != null
                                ? "${driver!.vehicle} • ${driver.plate}"
                                : "Recherche véhicule...",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _buildCircleButton(Icons.phone, onTap: () {}),
                    const SizedBox(width: 10),
                    _buildCircleButton(Icons.message, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFR ? "code de vérification" : "verification code",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Text(
                        "2824",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildAddressRow(
                  Icons.radio_button_checked,
                  _startAddress.isEmpty ? _currentAddress : _startAddress,
                  Colors.grey,
                ),
                const SizedBox(height: 10),
                _buildAddressRow(
                  Icons.location_on,
                  _destinationAddress,
                  Colors.red,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _resetNavigation,
                    child: const Text(
                      "End Ride",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideSelectionPanel(bool isFR) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 15),
          _buildAddressRow(
            Icons.person,
            _startAddress.isEmpty ? _currentAddress : _startAddress,
            Colors.black87,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 35),
            child: Divider(height: 20),
          ),
          _buildAddressRow(Icons.flag, _destinationAddress, Colors.black87),
          const Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_vehicles.length, (index) {
                bool sel = _selectedVehicleIndex == index;
                double price =
                    _vehicles[index].baseFare +
                    (_vehicles[index].pricePerKm * _rawDistanceKm);
                return GestureDetector(
                  onTap: () => setState(() => _selectedVehicleIndex = index),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sel ? Colors.grey[100] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: sel ? Border.all(color: Colors.black12) : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _vehicles[index].icon,
                          color: sel ? Colors.black : Colors.grey,
                          size: 32,
                        ),
                        Text(
                          _vehicles[index].name,
                          style: TextStyle(
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Text(
                          "${price.toStringAsFixed(0)} F",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showPaymentModal,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(_paymentIcon, color: Colors.orange, size: 24),
                        const Icon(Icons.keyboard_arrow_up, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF04B5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: _sendRideRequest,
                    child: Text(
                      isFR ? "Commander" : "Order Now",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(bool isFR) {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Text(
              isFR ? "Salut, Arrel" : "Hey there, Arrel",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            Text(
              isFR ? "Où allez-vous ?" : "Where are you going?",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _openSearch,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black45),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFavoriteItem(
              Icons.home,
              isFR ? "Maison" : "Home",
              "4127 Mendong Street",
            ),
            const Divider(height: 25),
            _buildFavoriteItem(
              Icons.work,
              isFR ? "Travail" : "Work",
              "86706 Kuhic Trafficway",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String address, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111727),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner, color: Colors.pinkAccent),
          SizedBox(width: 10),
          Text(
            "Scan",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(IconData icon, String title, String address) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFF04B5E),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                address,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPayOption(
              "Orange Money",
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            _buildPayOption(
              "Mobile Money",
              Icons.vibration,
              Colors.yellow[800]!,
            ),
            _buildPayOption("Espèces", Icons.money, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPayOption(String name, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(name),
      trailing: Icon(
        _paymentMethod == name ? Icons.check_circle : Icons.circle_outlined,
        color: Colors.red,
      ),
      onTap: () => setState(() {
        _paymentMethod = name;
        _paymentIcon = icon;
        Navigator.pop(context);
      }),
    );
  }

  Future<void> _updateAddressFromCoords(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        setState(() {
          _currentAddress =
              "${placemarks[0].street}, ${placemarks[0].subLocality}";
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    _userLocation = LatLng(position.latitude, position.longitude);
    await _updateAddressFromCoords(position.latitude, position.longitude);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation!, 16.0),
    );
  }

  void _openSearch() async {
    final Place? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DestinationView(lang: widget.lang, currentAddress: _currentAddress),
      ),
    );
    if (result != null) _addDestinationMarker(result);
  }

  //

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    // 1. Chargement de l'image depuis les assets
    ByteData data = await rootBundle.load(path);

    // 2. Création du codec pour le redimensionnement
    // On ajoute .buffer ici 👇
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );

    ui.FrameInfo fi = await codec.getNextFrame();

    // 3. Conversion de l'image redimensionnée en octets PNG
    // On ajoute .buffer ici aussi 👇
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }
}
