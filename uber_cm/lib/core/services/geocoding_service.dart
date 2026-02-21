import 'package:flutter/material.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

class GeocodingService {
  Future<List<Place>> getSuggestions(String input) async {
    if (input.length < 3) return [];

    try {
      // ÉTAPE 1 : Créer l'instance avec le userAgent obligatoire
      final nominatim = Nominatim(userAgent: 'uber_cm_app');

      // ÉTAPE 2 : Appeler la méthode (search ou searchByName selon ta version)
      return await nominatim.searchByName(
        query: input,
        limit: 5,
        addressDetails: true,
        extraTags: true,
        countryCodes: ['cm'],
      );
    } catch (e) {
      debugPrint("Erreur de recherche : $e");
      return [];
    }
  }
}
