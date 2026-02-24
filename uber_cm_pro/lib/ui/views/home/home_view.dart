import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. LA MAP (Standard)
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.8480, 11.5021),
              zoom: 16,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
          ),

          // 2. BOUTON MENU (Top Left)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: _circleIconButton(Icons.menu),
            ),
          ),

          // 3. BOUTONS DROITE (My Location & Search)
          Positioned(
            right: 20,
            bottom: 320,
            child: Column(
              children: [
                _circleIconButton(Icons.my_location),
                const SizedBox(height: 15),
                _circleIconButton(Icons.search),
              ],
            ),
          ),

          // 4. PANNEAU INFÉRIEUR AVEC L'ENCOCHE ET LA LISTE
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _buildWhitePanel(),
                // LE BOUTON "GO ONLINE" (Placé sur la courbe)
                Positioned(
                  top: -28,
                  child: _goOnlineButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhitePanel() {
    return ClipPath(
      clipper: UberClipper(),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Onglets Drive / Earnings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navTab(Icons.attach_money, "Drive", true),
                  _navTab(Icons.monetization_on, "Earnings", false),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Divider(thickness: 1),
            
            // Section Weekly Challenges & Destinations
            _buildChallengesAndDestinations(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesAndDestinations() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Challenges",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
          ),
          const SizedBox(height: 15),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.black54),
                SizedBox(width: 10),
                Text("Search your destination", style: TextStyle(color: Colors.black38, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Liste Home / Work
          _destinationItem(Icons.home, "Home", "4127 Mendong Street, Phenix City, AL", Colors.redAccent),
          const Padding(padding: EdgeInsets.only(left: 60), child: Divider()),
          _destinationItem(Icons.business_center, "Work", "86706 Kuhic Trafficway, Upton Falls, SL", Colors.purple),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _destinationItem(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goOnlineButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF27D05D), // Vert brillant du design
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: const Text(
        "Go Online",
        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _navTab(IconData icon, String label, bool active) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0D1B3E) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: active ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _circleIconButton(IconData icon) {
    return Container(
      height: 50, width: 50,
      decoration: const BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Icon(icon, color: Colors.black87),
    );
  }
}

// ✅ LE CLIPPER POUR LA COURBE PARFAITE
class UberClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double h = size.height;
    double w = size.width;
    double curveHeight = 40.0;

    path.moveTo(0, curveHeight);
    path.quadraticBezierTo(0, 0, 30, 0); // Arrondi gauche
    
    // La courbe centrale pour le bouton
    path.lineTo(w / 2 - 85, 0);
    path.quadraticBezierTo(w / 2 - 70, 0, w / 2 - 60, 25);
    path.arcToPoint(Offset(w / 2 + 60, 25), radius: const Radius.circular(60), clockwise: false);
    path.quadraticBezierTo(w / 2 + 70, 0, w / 2 + 85, 0);

    path.lineTo(w - 30, 0);
    path.quadraticBezierTo(w, 0, w, curveHeight); // Arrondi droit
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}