import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'destination_view.dart';
import '../../../core/services/route_service.dart';

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
  GoogleMapController? _mapController;
  String _currentAddress = "Localisation en cours..."; // Position GPS live
  String _startAddress = ""; // Adresse fixe du point de départ pour le trajet
  String _destinationAddress = ""; // Adresse de destination
  LatLng? _userLocation;

  // LOGIQUE PAIEMENT
  String _paymentMethod = "Espèces";
  IconData _paymentIcon = Icons.payments;

  // LOGIQUE VEHICULES
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
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final RouteService _routeService = RouteService();

  static const CameraPosition _kInitialPos = CameraPosition(
    target: LatLng(3.8480, 11.5021),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // --- LOGIQUE DE CALCUL & NAVIGATION ---

  void _calculatePrice() {
    if (_rawDistanceKm == 0) return;
    setState(() {
      // Le prix est recalculé automatiquement dans l'UI via _rawDistanceKm
    });
  }

  void _resetNavigation() {
    setState(() {
      _polylines.clear();
      _markers.clear();
      _rawDistanceKm = 0;
      _destinationAddress = "";
      _startAddress = "";
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

        _markers = {
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

  // Sélection via recherche
  void _addDestinationMarker(Place place) {
    LatLng target = LatLng(place.lat, place.lon);
    setState(() {
      _startAddress = _currentAddress; // On fige le départ
      _destinationAddress = place.displayName.split(',')[0];
    });
    _drawRoute(target);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 14));
  }

  // Sélection via clic carte
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
        Placemark place = placemarks[0];
        setState(() {
          _destinationAddress = place.street ?? place.name ?? 'Lieu sélectionné';
        });
      }
    } catch (e) {
      setState(() => _destinationAddress = "Point sur la carte");
    }

    _drawRoute(latLng);
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  // --- MODAL PAIEMENT ---

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
            const Text(
              "Modes de paiement",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF04B5E),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Terminer",
                style: TextStyle(color: Colors.white),
              ),
            ),
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

  // --- INTERFACE (UI) ---

  @override
  Widget build(BuildContext context) {
    bool isFR = widget.lang.toUpperCase() == "FR";
    bool hasRoute = _polylines.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kInitialPos,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _determinePosition();
            },
            onTap: _handleMapTap,
          ),

          // BOUTON MENU (En haut)
          if (!hasRoute)
            Positioned(
              top: 50,
              left: 20,
              child: _buildCircleButton(Icons.menu),
            ),

          // FLÈCHE RETOUR (Au dessus du panneau)
          if (hasRoute)
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
            child: hasRoute
                ? _buildRideSelectionPanel(isFR)
                : _buildBottomPanel(isFR),
          ),

          if (!hasRoute)
            Positioned(
              bottom: 275,
              left: 0,
              right: 0,
              child: Center(child: _buildScanButton()),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildAddressRow(Icons.person, _startAddress, Colors.black87),
                const Padding(
                  padding: EdgeInsets.only(left: 35),
                  child: Divider(height: 20),
                ),
                _buildAddressRow(
                  Icons.flag,
                  _destinationAddress,
                  Colors.black87,
                  isDestination: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
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
                  onTap: () {
                    setState(() {
                      _selectedVehicleIndex = index;
                      _calculatePrice();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
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
                    onPressed: () {},
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

  Widget _buildAddressRow(
    IconData icon,
    String address,
    Color iconColor, {
    bool isDestination = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isDestination)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Arrêts",
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
      ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
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
          Icon(Icons.qr_code_scanner, color: Colors.pinkAccent, size: 22),
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

  Future<void> _updateAddressFromCoords(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}";
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
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
}
