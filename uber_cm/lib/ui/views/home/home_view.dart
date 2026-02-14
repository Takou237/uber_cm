import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Importation pour transformer les coordonnées en texte
import 'destination_view.dart';

class HomeView extends StatefulWidget {
  final String lang;
  const HomeView({super.key, this.lang = "EN"});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;

  // VARIABLE MISE À JOUR : On commence par un message de chargement
  String _currentAddress = "Localisation en cours...";

  static const CameraPosition _kInitialPos = CameraPosition(
    target: LatLng(3.8480, 11.5021),
    zoom: 14.4746,
  );

  /// Fonction pour obtenir la position et l'adresse réelle
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // 1. Récupérer les coordonnées GPS
    Position position = await Geolocator.getCurrentPosition();

    // 2. Transformer les coordonnées en adresse textuelle (Reverse Geocoding)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // On construit l'adresse (ex: "Mimba, Rue 1234")
          _currentAddress = "${place.street}, ${place.subLocality}";
        });
      }
    } catch (e) {
      debugPrint("Erreur de geocoding: $e");
    }

    // 3. Déplacer la caméra
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0,
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DestinationView(lang: widget.lang, currentAddress: _currentAddress),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFR = widget.lang.toUpperCase() == "FR";

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kInitialPos,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _determinePosition();
            },
          ),

          // BOUTONS FLOTTANTS
          Positioned(
            top: 50,
            left: 20,
            child: _buildFloatingButton(Icons.menu, onTap: () {}),
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                _buildFloatingButton(
                  Icons.my_location,
                  onTap: () => _determinePosition(),
                ),
                const SizedBox(height: 15),
                _buildFloatingButton(Icons.search, onTap: _openSearch),
              ],
            ),
          ),

          // PANEL DU BAS
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(isFR),
          ),

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

            // BARRE DE RECHERCHE DYNAMIQUE
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
                        // ON AFFICHE L'ADRESSE REELLE ICI
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

  // Tes autres widgets restent identiques...
  Widget _buildFloatingButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues( alpha:0.1), blurRadius: 10),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onTap,
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
}
