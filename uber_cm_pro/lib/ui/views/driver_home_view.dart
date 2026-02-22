import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/location_service.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({super.key});

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  bool _isOnline = false;
  final LocationService _locationService = LocationService();
  final String _driverId = "driver_001"; // Simulation d'un ID chauffeur

  void _toggleStatus() {
    setState(() {
      _isOnline = !_isOnline;
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
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(3.8480, 11.5021),
              zoom: 14,
            ),
            myLocationEnabled: true,
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
