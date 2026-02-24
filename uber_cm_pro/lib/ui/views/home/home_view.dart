import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../core/services/location_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isOnline = false;
  final LocationService _locationService = LocationService();
  
  // Dans un vrai projet, on récupère l'ID depuis le provider
  // final String _driverId = authProv.userId; 

  void _toggleStatus(String driverId) {
    setState(() {
      _isOnline = !_isOnline;
    });

    if (_isOnline) {
      _locationService.startRealtimeTracking(driverId);
    } else {
      _locationService.goOffline(driverId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final isFr = authProv.language == "fr";

    return Scaffold(
      body: Stack(
        children: [
          // 1. LA CARTE (Prend tout l'écran)
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(3.8480, 11.5021), // Yaoundé
              zoom: 14,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // 2. BARRE SUPÉRIEURE : Revenus et Profil
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton Menu/Profil
                  _headerCircleButton(Icons.menu, () {}),
                  
                  // Affichage des revenus (Le badge noir au milieu)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "0.00",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Text("FCFA", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),

                  // Bouton Recherche ou Statut
                  _headerCircleButton(Icons.insights, () {}),
                ],
              ),
            ),
          ),

          // 3. PANNEAU DE CONTRÔLE INFÉRIEUR (Bouton GO et Statut)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Petite barre de drag
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 15),
                  
                  Text(
                    _isOnline 
                      ? (isFr ? "VOUS ÊTES EN LIGNE" : "YOU ARE ONLINE") 
                      : (isFr ? "VOUS ÊTES HORS LIGNE" : "YOU ARE OFFLINE"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: _isOnline ? Colors.green[700] : Colors.grey[600],
                      letterSpacing: 1.2
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Le gros bouton circulaire GO / STOP
                  GestureDetector(
                    onTap: () => _toggleStatus("driver_001"), // Remplacer par authProv.id
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.red : const Color(0xFF2196F3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isOnline ? Colors.red : Colors.blue).withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isOnline ? "STOP" : "GO",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour les boutons du haut
  Widget _headerCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}