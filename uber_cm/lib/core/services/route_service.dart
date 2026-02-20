import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Structure pour transporter les données de l'itinéraire
class RouteData {
  final List<LatLng> points;
  final double distanceInMeters;

  RouteData({required this.points, required this.distanceInMeters});
}

class RouteService {
  /// Calcule l'itinéraire et la distance via OSRM
  Future<RouteData> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=polyline',
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'uber_cm_app',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          throw Exception('Aucun itinéraire trouvé');
        }

        final route = data['routes'][0];
        final String encodedPolyline = route['geometry'];

        // On récupère la distance renvoyée par l'API (en mètres)
        final double distance = (route['distance'] as num).toDouble();

        return RouteData(
          points: _decodePolyline(encodedPolyline),
          distanceInMeters: distance,
        );
      } else {
        throw Exception('Erreur serveur OSRM : ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      debugPrint("Erreur RouteService: $e");
      // Retourne un objet vide en cas d'erreur pour éviter le crash
      return RouteData(points: [], distanceInMeters: 0.0);
    }
  }

  /// Décode l'algorithme Polyline de Google
  List<LatLng> _decodePolyline(String str) {
    List<LatLng> poly = [];
    int index = 0, len = str.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}
